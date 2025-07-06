# ==============================================================================
# MAIN SCENE MANAGER
# ==============================================================================
# Purpose: Central hub for managing all scene transitions and game flow
# 
# ARCHITECTURE:
# This is the root scene of the entire game. It manages two main layers:
# - MenuLayer (Control): Holds UI scenes like MainMenu, SettingsMenu, PauseMenu
# - GameLayer (Node2D): Holds gameplay scenes like StrategicMap, ColonyView, BattleScene
#
# USAGE:
# 1. Set this scene (Main.tscn) as your project's main scene in Project Settings
# 2. All scene transitions should go through this manager
# 3. UI scenes call methods on this script to switch between game modes
# 4. Only one game scene should be active at a time (automatic cleanup)
#
# SCENE HIERARCHY:
# Main (Node)
# ├── MenuLayer (Control)     ← UI scenes instantiated here
# └── GameLayer (Node2D)      ← Game scenes instantiated here
#
# DEPENDENCIES:
# - MainMenu.tscn scene for initial menu
# - StrategicMap.tscn scene for main gameplay (to be created)
# - Various menu scenes (SettingsMenu.tscn, etc.)
#
# FUTURE ENHANCEMENTS:
# - Add fade transitions between scenes
# - Implement scene loading with progress bars for large scenes
# - Add audio management for scene-specific music
# - Integrate with GameState singleton for persistent data
# ==============================================================================

# res://scripts/Main.gd
extends Node

# ------------------------------------------------------------------------------
# MEMBER VARIABLES
# ------------------------------------------------------------------------------

## Reference to the currently active game scene
## Used for cleanup and scene management
## @note: Only game scenes (not UI menus) are tracked here
var current_game_scene: Node = null

# ------------------------------------------------------------------------------
# GODOT LIFECYCLE METHODS
# ------------------------------------------------------------------------------

## Initialize the game by loading the main menu
## This is called automatically when the scene is ready
func _ready():
	# Start the game by loading the main menu
	# This gives players the initial interface to interact with
	load_menu("res://ui/MainMenu.tscn")

# ------------------------------------------------------------------------------
# MENU MANAGEMENT METHODS
# ------------------------------------------------------------------------------

## Load a UI menu scene into the MenuLayer
## @param path: String path to the .tscn file to load
## @note: This clears any existing UI and game content and loads the new menu
## @example: load_menu("res://ui/SettingsMenu.tscn")
func load_menu(path: String):
	# Clear any existing menu content from MenuLayer
	clear_menu_layer()
	
	# Also clear any game content when returning to main menu
	clear_game_layer()
	
	# Load and instantiate the new menu scene
	var menu = load(path).instantiate()
	
	# Add it to the MenuLayer for display
	$MenuLayer.add_child(menu)
	
	# Enable input blocking when menu is present
	$MenuLayer.mouse_filter = Control.MOUSE_FILTER_STOP
	print("Main.gd: MenuLayer mouse_filter set to STOP (menu loaded)")

# ------------------------------------------------------------------------------
# GAME SCENE MANAGEMENT METHODS  
# ------------------------------------------------------------------------------

## Start the main game by loading the Strategic Map (direct access)
## @note: This bypasses the Game Selection menu for direct Skirmish mode
## @deprecated: Consider using Game Selection menu instead for better UX
func start_game():
	print("Main.gd: start_game() called (direct Strategic Map)")
	# Load the strategic map directly - used for direct game access
	# Consider using Game Selection menu for better user experience
	load_game_scene("res://scenes/game/StrategicMap.tscn")

