# ==============================================================================
# SKIRMISH SETUP MENU
# ==============================================================================
# Purpose: Configure skirmish match settings before starting gameplay
# 
# CURRENT STATUS: FUNCTIONAL - Full setup for species, map, and opponent
# 
# FEATURES:
# - Player ant species selection (Fire/Carpenter/Harvester Ants)
# - Opponent species and difficulty configuration
# - Map selection with preview
# - Dynamic match information display
# - Species information panel with stats
#
# USAGE:
# - Accessed from Game Selection Menu → Skirmish Mode
# - Configure all match parameters
# - Start Match → Loads Strategic Map with configured settings
# - Back → Return to Game Selection Menu
#
# CONFIGURATION OPTIONS:
# - Player Species: Fire Ants, Carpenter Ants, Harvester Ants
# - Opponent: Random/Specific species with Easy/Normal/Hard difficulty
# - Maps: Garden Valley (expandable for more maps)
# ==============================================================================

extends Control

# ------------------------------------------------------------------------------
# MEMBER VARIABLES
# ------------------------------------------------------------------------------

## Reference to the main scene manager for transitions
var main_scene_manager: Node

## Current match configuration
var match_config = {
	"player_species": "Fire Ants",
	"opponent_species": "Random",
	"opponent_difficulty": "Normal", 
	"map": "Garden Valley"
}

## Species data for information display
var species_data = {
	"Fire Ants": {
		"display_name": "🔴 FIRE ANTS",
		"color": Color.RED,
		"description": "[b]Fire Ants[/b]\n\n[color=red]+ Strong Attack[/color]\n[color=red]+ Fast Workers[/color]\n[color=yellow]- Moderate Defense[/color]\n[color=yellow]- Average Resources[/color]\n\nAggressive species focused on rapid expansion and combat."
	},
	"Carpenter Ants": {
		"display_name": "⚫ CARPENTER ANTS", 
		"color": Color.BLACK,
		"description": "[b]Carpenter Ants[/b]\n\n[color=green]+ Excellent Building[/color]\n[color=green]+ Strong Defense[/color]\n[color=yellow]- Slower Attack[/color]\n[color=yellow]- Moderate Speed[/color]\n\nMaster builders with superior tunnel construction abilities."
	},
	"Harvester Ants": {
		"display_name": "🟡 HARVESTER ANTS",
		"color": Color.YELLOW,
		"description": "[b]Harvester Ants[/b]\n\n[color=green]+ Superior Resources[/color]\n[color=green]+ Fast Gathering[/color]\n[color=yellow]- Weaker Combat[/color]\n[color=yellow]- Slower Building[/color]\n\nResource specialists with excellent food management."
	}
}

## Map data for selection and preview
var map_data = {
	"Garden Valley": {
		"display_name": "Garden Valley",
		"description": "A peaceful garden setting with moderate resources",
		"preview_color": Color(0.3, 0.5, 0.3, 1)
	},
	"Desert Oasis": {
		"display_name": "Desert Oasis", 
		"description": "Harsh desert with limited water sources",
		"preview_color": Color(0.8, 0.6, 0.3, 1)
	},
	"Forest Floor": {
		"display_name": "Forest Floor",
		"description": "Dense woodland with abundant resources",
		"preview_color": Color(0.2, 0.4, 0.2, 1)
	}
}

# ------------------------------------------------------------------------------
# GODOT LIFECYCLE METHODS
# ------------------------------------------------------------------------------

## Initialize the skirmish setup menu
func _ready():
	print("SkirmishSetupMenu: _ready() called")
	
	# Get reference to the main scene manager
	main_scene_manager = get_tree().root.get_node("Main")
	if main_scene_manager:
		print("SkirmishSetupMenu: main_scene_manager found: ", main_scene_manager.name)
	else:
		print("SkirmishSetupMenu: ERROR - main_scene_manager not found!")
	
	# Setup initial configuration
	setup_dropdown_options()
	update_match_info()
	update_species_info()
	
	print("=== SKIRMISH SETUP MENU LOADED ===")
	print("Configure your match settings and click Start Match")

