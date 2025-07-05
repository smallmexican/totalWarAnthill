# ==============================================================================
# STRATEGIC MAP - PLACEHOLDER
# ==============================================================================
# Purpose: Main overworld view where players manage colonies and armies
# 
# CURRENT STATUS: PLACEHOLDER - Basic functionality for testing scene transitions
# 
# PLANNED FEATURES:
# - Tile-based garden map with different regions
# - Colony nodes that can be selected and managed
# - Army movement system between territories
# - Fog of war and territory control
# - Day/night cycle and turn-based progression
# - Battle initiation when armies meet
#
# USAGE:
# - This scene is loaded when the player clicks "Start Game"
# - Press ESC to return to main menu (placeholder functionality)
# - Press C to enter Colony View (placeholder functionality)
#
# TODO: Replace with actual strategic map implementation
# ==============================================================================

extends Node2D

# ------------------------------------------------------------------------------
# PLACEHOLDER VARIABLES
# ------------------------------------------------------------------------------

## Reference to the main scene manager for transitions
var main_scene_manager: Node

## Game configuration data passed from skirmish setup
var game_config: Dictionary = {}

## Current player species data
var player_species_data: SpeciesDataSimple

## Reference to the species stats bar UI
@onready var species_stats_bar: Control = $SpeciesStatsBar

# ----------------------------------------------------------------------------
# GAMEPLAY INTEGRATION
# -----------------------------------------------------------------------------

## Initialize the strategic map with gameplay configuration
func initialize_with_gameplay(config: Dictionary):
	print("🎮 Initializing Strategic Map with gameplay config:")
	print("   Player Species: ", config.get("player_species", "Unknown"))
	print("   Opponent Species: ", config.get("opponent_species", "Unknown"))
	
	game_config = config
	
	# Load player species data
	load_player_species_data()
	
	# Update the species stats bar
	if species_stats_bar and player_species_data:
		if species_stats_bar.has_method("update_species_display"):
			species_stats_bar.call("update_species_display", player_species_data)
			print("✅ Species stats bar updated with ", player_species_data.species_name)
		else:
			print("❌ Species stats bar missing update_species_display method")
	else:
		print("❌ Failed to update species stats bar")

## Load the player's selected species data
func load_player_species_data():
	var player_species_id = game_config.get("player_species", "")
	if player_species_id.is_empty():
		print("❌ No player species specified in config")
		return
	
	# Try to load from SpeciesManager singleton first
	if SpeciesManager and SpeciesManager.has_method("get_species_data"):
		player_species_data = SpeciesManager.get_species_data(player_species_id)
		if player_species_data:
			print("✅ Loaded species data from SpeciesManager: ", player_species_data.species_name)
			return
	
	# Fallback: Load directly from file
	var species_file_path = "res://data/species/" + player_species_id + "_simple.tres"
	if FileAccess.file_exists(species_file_path):
		player_species_data = load(species_file_path) as SpeciesDataSimple
		if player_species_data:
			print("✅ Loaded species data from file: ", player_species_data.species_name)
		else:
			print("❌ Failed to load species data from: ", species_file_path)
	else:
		print("❌ Species file not found: ", species_file_path)

## Get singleton instance (helper method)
func get_singleton(singleton_name: String) -> Node:
	return Engine.get_singleton(singleton_name)

## Check if singleton exists (helper method)
func has_singleton(singleton_name: String) -> bool:
	return Engine.has_singleton(singleton_name)

# ------------------------------------------------------------------------------
# GODOT LIFECYCLE METHODS
# ------------------------------------------------------------------------------

## Initialize the strategic map
func _ready():
	# Get reference to the main scene manager
	main_scene_manager = get_tree().root.get_node("Main")
	
	# Debug: Verify the main scene manager reference
	if main_scene_manager:
		print("✅ Main scene manager found: ", main_scene_manager.name)
		# Check if show_pause_menu method exists
		if main_scene_manager.has_method("show_pause_menu"):
			print("✅ show_pause_menu method exists")
		else:
			print("❌ show_pause_menu method NOT found!")
	else:
		print("❌ Failed to get main scene manager!")
	
	# Ensure species stats bar doesn't block input
	if species_stats_bar:
		species_stats_bar.mouse_filter = Control.MOUSE_FILTER_PASS
		print("✅ Species stats bar mouse filter set to PASS")
	
	# Display placeholder message
	print("=== STRATEGIC MAP LOADED ===")
	print("This is a placeholder scene.")
	print("Controls:")
	print("  ESC - Show Game Menu (Save/Load/Settings/Main Menu)")
	print("  C - Enter Colony View")
	print("  P - Show Pause Menu")
	print("  Click Colony Button - Enter Colony View")

