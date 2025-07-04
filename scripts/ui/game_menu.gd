# ==============================================================================
# GAME MENU - IN-GAME PAUSE/OPTIONS MENU
# ==============================================================================
# Purpose: In-game menu accessible during gameplay via ESC key
# 
# CURRENT STATUS: FUNCTIONAL - Provides access to save/load and other options
# 
# FEATURES:
# - Resume game functionality
# - Save/Load game options (placeholder)
# - Access to settings menu
# - Return to main menu option
# - Quit game option
# - ESC key to resume
#
# USAGE:
# - Accessed by pressing ESC in any gameplay scene (Strategic Map, Colony View)
# - Shows as overlay without destroying the game scene
# - Resume returns to the previous gameplay scene
#
# NAVIGATION:
# - Resume Game → Close this menu and return to game
# - Save/Load → Access save/load functionality (TODO)
# - Settings → Open settings menu
# - Main Menu → Return to main menu (with confirmation)
# - Quit → Exit the application
# ==============================================================================

extends Control

# ------------------------------------------------------------------------------
# MEMBER VARIABLES
# ------------------------------------------------------------------------------

## Reference to the main scene manager for transitions
var main_scene_manager: Node

## Store the previous scene path to return to after resume
var previous_scene_path: String = "res://scenes/game/StrategicMap.tscn"

# ------------------------------------------------------------------------------
# GODOT LIFECYCLE METHODS
# ------------------------------------------------------------------------------

## Initialize the game menu
func _ready():
	print("GameMenu: _ready() called")
	
	# Get reference to the main scene manager
	main_scene_manager = get_tree().root.get_node("Main")
	if main_scene_manager:
		print("GameMenu: main_scene_manager found: ", main_scene_manager.name)
	else:
		print("GameMenu: ERROR - main_scene_manager not found!")
	
	# Display game menu information
	print("=== GAME MENU LOADED ===")
	print("In-game menu active. Game is paused.")

# ------------------------------------------------------------------------------
# INPUT HANDLING
# ------------------------------------------------------------------------------

## Handle input for game menu (ESC to resume)
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("ESC pressed in game menu - resuming game")
		_on_resume_button_pressed()

# ------------------------------------------------------------------------------
# BUTTON SIGNAL HANDLERS
# ------------------------------------------------------------------------------

## Resume the game and return to previous scene
## @note: Closes the game menu overlay to resume the game
func _on_resume_button_pressed() -> void:
	print("Resuming game...")
	# Simply close the game menu to resume the game
	# The game scene remains active in the background
	queue_free()

## Save the current game state
## @note: Placeholder functionality - to be implemented
func _on_save_button_pressed() -> void:
	print("Save Game functionality - TODO")
	# TODO: Implement save game system
	# - Serialize current game state
	# - Save to file with timestamp
	# - Show confirmation message
	pass

## Load a previously saved game
## @note: Placeholder functionality - to be implemented
func _on_load_button_pressed() -> void:
	print("Load Game functionality - TODO")
	# TODO: Implement load game system
	# - Show list of saved games
	# - Allow selection and loading
	# - Transition to loaded game state
	pass

## Open the settings menu
## @note: Opens settings as overlay, can return to this menu
func _on_settings_button_pressed() -> void:
	print("Opening settings from game menu...")
	if main_scene_manager:
		main_scene_manager.show_settings_menu("res://scenes/ui/GameMenu.tscn", true)
	else:
		print("ERROR: main_scene_manager is null!")

## Return to the main menu
## @warning: This will lose any unsaved game progress
func _on_main_menu_button_pressed() -> void:
	print("Returning to main menu...")
	# TODO: Add confirmation dialog for unsaved progress
	if main_scene_manager:
		main_scene_manager.load_menu("res://ui/MainMenu.tscn")
	else:
		print("ERROR: main_scene_manager is null!")

## Quit the game application
## @warning: This will lose any unsaved game progress
func _on_quit_button_pressed() -> void:
	print("Quitting game...")
	# TODO: Add confirmation dialog for unsaved progress
	get_tree().quit()

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------

## Set the previous scene path for proper resume functionality
## @param scene_path: String path to the scene to return to on resume
func set_previous_scene(scene_path: String):
	previous_scene_path = scene_path
	print("Game menu set to return to: ", scene_path)

# ------------------------------------------------------------------------------
# FUTURE IMPLEMENTATION METHODS (PLACEHOLDER STUBS)
# ------------------------------------------------------------------------------

## Show confirmation dialog before destructive actions
## TODO: Implement confirmation dialogs for main menu/quit
func show_confirmation_dialog(message: String, callback: Callable):
	pass

## Check if there are unsaved changes that would be lost
## TODO: Implement save state checking
func has_unsaved_changes() -> bool:
	return false