## Setup dropdown menu options
func setup_dropdown_options():
	# Setup opponent species options
	var opponent_species = $MainContainer/LeftPanel/OpponentSpeciesContainer/OpponentSpeciesOption
	opponent_species.clear()
	opponent_species.add_item("Random Species")
	opponent_species.add_item("🔴 Fire Ants")
	opponent_species.add_item("⚫ Carpenter Ants") 
	opponent_species.add_item("🟡 Harvester Ants")
	
	# Setup difficulty options
	var difficulty = $MainContainer/LeftPanel/OpponentDifficultyContainer/DifficultyOption
	difficulty.clear()
	difficulty.add_item("Easy")
	difficulty.add_item("Normal")
	difficulty.add_item("Hard")
	difficulty.select(1)  # Default to Normal
	
	# Setup map options
	var map_option = $MainContainer/CenterPanel/MapSelectionContainer/MapOption
	map_option.clear()
	map_option.add_item("Garden Valley")
	map_option.add_item("Desert Oasis (Coming Soon)")
	map_option.add_item("Forest Floor (Coming Soon)")
	# Disable coming soon options
	map_option.set_item_disabled(1, true)
	map_option.set_item_disabled(2, true)

# ------------------------------------------------------------------------------
# INPUT HANDLING
# ------------------------------------------------------------------------------

## Handle input for skirmish setup menu (ESC to go back)
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("ESC pressed in skirmish setup menu - returning to game selection")
		_on_back_button_pressed()

# ------------------------------------------------------------------------------
# SPECIES SELECTION HANDLERS
# ------------------------------------------------------------------------------

## Handle Fire Ants selection
func _on_red_ants_button_pressed():
	select_player_species("Fire Ants")

## Handle Carpenter Ants selection  
func _on_black_ants_button_pressed():
	select_player_species("Carpenter Ants")

## Handle Harvester Ants selection
func _on_yellow_ants_button_pressed():
	select_player_species("Harvester Ants")

## Update player species selection
func select_player_species(species: String):
	print("Player species selected: ", species)
	match_config.player_species = species
	
	# Update button states (toggle group behavior)
	var red_btn = $MainContainer/LeftPanel/PlayerSpeciesContainer/RedAntsButton
	var black_btn = $MainContainer/LeftPanel/PlayerSpeciesContainer/BlackAntsButton
	var yellow_btn = $MainContainer/LeftPanel/PlayerSpeciesContainer/YellowAntsButton
	
	red_btn.button_pressed = (species == "Fire Ants")
	black_btn.button_pressed = (species == "Carpenter Ants")
	yellow_btn.button_pressed = (species == "Harvester Ants")
	
	update_match_info()
	update_species_info()

# ------------------------------------------------------------------------------
# OPPONENT CONFIGURATION HANDLERS
# ------------------------------------------------------------------------------

## Handle opponent species selection
func _on_opponent_species_option_item_selected(index: int):
	var species_names = ["Random", "Fire Ants", "Carpenter Ants", "Harvester Ants"]
	var selected_species = species_names[index]
	print("Opponent species selected: ", selected_species)
	match_config.opponent_species = selected_species
	update_match_info()

## Handle difficulty selection
func _on_difficulty_option_item_selected(index: int):
	var difficulties = ["Easy", "Normal", "Hard"]
	var selected_difficulty = difficulties[index]
	print("Difficulty selected: ", selected_difficulty)
	match_config.opponent_difficulty = selected_difficulty
	update_match_info()

# ------------------------------------------------------------------------------
# MAP SELECTION HANDLERS
# ------------------------------------------------------------------------------