## Load a gameplay scene into the GameLayer
## @param path: String path to the .tscn file to load
## @note: This handles all gameplay scenes (Strategic Map, Colony View, Battle)
## @example: load_game_scene("res://scenes/game/ColonyView.tscn")
func load_game_scene(path: String):
	print("Main.gd: load_game_scene() called with path: ", path)
	
	# Clear any existing game scene
	clear_game_layer()
	print("Main.gd: GameLayer cleared")
	
	# Load and instantiate the new game scene
	print("Main.gd: Loading scene from: ", path)
	var game_scene_resource = load(path)
	if game_scene_resource == null:
		print("ERROR: Failed to load scene: ", path)
		return
	
	current_game_scene = game_scene_resource.instantiate()
	if current_game_scene == null:
		print("ERROR: Failed to instantiate scene: ", path)
		return
	
	print("Main.gd: Scene instantiated successfully: ", current_game_scene.name)
	
	# Add it to the GameLayer for gameplay
	$GameLayer.add_child(current_game_scene)
	print("Main.gd: Scene added to GameLayer")
	
	# CRITICAL: We can't set a child scene as current_scene in Godot
	# Instead, ensure the scene has proper focus and input handling
	print("Main.gd: Ensuring proper input focus for: ", current_game_scene.name)
	current_game_scene.grab_focus()
	if current_game_scene.has_method("set_process_input"):
		current_game_scene.set_process_input(true)
		current_game_scene.set_process_unhandled_input(true)
		current_game_scene.set_process_unhandled_key_input(true)
	print("Main.gd: Input focus and processing enabled for: ", current_game_scene.name)
	
	# Clear any existing menu content since we're starting a game
	clear_menu_layer()
	print("Main.gd: MenuLayer cleared")
	
	# Disable input blocking when no menu is present
	$MenuLayer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	print("Main.gd: MenuLayer mouse_filter set to IGNORE (game scene active)")

# ------------------------------------------------------------------------------
# PAUSE MENU MANAGEMENT METHODS
# ------------------------------------------------------------------------------

## Show pause menu as an overlay without clearing the current game scene
## @note: This keeps the game scene active in the background
func show_pause_menu():
	print("Main.gd: show_pause_menu() called")
	
	# Clear any existing menu content from MenuLayer (but keep game scene)
	# DON'T use clear_menu_layer() as it sets up deferred mouse_filter IGNORE
	print("Main.gd: Clearing existing menus manually...")
	for child in $MenuLayer.get_children():
		print("Main.gd: Removing existing menu: ", child.name)
		child.queue_free()
	
	# Load and instantiate the pause menu
	var pause_menu = load("res://scenes/ui/PauseMenu.tscn").instantiate()
	
	# Set the previous scene for the pause menu to return to
	if current_game_scene:
		pause_menu.set_previous_scene(current_game_scene.scene_file_path)
	
	# Add it to the MenuLayer as an overlay
	$MenuLayer.add_child(pause_menu)
	
	# CRITICAL: Enable input blocking when menu is present (don't defer this!)
	$MenuLayer.mouse_filter = Control.MOUSE_FILTER_STOP
	print("Main.gd: MenuLayer mouse_filter set to STOP (pause menu loaded)")

## Show game menu as an overlay without clearing the current game scene
## @note: This is the in-game menu accessed via ESC key during gameplay
func show_game_menu():
	print("Main.gd: show_game_menu() called")
	
	# Clear any existing menu content from MenuLayer (but keep game scene)
	# DON'T use clear_menu_layer() as it sets up deferred mouse_filter IGNORE
	print("Main.gd: Clearing existing menus manually...")
	for child in $MenuLayer.get_children():
		print("Main.gd: Removing existing menu: ", child.name)
		child.queue_free()
	
	# Load and instantiate the game menu
	print("Main.gd: Loading GameMenu.tscn...")
	var game_menu_scene = load("res://scenes/ui/GameMenu.tscn")
	if game_menu_scene == null:
		print("ERROR: Failed to load GameMenu.tscn!")
		return
	
	var game_menu = game_menu_scene.instantiate()
	if game_menu == null:
		print("ERROR: Failed to instantiate GameMenu!")
		return
	
	print("Main.gd: GameMenu instantiated successfully")
	
	# Set the previous scene for the game menu to return to
	if current_game_scene:
		game_menu.set_previous_scene(current_game_scene.scene_file_path)
		print("Main.gd: Set previous scene to: ", current_game_scene.scene_file_path)
	
	# Add it to the MenuLayer as an overlay
	$MenuLayer.add_child(game_menu)
	print("Main.gd: GameMenu added to MenuLayer")
	
	# CRITICAL: Enable input blocking when menu is present (don't defer this!)
	$MenuLayer.mouse_filter = Control.MOUSE_FILTER_STOP
	print("Main.gd: MenuLayer mouse_filter set to STOP (game menu loaded)")

