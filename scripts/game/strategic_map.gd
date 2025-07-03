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

# ------------------------------------------------------------------------------
# GODOT LIFECYCLE METHODS
# ------------------------------------------------------------------------------

## Initialize the strategic map
func _ready():
	# Get reference to the main scene manager
	main_scene_manager = get_tree().root.get_node("Main")
	
	# Display placeholder message
	print("=== STRATEGIC MAP LOADED ===")
	print("This is a placeholder scene.")
	print("Controls:")
	print("  ESC - Return to Main Menu")
	print("  C - Enter Colony View")
	print("  P - Show Pause Menu")

## Handle input for placeholder functionality
func _input(event):
	# Debug: Print all key presses to help diagnose issues
	if event is InputEventKey and event.pressed:
		print("Key pressed: ", event.keycode, " (", char(event.keycode), ")")
	
	# Return to main menu on ESC
	if event.is_action_pressed("ui_cancel"):
		print("ESC key detected - returning to main menu")
		return_to_main_menu()
	
	# Enter colony view on C key
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_C and event.pressed):
		print("C key detected - entering colony view")
		enter_colony_view()
	
	# Show pause menu on P key
	if event is InputEventKey and event.keycode == KEY_P and event.pressed:
		print("P key detected - showing pause menu")
		show_pause_menu()

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
	print("Entering Colony View...")
	if main_scene_manager:
		main_scene_manager.load_game_scene("res://scenes/game/ColonyView.tscn")
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