## Handle input for placeholder functionality
func _input(event):
	# Debug: Print all key presses to help diagnose issues
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		print("Key pressed: ", event.keycode, " (", key_name, ")")
	
	# Return to main menu on ESC (ui_cancel)
	if event.is_action_pressed("ui_cancel"):
		print("ESC key detected (ui_cancel) - showing game menu")
		get_viewport().set_input_as_handled()
		show_game_menu()
		return
	
	# Alternative ESC key detection (direct keycode check)
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		print("ESC key detected (direct) - showing game menu")
		get_viewport().set_input_as_handled()
		show_game_menu()
		return
	
	# Enter colony view on C key
	if event is InputEventKey and event.keycode == KEY_C and event.pressed:
		print("C key detected - entering colony view")
		get_viewport().set_input_as_handled()
		enter_colony_view()
		return
	
	# Show pause menu on P key
	if event is InputEventKey and event.keycode == KEY_P and event.pressed:
		print("P key detected - showing pause menu")
		get_viewport().set_input_as_handled()
		show_pause_menu()
		return
	
	## Debug mouse input to see if ANY clicks are detected
	if event is InputEventMouseButton and event.pressed:
		print("Mouse click detected at: ", event.position)
		print("Button: ", event.button_index)

# ------------------------------------------------------------------------------
# SCENE TRANSITION METHODS
# ------------------------------------------------------------------------------

## Return to the main menu
## @note: This is placeholder functionality for testing
func return_to_main_menu():
	print("Returning to Main Menu...")
	if main_scene_manager:
		main_scene_manager.load_menu("res://ui/MainMenu.tscn")
	else:
		print("ERROR: main_scene_manager is null!")

## Enter colony management view
## @note: This will load the colony management scene
func enter_colony_view():
	print("StrategicMap: enter_colony_view() called")
	if main_scene_manager:
		print("StrategicMap: main_scene_manager found, calling load_game_scene()")
		if main_scene_manager.has_method("load_game_scene"):
			print("StrategicMap: load_game_scene method exists")
			main_scene_manager.load_game_scene("res://scenes/game/ColonyView.tscn")
		else:
			print("ERROR: load_game_scene method NOT found!")
	else:
		print("ERROR: main_scene_manager is null!")

## Show the game menu (in-game menu with save/load/settings options)
## @note: Shows game menu as overlay without clearing this scene
func show_game_menu():
	print("StrategicMap: show_game_menu() called")
	if main_scene_manager:
		print("StrategicMap: main_scene_manager found, calling show_game_menu()")
		if main_scene_manager.has_method("show_game_menu"):
			print("StrategicMap: show_game_menu method exists on main_scene_manager")
			main_scene_manager.show_game_menu()
		else:
			print("ERROR: show_game_menu method NOT found on main_scene_manager!")
	else:
		print("ERROR: main_scene_manager is null!")

## Show the pause menu
## @note: Shows pause menu as overlay without clearing this scene
func show_pause_menu():
	print("Showing Pause Menu...")
	if main_scene_manager:
		main_scene_manager.show_pause_menu()
	else:
		print("ERROR: main_scene_manager is null!")

# ------------------------------------------------------------------------------
# FUTURE IMPLEMENTATION METHODS (PLACEHOLDER STUBS)
# ------------------------------------------------------------------------------

## Initialize the strategic map with regions and territories
## TODO: Implement actual map generation
func setup_map():
	pass

## Handle colony selection and management
## TODO: Implement colony interaction system
func select_colony(colony_id: int):
	pass

## Move armies between territories
## TODO: Implement army movement system
func move_army(from_territory: int, to_territory: int):
	pass

## Update the day/night cycle
## TODO: Implement time progression system
func advance_turn():
	pass

## Check for random events (predators, weather, etc.)
## TODO: Implement event system
func check_random_events():
	pass

# ------------------------------------------------------------------------------
# UI SIGNAL HANDLERS
# ------------------------------------------------------------------------------

## Handle colony button press
## @note: Signal handler for the ColonyButton
func _on_colony_button_pressed() -> void:
	print("=== COLONY BUTTON SIGNAL FIRED ===")
	print("Colony button clicked!")
	enter_colony_view()

## Handle when mouse enters the colony button area
func _on_colony_button_mouse_entered() -> void:
	print("Mouse entered colony button area")

## Handle when mouse exits the colony button area  
func _on_colony_button_mouse_exited() -> void:
	print("Mouse exited colony button area")
