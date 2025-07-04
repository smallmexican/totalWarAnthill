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

# ------------------------------------------------------------------------------
# GAME SCENE MANAGEMENT METHODS  
# ------------------------------------------------------------------------------

## Start the main game by loading the Strategic Map
## Called from the main menu "Start Game" button
## @note: This begins the core RTS gameplay experience
func start_game():
	print("Main.gd: start_game() called")
	# Load the strategic map - the main overworld view
	# This is where players manage colonies and move armies
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
	
	# Clear any existing menu content since we're starting a game
	clear_menu_layer()
	print("Main.gd: MenuLayer cleared")

# ------------------------------------------------------------------------------
# PAUSE MENU MANAGEMENT METHODS
# ------------------------------------------------------------------------------

## Show pause menu as an overlay without clearing the current game scene
## @note: This keeps the game scene active in the background
func show_pause_menu():
	# Clear any existing menu content from MenuLayer (but keep game scene)
	clear_menu_layer()
	
	# Load and instantiate the pause menu
	var pause_menu = load("res://scenes/ui/PauseMenu.tscn").instantiate()
	
	# Set the previous scene for the pause menu to return to
	if current_game_scene:
		pause_menu.set_previous_scene(current_game_scene.scene_file_path)
	
	# Add it to the MenuLayer as an overlay
	$MenuLayer.add_child(pause_menu)

## Show game menu as an overlay without clearing the current game scene
## @note: This is the in-game menu accessed via ESC key during gameplay
func show_game_menu():
	print("Main.gd: show_game_menu() called")
	
	# Clear any existing menu content from MenuLayer (but keep game scene)
	clear_menu_layer()
	print("Main.gd: MenuLayer cleared")
	
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
	# Safely remove all children from the MenuLayer
	# queue_free() ensures cleanup happens at a safe time
	for child in $MenuLayer.get_children():
		child.queue_free()

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
