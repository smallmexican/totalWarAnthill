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
## Communicates with the Main scene manager to begin gameplay
## @note: This will load the Strategic Map scene (when implemented)
func _on_start_button_pressed() -> void:
	# Access the Main scene (root of the scene tree) and call start_game()
	# This follows the scene management pattern established in Main.gd
	get_tree().root.get_node("Main").start_game()

## Handles the "Settings" button press  
## Loads the settings menu through the Main scene manager
## @warning: SettingsMenu.tscn must exist at the specified path
func _on_settings_button_pressed() -> void:
	# Load the settings menu via Main scene manager
	# This maintains consistent scene switching through the central manager
	get_tree().root.get_node("Main").load_menu("res://scenes/ui/SettingsMenu.tscn")

## Handles the "Quit" button press
## Cleanly exits the application
## @note: This will trigger any cleanup code in _exit_tree() methods
func _on_quit_button_pressed() -> void:
	# Quit the entire application
	# Godot will handle cleanup of resources and saving if needed
	get_tree().quit()