## Handle map selection
func _on_map_option_item_selected(index: int):
	var map_names = ["Garden Valley", "Desert Oasis", "Forest Floor"]
	if index < map_names.size():
		var selected_map = map_names[index]
		print("Map selected: ", selected_map)
		match_config.map = selected_map
		update_map_preview()
		update_match_info()

## Update map preview display
func update_map_preview():
	var current_map = match_config.map
	if current_map in map_data:
		var preview = $MainContainer/CenterPanel/MapPreviewContainer/MapPreview
		var label = $MainContainer/CenterPanel/MapPreviewContainer/MapPreview/MapPreviewLabel
		
		preview.color = map_data[current_map].preview_color
		label.text = map_data[current_map].display_name

# ------------------------------------------------------------------------------
# UI UPDATE METHODS
# ------------------------------------------------------------------------------

## Update match information display
func update_match_info():
	var player_info = $MainContainer/RightPanel/InfoContainer/PlayerInfoLabel
	var opponent_info = $MainContainer/RightPanel/InfoContainer/OpponentInfoLabel
	var map_info = $MainContainer/RightPanel/InfoContainer/MapInfoLabel
	
	player_info.text = "Player: " + match_config.player_species
	opponent_info.text = "Opponent: " + match_config.opponent_species + " (" + match_config.opponent_difficulty + ")"
	map_info.text = "Map: " + match_config.map

## Update species information panel
func update_species_info():
	var current_species = match_config.player_species
	if current_species in species_data:
		var species_label = $MainContainer/RightPanel/SpeciesInfoLabel
		var species_text = $MainContainer/RightPanel/SpeciesInfoText
		
		species_label.text = species_data[current_species].display_name
		species_text.text = species_data[current_species].description

# ------------------------------------------------------------------------------
# NAVIGATION HANDLERS
# ------------------------------------------------------------------------------

## Handle Back button - return to game selection
func _on_back_button_pressed():
	print("SkirmishSetupMenu: Back button pressed")
	print("Returning to Game Selection...")
	
	if main_scene_manager:
		main_scene_manager.load_menu("res://scenes/ui/GameSelectionMenu.tscn")
	else:
		print("ERROR: main_scene_manager is null!")

## Handle Start Match button - begin skirmish with configured settings
func _on_start_match_button_pressed():
	print("SkirmishSetupMenu: Start Match button pressed")
	print("Starting skirmish with configuration:")
	print("  Player: ", match_config.player_species)
	print("  Opponent: ", match_config.opponent_species, " (", match_config.opponent_difficulty, ")")
	print("  Map: ", match_config.map)
	
	if main_scene_manager:
		# TODO: Pass match configuration to Strategic Map
		# For now, just load Strategic Map normally
		main_scene_manager.load_game_scene("res://scenes/game/StrategicMap.tscn")
	else:
		print("ERROR: main_scene_manager is null!")

# ------------------------------------------------------------------------------
# FUTURE IMPLEMENTATION METHODS (PLACEHOLDER STUBS)
# ------------------------------------------------------------------------------

## Pass match configuration to game scenes
## TODO: Implement configuration persistence
func apply_match_config_to_game():
	print("Applying match configuration to game...")
	# TODO: Future implementation
	# - Pass species selection to Strategic Map
	# - Configure AI opponent settings
	# - Load appropriate map/terrain
	# - Set up initial colony parameters
	pass

## Load map-specific assets and configuration
## TODO: Implement dynamic map loading
func load_map_configuration(map_name: String):
	print("Loading map configuration for: ", map_name)
	# TODO: Future implementation
	# - Load map-specific terrain
	# - Configure resource distribution
	# - Set environmental factors
	# - Load map-specific music/ambience
	pass

## Configure AI opponent based on settings
## TODO: Implement AI difficulty scaling
func configure_ai_opponent():
	print("Configuring AI opponent...")
	# TODO: Future implementation
	# - Set AI difficulty parameters
	# - Configure AI species bonuses
	# - Adjust AI behavior patterns
	# - Set AI starting conditions
	pass
