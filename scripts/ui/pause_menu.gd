# ==============================================================================
# PAUSE MENU - PLACEHOLDER
# ==============================================================================
# Purpose: In-game pause menu accessible during gameplay
# 
# CURRENT STATUS: PLACEHOLDER - Basic functionality for testing
# 
# FEATURES:
# - Resume game functionality
# - Access to settings menu
# - Return to main menu option
# - Quit game option
#
# USAGE:
# - Accessed by pressing P in any gameplay scene
# - Can be accessed from Strategic Map or Colony View
# - Resume returns to the previous gameplay scene
#
# TODO: Add game state preservation and better integration
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

## Initialize the pause menu
func _ready():
	# Get reference to the main scene manager
	main_scene_manager = get_tree().root.get_node("Main")
	
	# Display pause menu information
	print("=== PAUSE MENU LOADED ===")
	print("Game is paused. Use menu options to continue.")

# ------------------------------------------------------------------------------
# INPUT HANDLING
# ------------------------------------------------------------------------------

## Handle input for pause menu (ESC to resume)
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("ESC pressed in pause menu - resuming game")
		_on_resume_button_pressed()

# ------------------------------------------------------------------------------
# BUTTON SIGNAL HANDLERS
# ------------------------------------------------------------------------------

## Resume the game and return to previous scene
## @note: Closes the pause menu overlay to resume the game
func _on_resume_button_pressed() -> void:
	print("Resuming game...")
	# Simply close the pause menu to resume the game
	# The game scene remains active in the background
	queue_free()

## Open the settings menu
## @note: Settings menu is referenced but not yet implemented
func _on_settings_button_pressed() -> void:
	print("Opening settings from pause menu...")
	main_scene_manager.load_menu("res://scenes/ui/SettingsMenu.tscn")

## Return to the main menu
## @warning: This will lose any unsaved game progress
func _on_main_menu_button_pressed() -> void:
	print("Returning to main menu...")
	# TODO: Add confirmation dialog for unsaved progress
	main_scene_manager.load_menu("res://ui/MainMenu.tscn")

## Quit the game entirely
## @warning: This will lose any unsaved game progress
func _on_quit_button_pressed() -> void:
	print("Quitting game...")
	# TODO: Add confirmation dialog and save prompt
	get_tree().quit()

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------

## Set which scene to return to when resuming
## @param scene_path: String path to the scene to return to
## TODO: This should be called automatically when pause menu is opened
func set_previous_scene(scene_path: String):
	previous_scene_path = scene_path
	print("Previous scene set to: ", scene_path)

# ------------------------------------------------------------------------------
# FUTURE IMPLEMENTATION METHODS (PLACEHOLDER STUBS)
# ------------------------------------------------------------------------------

## Save the current game state before showing pause menu
## TODO: Integrate with save system
func save_current_state():
	pass

## Show confirmation dialog before destructive actions
## TODO: Implement confirmation system
func show_confirmation_dialog(message: String, callback: Callable):
	pass
