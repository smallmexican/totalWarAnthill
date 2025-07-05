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

var loaded_species: Array[SpeciesDataSimple] = []
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
				var species_resource = load(file_path)
				
				# Try to load as SpeciesDataSimple first, then SpeciesData
				var species_data = species_resource as SpeciesDataSimple
				if not species_data:
					species_data = species_resource as SpeciesData
				
				if species_data:
					loaded_species.append(species_data)
					species_files.append(file_path)
					species_list.add_item(species_data.species_name + " (" + species_data.species_id + ")")
				else:
					print("Warning: Could not load species from: ", file_path)
			
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
	var species_data = SpeciesDataSimple.new()
	
	# Set basic properties
	species_data.species_id = species_id
	species_data.species_name = species_name
	species_data.description = "A new ant species with unique characteristics."
	species_data.difficulty_rating = 2
	species_data.lore_text = "Add lore text here..."
	species_data.origin_biome = "forest"
	
	# Set balanced base stats
	species_data.attack_modifier = 1.0
	species_data.defense_modifier = 1.0
	species_data.speed_modifier = 1.0
	species_data.health_modifier = 1.0
	species_data.energy_modifier = 1.0
	
	# Set resource efficiency
	species_data.food_efficiency = 1.0
	species_data.material_efficiency = 1.0
	species_data.water_efficiency = 1.0
	species_data.research_efficiency = 1.0
	
	# Set population defaults
	species_data.reproduction_rate = 1.0
	species_data.max_population_bonus = 0
	species_data.worker_ratio = 0.6
	species_data.soldier_ratio = 0.3
	
	var file_path = "res://data/species/" + species_id + "_simple.tres"
	
	var result = ResourceSaver.save(species_data, file_path)
	if result == OK:
		output_text.text = "Created new species: " + species_name + " at " + file_path
		load_all_species()  # Refresh list
	else:
		output_text.text = "Error: Failed to save species file. Error code: " + str(result)

func _on_validate_all():
	var report = "SPECIES VALIDATION REPORT\n"
	report += "=" * 40 + "\n\n"
	
	var total_errors = 0
	
	for i in range(loaded_species.size()):
		var species = loaded_species[i]
		var errors: Array[String] = []
		
		# Basic validation for simplified species
		if species.species_id.is_empty():
			errors.append("species_id cannot be empty")
		
		if species.species_name.is_empty():
			errors.append("species_name cannot be empty")
		
		# Check stat balance
		var total_modifiers = species.get_total_stat_modifiers()
		if total_modifiers > 6.0:
			errors.append("Total stat modifiers may be too high: %.2f" % total_modifiers)
		
		if total_modifiers < 4.0:
			errors.append("Total stat modifiers may be too low: %.2f" % total_modifiers)
		
		# Check ratios
		var total_ratio = species.worker_ratio + species.soldier_ratio
		if total_ratio > 1.0:
			errors.append("Worker + Soldier ratio exceeds 1.0: %.2f" % total_ratio)
		
		# Check difficulty rating
		if species.difficulty_rating < 1 or species.difficulty_rating > 3:
			errors.append("Difficulty rating should be 1-3, got: %d" % species.difficulty_rating)
		
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
	
	# Create simple JSON export
	var data = {
		"species_name": species.species_name,
		"species_id": species.species_id,
		"description": species.description,
		"difficulty_rating": species.difficulty_rating,
		"attack_modifier": species.attack_modifier,
		"defense_modifier": species.defense_modifier,
		"speed_modifier": species.speed_modifier,
		"special_abilities": species.special_abilities,
		"passive_traits": species.passive_traits
	}
	
	var json_data = JSON.stringify(data, "\t")
	
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
