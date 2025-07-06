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
	
	# Debug: Check if the resume button exists and is properly connected
	print("🔍 Searching for resume button in pause menu...")
	var resume_button = get_node_or_null("MenuPanel/VBoxContainer/ResumeButton")
	
	# If not found, try alternative paths
	if not resume_button:
		resume_button = find_node_by_name(self, "ResumeButton")
	
	if not resume_button:
		resume_button = find_button_by_text(self, "Resume")
	
	if resume_button:
		print("✅ Resume button found: ", resume_button.name)
		print("   Button path: ", resume_button.get_path())
		print("   Button text: ", resume_button.text)
		print("   Button disabled: ", resume_button.disabled)
		print("   Button visible: ", resume_button.visible)
		print("   Button mouse_filter: ", resume_button.mouse_filter)
		
		# Check if signal is connected
		if resume_button.is_connected("pressed", _on_resume_button_pressed):
			print("✅ Resume button signal is connected")
		else:
			print("❌ Resume button signal is NOT connected!")
			print("   Connecting signal manually...")
			resume_button.pressed.connect(_on_resume_button_pressed)
			print("   Signal connected manually")
	else:
		print("❌ Resume button not found anywhere in pause menu!")
		print("🔍 Available buttons:")
		list_all_buttons(self)
	
	# Debug: Check the pause menu's own input handling
	print("🔍 PauseMenu input configuration:")
	print("   Mouse filter: ", mouse_filter)
	print("   Process mode: ", process_mode)
	print("   Visible: ", visible)
	print("   Input processing enabled for pause menu")
	
	# Check mouse filters of key components
	check_mouse_filters()

## Check mouse filters that might block input
func check_mouse_filters():
	print("🔍 Checking mouse filters in pause menu hierarchy...")
	check_node_mouse_filter(self, 0)

## Recursively check mouse filters
func check_node_mouse_filter(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	
	if node is Control:
		print(indent, node.name, " (", node.get_class(), ") - mouse_filter: ", node.mouse_filter)
		# Only warn about IGNORE on interactive elements, not labels
		if node.mouse_filter == Control.MOUSE_FILTER_IGNORE and not (node is Label):
			print(indent, "⚠️ WARNING: MOUSE_FILTER_IGNORE detected on interactive element!")
	
	if depth < 3:  # Limit depth
		for child in node.get_children():
			check_node_mouse_filter(child, depth + 1)

# ------------------------------------------------------------------------------
# INPUT HANDLING
# ------------------------------------------------------------------------------

## Handle input for pause menu (ESC to resume)
func _input(event):
	# Debug: Print all input events received by pause menu
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		print("🔍 PauseMenu _input: Key pressed: ", event.keycode, " (", key_name, ")")
	
	if event is InputEventMouseButton and event.pressed:
		print("🔍 PauseMenu _input: Mouse clicked at: ", event.position)
	
	if event.is_action_pressed("ui_cancel"):
		print("ESC pressed in pause menu - resuming game")
		_on_resume_button_pressed()

## Debug mouse input to see if clicks reach the pause menu
func _gui_input(event):
	if event is InputEventMouseButton:
		print("🔍 PauseMenu _gui_input: Mouse click detected")
		print("   Position: ", event.position)
		print("   Button: ", event.button_index)
		print("   Pressed: ", event.pressed)

# ------------------------------------------------------------------------------
# BUTTON SIGNAL HANDLERS
# ------------------------------------------------------------------------------

## Resume the game and return to previous scene
## @note: Closes the pause menu overlay to resume the game
func _on_resume_button_pressed() -> void:
	print("=== PAUSE MENU RESUME BUTTON CLICKED ===")
	print("📍 _on_resume_button_pressed() called at: ", Time.get_ticks_msec())
	print("PauseMenu: Resume button pressed")
	print("PauseMenu: Current scene tree valid: ", is_inside_tree())
	print("PauseMenu: Menu visible: ", visible)
	print("PauseMenu: Menu modulate: ", modulate)
	print("PauseMenu: Node path: ", get_path())
	
	# Debug: Check main scene manager
	if main_scene_manager:
		print("PauseMenu: main_scene_manager found: ", main_scene_manager.name)
		print("PauseMenu: Calling clear_menu_layer()")
		main_scene_manager.clear_menu_layer()
		print("PauseMenu: clear_menu_layer() called successfully")
	else:
		print("ERROR: main_scene_manager is null!")
		print("PauseMenu: Attempting to find Main scene manually...")
		var main_node = get_tree().root.get_node_or_null("Main")
		if main_node:
			print("PauseMenu: Found Main node manually: ", main_node.name)
			if main_node.has_method("clear_menu_layer"):
				print("PauseMenu: Calling clear_menu_layer on manual Main reference")
				main_node.clear_menu_layer()
			else:
				print("ERROR: Main node doesn't have clear_menu_layer method!")
		else:
			print("ERROR: Cannot find Main node at all!")
			# Last resort fallback: just free this menu
			print("PauseMenu: Fallback - freeing pause menu directly")
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

# ----------------------------------------------------------------------------
# HELPER FUNCTIONS FOR FINDING BUTTONS
# -----------------------------------------------------------------------------

## Find a node by name recursively
func find_node_by_name(node: Node, name: String) -> Node:
	if name.to_lower() in node.name.to_lower():
		return node
	
	for child in node.get_children():
		var result = find_node_by_name(child, name)
		if result:
			return result
	
	return null

## Find a button by text content recursively
func find_button_by_text(node: Node, text: String) -> Button:
	if node is Button and text.to_lower() in node.text.to_lower():
		return node
	
	for child in node.get_children():
		var result = find_button_by_text(child, text)
		if result:
			return result
	
	return null

## List all buttons in the menu for debugging
func list_all_buttons(node: Node, depth: int = 0):
	var indent = "  ".repeat(depth)
	
	if node is Button:
		print(indent, "BUTTON: ", node.name, " - '", node.text, "' (disabled: ", node.disabled, ", visible: ", node.visible, ")")
	
	for child in node.get_children():
		list_all_buttons(child, depth + 1)
