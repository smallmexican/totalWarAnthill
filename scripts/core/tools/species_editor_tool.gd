# ==============================================================================
# SPECIES_EDITOR_TOOL - Godot Editor Tool for Species Management
# ==============================================================================
# Purpose: In-editor tool for creating, editing, and managing species data
# 
# Instructions:
# 1. Add this script to a scene
# 2. Mark the script as @tool
# 3. Use in the editor to create new species
# 4. Validate existing species data
# 5. Export/import JSON for easier editing
#
# Usage: Run scene in editor, use buttons to manage species
# ==============================================================================

@tool
extends Control

# ==============================================================================
# UI REFERENCES
# ==============================================================================

@onready var species_list: ItemList = $VBoxContainer/SpeciesList
@onready var create_button: Button = $VBoxContainer/HBoxContainer/CreateButton
@onready var validate_button: Button = $VBoxContainer/HBoxContainer/ValidateButton
@onready var export_button: Button = $VBoxContainer/HBoxContainer/ExportButton
@onready var import_button: Button = $VBoxContainer/HBoxContainer/ImportButton
@onready var output_text: TextEdit = $VBoxContainer/OutputText

# ==============================================================================
# SPECIES MANAGEMENT
# ==============================================================================

var loaded_species: Array[SpeciesData] = []
var species_files: Array[String] = []

func _ready():
	if not Engine.is_editor_hint():
		return
	
	setup_ui()
	load_all_species()

func setup_ui():
	# Connect buttons
	create_button.pressed.connect(_on_create_species)
	validate_button.pressed.connect(_on_validate_all)
	export_button.pressed.connect(_on_export_selected)
	import_button.pressed.connect(_on_import_json)
	
	# Setup lists
	species_list.item_selected.connect(_on_species_selected)

func load_all_species():
	loaded_species.clear()
	species_files.clear()
	species_list.clear()
	
	var dir = DirAccess.open("res://data/species/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tres"):
				var file_path = "res://data/species/" + file_name
				var species_data = SpeciesCreator.load_species_from_file(file_path)
				
				if species_data:
					loaded_species.append(species_data)
					species_files.append(file_path)
					species_list.add_item(species_data.species_name + " (" + species_data.species_id + ")")
			
			file_name = dir.get_next()
	
	output_text.text = "Loaded %d species from res://data/species/" % loaded_species.size()

# ==============================================================================
# BUTTON HANDLERS
# ==============================================================================

func _on_create_species():
	var dialog = AcceptDialog.new()
	var vbox = VBoxContainer.new()
	
	var id_label = Label.new()
	id_label.text = "Species ID:"
	var id_input = LineEdit.new()
	id_input.placeholder_text = "fire_ant"
	
	var name_label = Label.new()
	name_label.text = "Species Name:"
	var name_input = LineEdit.new()
	name_input.placeholder_text = "Fire Ant"
	
	vbox.add_child(id_label)
	vbox.add_child(id_input)
	vbox.add_child(name_label)
	vbox.add_child(name_input)
	
	dialog.add_child(vbox)
	dialog.title = "Create New Species"
	dialog.confirmed.connect(func():
		var species_id = id_input.text.strip_edges()
		var species_name = name_input.text.strip_edges()
		
		if species_id.is_empty() or species_name.is_empty():
			output_text.text = "Error: Both ID and Name are required"
			return
		
		create_new_species(species_id, species_name)
		dialog.queue_free()
	)
	
	add_child(dialog)
	dialog.popup_centered()

func create_new_species(species_id: String, species_name: String):
	var species_data = SpeciesCreator.create_species_template(species_id, species_name)
	var file_path = "res://data/species/" + species_id + ".tres"
	
	if SpeciesCreator.save_species_to_file(species_data, file_path):
		output_text.text = "Created new species: " + species_name + " at " + file_path
		load_all_species()  # Refresh list
	else:
		output_text.text = "Error: Failed to save species file"

func _on_validate_all():
	var report = "SPECIES VALIDATION REPORT\n"
	report += "=" * 40 + "\n\n"
	
	var total_errors = 0
	
	for i in range(loaded_species.size()):
		var species = loaded_species[i]
		var errors = SpeciesCreator.validate_species_data(species)
		
		report += "%s (%s):\n" % [species.species_name, species.species_id]
		
		if errors.is_empty():
			report += "  ✓ No issues found\n"
		else:
			for error in errors:
				report += "  ✗ " + error + "\n"
				total_errors += 1
		
		report += "\n"
	
	report += "Total errors found: %d\n" % total_errors
	
	if total_errors == 0:
		report += "\n🎉 All species data is valid!"
	
	output_text.text = report

func _on_export_selected():
	var selected = species_list.get_selected_items()
	if selected.is_empty():
		output_text.text = "Error: No species selected for export"
		return
	
	var species = loaded_species[selected[0]]
	var json_data = SpeciesCreator.export_to_json(species)
	
	# Save to file
	var file_path = "res://data/species/" + species.species_id + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_data)
		file.close()
		output_text.text = "Exported " + species.species_name + " to " + file_path
	else:
		output_text.text = "Error: Failed to export JSON file"

func _on_import_json():
	# Simple implementation - you could add file dialog here
	output_text.text = "JSON import feature - add FileDialog for full implementation"

func _on_species_selected(index: int):
	if index >= 0 and index < loaded_species.size():
		var species = loaded_species[index]
		var info = "SPECIES INFO: %s\n" % species.species_name
		info += "ID: %s\n" % species.species_id
		info += "Difficulty: %d/3\n" % species.difficulty_rating
		info += "Origin: %s\n" % species.origin_biome
		info += "\nSTATS:\n"
		info += "Attack: %.2f\n" % species.attack_modifier
		info += "Defense: %.2f\n" % species.defense_modifier
		info += "Speed: %.2f\n" % species.speed_modifier
		info += "\nABILITIES: %s\n" % ", ".join(species.special_abilities)
		info += "\nDESCRIPTION:\n%s" % species.description
		
		output_text.text = info
