# ==============================================================================
# MAIN MENU CONTROLLER
# ==============================================================================
# Purpose: Controls the main menu UI and handles user interactions
# 
# USAGE:
# - Attach this script to the root Control node of MainMenu.tscn
# - Connect button signals to the corresponding methods below
# - Ensure the Main scene has the proper methods (start_game, load_menu)
#
# DEPENDENCIES:
# - Main.gd script with start_game() and load_menu() methods
# - MainMenu.tscn with properly named and connected buttons
# - SettingsMenu.tscn scene (referenced but not yet created)
#
# BUTTON CONNECTIONS REQUIRED:
# - StartButton.pressed -> _on_start_button_pressed()
# - SettingsButton.pressed -> _on_settings_button_pressed()  
# - QuitButton.pressed -> _on_quit_button_pressed()
# ==============================================================================

extends Control

# ------------------------------------------------------------------------------
# BUTTON SIGNAL HANDLERS
# ------------------------------------------------------------------------------

## Handles the "Start Game" button press
## Communicates with the Main scene manager to show game selection
## @note: This will load the Game Selection menu to choose Campaign vs Skirmish
func _on_start_button_pressed() -> void:
	print("MainMenu: Start Game button pressed")
	# Access the Main scene (root of the scene tree) and load game selection menu
	# This follows the scene management pattern established in Main.gd
	var main_scene = get_tree().root.get_node("Main")
	if main_scene:
		print("MainMenu: Found Main scene, loading Game Selection menu")
		main_scene.load_menu("res://scenes/ui/GameSelectionMenu.tscn")
	else:
		print("MainMenu: ERROR - Main scene not found!")

## Handles the "Settings" button press  
## Loads the settings menu through the Main scene manager
## @warning: SettingsMenu.tscn must exist at the specified path
func _on_settings_button_pressed() -> void:
	# Load the settings menu via Main scene manager
	# This maintains consistent scene switching through the central manager
	get_tree().root.get_node("Main").show_settings_menu()

## Handles the "Quit" button press
## Cleanly exits the application
## @note: This will trigger any cleanup code in _exit_tree() methods
func _on_quit_button_pressed() -> void:
	# Quit the entire application
	# Godot will handle cleanup of resources and saving if needed
	get_tree().quit()
