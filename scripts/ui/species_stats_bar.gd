# ==============================================================================
# SPECIES_STATS_BAR - UI Component for Displaying Player Species Information
# ==============================================================================
# Purpose: Shows selected species stats in a top bar on the strategic map
# 
# This component displays:
# - Species name and icon
# - Key combat stats (attack, defense, speed)
# - Special abilities
# - Resource efficiency indicators
#
# Usage:
# - Add to Strategic Map as top UI bar
# - Call update_species_display(species_data) to populate
# ==============================================================================

class_name SpeciesStatsBar
extends Control

# ==============================================================================
# UI REFERENCES
# ==============================================================================

@onready var species_name_label: Label = $HBoxContainer/SpeciesInfo/SpeciesName
@onready var species_icon: TextureRect = $HBoxContainer/SpeciesInfo/HBoxContainer/SpeciesIcon
@onready var difficulty_label: Label = $HBoxContainer/SpeciesInfo/HBoxContainer/Difficulty

@onready var attack_stat: RichTextLabel = $HBoxContainer/CombatStats/StatsContainer/AttackStat
@onready var defense_stat: RichTextLabel = $HBoxContainer/CombatStats/StatsContainer/DefenseStat
@onready var speed_stat: RichTextLabel = $HBoxContainer/CombatStats/StatsContainer/SpeedStat

@onready var food_efficiency: RichTextLabel = $HBoxContainer/ResourceStats/ResourceContainer/FoodEfficiency
@onready var material_efficiency: RichTextLabel = $HBoxContainer/ResourceStats/ResourceContainer/MaterialEfficiency

@onready var abilities_label: Label = $HBoxContainer/Abilities/AbilitiesList

# ==============================================================================
# SPECIES DISPLAY
# ==============================================================================

## Current species data
var current_species: SpeciesDataSimple

## Update the display with new species data
func update_species_display(species_data: SpeciesDataSimple):
	print("🧬 SpeciesStatsBar: Updating display with species data...")
	
	if not species_data:
		print("❌ No species data provided to stats bar")
		return
	
	current_species = species_data
	print("✅ Updating display for: " + species_data.species_name)
	
	# Update basic info (with null checks)
	if species_name_label:
		species_name_label.text = species_data.species_name
		print("   Set species name: " + species_data.species_name)
	else:
		print("   ⚠️ Species name label not found")
	
	if difficulty_label:
		difficulty_label.text = "★".repeat(species_data.difficulty_rating)
		print("   Set difficulty: " + str(species_data.difficulty_rating))
	else:
		print("   ⚠️ Difficulty label not found")
	
	# Update combat stats with color coding (with null checks)
	if attack_stat:
		update_stat_label(attack_stat, "ATK", species_data.attack_modifier)
	else:
		print("   ⚠️ Attack stat label not found")
		
	if defense_stat:
		update_stat_label(defense_stat, "DEF", species_data.defense_modifier)
	else:
		print("   ⚠️ Defense stat label not found")
		
	if speed_stat:
		update_stat_label(speed_stat, "SPD", species_data.speed_modifier)
	else:
		print("   ⚠️ Speed stat label not found")
	
	# Update resource efficiency (with null checks)
	if food_efficiency:
		update_efficiency_label(food_efficiency, "Food", species_data.food_efficiency)
	else:
		print("   ⚠️ Food efficiency label not found")
		
	if material_efficiency:
		update_efficiency_label(material_efficiency, "Materials", species_data.material_efficiency)
	else:
		print("   ⚠️ Material efficiency label not found")
	
	# Update abilities (with null check)
	if abilities_label:
		var abilities_text = ""
		if species_data.special_abilities.size() > 0:
			abilities_text = "Abilities: " + ", ".join(species_data.special_abilities.slice(0, 3))
			if species_data.special_abilities.size() > 3:
				abilities_text += "..."
		else:
			abilities_text = "No special abilities"
		
		abilities_label.text = abilities_text
		print("   Set abilities: " + abilities_text)
	else:
		print("   ⚠️ Abilities label not found")
	
	print("✅ Species stats bar update completed")

## Update a stat label with appropriate color coding
func update_stat_label(label: RichTextLabel, stat_name: String, value: float):
	var display_value = "%.1f" % value
	var color_code = ""
	
	if value > 1.1:
		color_code = "[color=green]"  # Good stats in green
	elif value < 0.9:
		color_code = "[color=red]"    # Poor stats in red
	else:
		color_code = "[color=white]"  # Normal stats in white
	
	label.text = "%s: %s%s[/color]" % [stat_name, color_code, display_value]

## Update efficiency label with percentage display
func update_efficiency_label(label: RichTextLabel, resource_name: String, value: float):
	var percentage = int((value - 1.0) * 100)
	var color_code = ""
	var sign = ""
	
	if percentage > 0:
		color_code = "[color=green]"
		sign = "+"
	elif percentage < 0:
		color_code = "[color=red]"
	else:
		color_code = "[color=white]"
	
	label.text = "%s: %s%s%d%%[/color]" % [resource_name, color_code, sign, percentage]

## Show species tooltip with detailed information
func show_species_tooltip():
	if not current_species:
		return
	
	var tooltip_text = current_species.get_summary()
	
	# For now, just print to console - you could create a proper tooltip UI later
	print("Species Tooltip:\n" + tooltip_text)

# ==============================================================================
# INPUT HANDLING
# ==============================================================================

func _ready():
	# Make the bar clickable for tooltip, but don't block other UI elements
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Ensure the bar doesn't block input to other elements
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Debug: Check if all UI elements are found
	print("🧬 SpeciesStatsBar: Checking UI element references...")
	print("   Species name label: ", "✅" if species_name_label else "❌")
	print("   Species icon: ", "✅" if species_icon else "❌") 
	print("   Difficulty label: ", "✅" if difficulty_label else "❌")
	print("   Attack stat: ", "✅" if attack_stat else "❌")
	print("   Defense stat: ", "✅" if defense_stat else "❌")
	print("   Speed stat: ", "✅" if speed_stat else "❌")
	print("   Food efficiency: ", "✅" if food_efficiency else "❌")
	print("   Material efficiency: ", "✅" if material_efficiency else "❌")
	print("   Abilities label: ", "✅" if abilities_label else "❌")

func _on_mouse_entered():
	modulate = Color(1.1, 1.1, 1.1)  # Slight highlight

func _on_mouse_exited():
	modulate = Color.WHITE

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		show_species_tooltip()