## Show settings menu as an overlay
## @param calling_menu: String path to the menu that opened settings
## @param in_game: bool whether settings was opened from in-game
## @note: Can be called from main menu, pause menu, or game menu
func show_settings_menu(calling_menu: String = "res://ui/MainMenu.tscn", in_game: bool = false):
	# Clear any existing menu content from MenuLayer
	clear_menu_layer()
	
	# Load and instantiate the settings menu
	var settings_menu = load("res://scenes/ui/SettingsMenu.tscn").instantiate()
	
	# Set the calling context for proper back navigation
	settings_menu.set_calling_context(calling_menu, in_game)
	
	# Add it to the MenuLayer as an overlay
	$MenuLayer.add_child(settings_menu)
	
	# Enable input blocking when menu is present
	$MenuLayer.mouse_filter = Control.MOUSE_FILTER_STOP
	print("Main.gd: MenuLayer mouse_filter set to STOP (settings menu loaded)")

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------

## Clean up the GameLayer by removing all child scenes
## @note: Uses queue_free() for safe cleanup during the next frame
## @warning: This will destroy any unsaved game state in the current scene
func clear_game_layer():
	# Safely remove all children from the GameLayer
	# queue_free() ensures cleanup happens at a safe time
	for child in $GameLayer.get_children():
		child.queue_free()

## Clean up the MenuLayer by removing all child scenes
## @note: Uses queue_free() for safe cleanup during the next frame
func clear_menu_layer():
	print("=== MAIN: CLEAR_MENU_LAYER CALLED ===")
	print("Main.gd: clear_menu_layer() called")
	
	# Check if MenuLayer exists
	var menu_layer = $MenuLayer
	if not menu_layer:
		print("ERROR: MenuLayer not found!")
		return
	
	print("Main.gd: MenuLayer found with ", menu_layer.get_child_count(), " children")
	
	# Safely remove all children from the MenuLayer
	# queue_free() ensures cleanup happens at a safe time
	for child in menu_layer.get_children():
		print("Main.gd: Freeing child: ", child.name, " (", child.get_class(), ")")
		child.queue_free()
	
	# Defer the mouse filter change until after nodes are actually freed
	# This prevents timing issues where menu nodes might still handle input
	call_deferred("_set_menu_layer_ignore")
	print("Main.gd: MenuLayer cleared, mouse_filter change deferred")

## Set MenuLayer mouse filter to IGNORE after menu nodes are freed
func _set_menu_layer_ignore():
	print("=== MAIN: SET_MENU_LAYER_IGNORE CALLED ===")
	var menu_layer = $MenuLayer
	if menu_layer:
		# Only set to IGNORE if there are no menu children
		# If there are children, a new menu was loaded and needs STOP
		if menu_layer.get_child_count() == 0:
			menu_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
			print("Main.gd: MenuLayer mouse_filter set to IGNORE (no menus active)")
		else:
			print("Main.gd: MenuLayer has children - keeping STOP filter for menu input")
		
		print("Main.gd: MenuLayer children remaining: ", menu_layer.get_child_count())
		
		# Double-check that game layer is receiving input when no menus are active
		if menu_layer.get_child_count() == 0:
			var game_layer = $GameLayer
			if game_layer:
				print("Main.gd: GameLayer mouse_filter: ", game_layer.mouse_filter)
				print("Main.gd: GameLayer children: ", game_layer.get_child_count())
				for child in game_layer.get_children():
					print("   - ", child.name, " (", child.get_class(), ")")
					if child.has_method("grab_focus"):
						print("     Attempting to restore focus to: ", child.name)
						child.grab_focus()
					
					# CRITICAL FIX: We can't set a child scene as current_scene in Godot
					# Instead, ensure the scene has proper focus and input handling
					if child.name == "StrategicMap" or child.name == "ColonyView":
						print("     Ensuring proper input focus for: ", child.name)
						# Grab focus to ensure input events reach this scene
						child.grab_focus()
						# Make sure input processing is enabled
						if child.has_method("set_process_input"):
							child.set_process_input(true)
							child.set_process_unhandled_input(true)
							child.set_process_unhandled_key_input(true)
						print("     Input focus and processing restored for: ", child.name)
	else:
		print("ERROR: MenuLayer not found in _set_menu_layer_ignore")

# ------------------------------------------------------------------------------
# FUTURE METHODS (TO BE IMPLEMENTED)
# ------------------------------------------------------------------------------

## TODO: Add transition effects between scenes
# func transition_to_scene(path: String, transition_type: String = "fade"):
#     # Implement fade, slide, or other transition effects

## TODO: Add scene preloading for better performance  
# func preload_scene(path: String):
#     # Preload heavy scenes in the background

## TODO: Add pause menu functionality
# func show_pause_menu():
#     # Show pause menu without clearing the current game scene

## TODO: Add save/load integration
# func load_saved_game(save_file: String):
#     # Load a specific save file and restore game state
