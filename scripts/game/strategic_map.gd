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

extends Control

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
@onready var species_stats_bar: Control = $UILayer/SpeciesStatsBar

## Reference to the input debug label
@onready var input_debug_label: Label = $UILayer/InputDebugLabel

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
	
	# Configure UILayer to not block input
	var ui_layer = $UILayer
	if ui_layer:
		# CanvasLayers don't directly have mouse_filter, but we need to ensure they don't process input
		ui_layer.process_mode = Node.PROCESS_MODE_INHERIT  # Allow normal processing
		print("✅ UILayer configured for proper input handling")
	
	# Ensure species stats bar doesn't block input
	if species_stats_bar:
		# Set the main bar to IGNORE
		species_stats_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Also ensure all child nodes don't block input - be very aggressive about this
		_set_mouse_filter_recursive(species_stats_bar, Control.MOUSE_FILTER_IGNORE)
		print("✅ Species stats bar and ALL children set to IGNORE mouse input")
	
	# Verify colony button exists and is properly configured
	var colony_button = $UILayer/ColonyButton
	if colony_button:
		print("✅ Colony button found and ready")
		print("   Position: ", colony_button.position)
		print("   Z-Index: ", colony_button.z_index)
		print("   Mouse Filter: ", colony_button.mouse_filter)
	else:
		print("❌ Colony button not found at UILayer/ColonyButton!")
	
	# Display placeholder message
	print("=== STRATEGIC MAP LOADED ===")
	print("This is a placeholder scene.")
	print("Controls:")
	print("  ESC - Show Game Menu (Save/Load/Settings/Main Menu)")
	print("  C - Enter Colony View")
	print("  P - Show Pause Menu")
	print("  Click Colony Button - Enter Colony View")
	
	# Debug: Check if this scene is the current scene
	print("🔍 DEBUGGING INFO:")
	print("   Current scene: ", get_tree().current_scene.name if get_tree().current_scene else "NONE")
	print("   This scene name: ", self.name)
	print("   Scene file path: ", self.scene_file_path if self.scene_file_path else "NONE")
	print("   Process mode: ", self.process_mode)
	
	# Force enable input processing in multiple ways
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	set_process_input(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	print("   Process mode set to ALWAYS and all input processing enabled")
	
	# Control-specific input setup
	mouse_filter = Control.MOUSE_FILTER_STOP  # Allow this control to receive input
	focus_mode = Control.FOCUS_ALL  # Allow this control to receive focus
	print("   Control input configuration set")
	
	# Try to grab focus
	grab_focus()
	print("   Attempted to grab focus")
	
	# Call deferred to ensure everything is set up properly
	call_deferred("_post_ready_setup")

## Post-ready setup to ensure input is working
func _post_ready_setup():
	print("🔍 POST-READY SETUP:")
	print("   Scene is in tree: ", is_inside_tree())
	print("   Current scene root: ", get_tree().current_scene.name if get_tree().current_scene else "NONE")
	
	# CRITICAL: Check if this scene is properly set as current scene
	var tree = get_tree()
	if tree.current_scene != self:
		print("⚠️  WARNING: This scene is NOT the current scene!")
		print("   Setting this scene as current scene...")
		tree.current_scene = self
		print("   Current scene now: ", tree.current_scene.name if tree.current_scene else "NONE")
	
	# Additional input configuration
	var viewport = get_viewport()
	if viewport:
		print("   Viewport found: ", viewport.name)
		print("   GUI input disabled: ", viewport.gui_disable_input)
		
		# Make sure viewport isn't disabling input
		viewport.gui_disable_input = false
		print("   GUI input enabled")
		
		# Force viewport to handle input
		viewport.handle_input_locally = true
		print("   Viewport input handling enabled")
	
	# Check if there are any overlapping nodes that might be blocking input
	var main_scene = get_tree().root.get_node_or_null("Main")
	if main_scene:
		var menu_layer = main_scene.get_node_or_null("MenuLayer")
		if menu_layer:
			print("   MenuLayer found - filter: ", menu_layer.mouse_filter)
			# DON'T disable MenuLayer - it needs to be able to process menu input!
			# Only set to IGNORE when no menus are active (handled by Main.gd)
			print("   MenuLayer input processing preserved for menu functionality")
	
	# Test if we can detect any input at all
	print("   Input processing enabled, waiting for keyboard input...")
	
	# Force focus and input capability
	grab_focus()
	print("   Focus grabbed in post-ready")
	print("   Has focus: ", has_focus())
	print("   Focus mode: ", focus_mode)
	print("   Mouse filter: ", mouse_filter)
	
	# Start a timer to periodically check input status
	call_deferred("_start_input_monitoring")

## Start monitoring input status
func _start_input_monitoring():
	print("🔍 Starting input monitoring...")
	
	# Create a timer to check input state every few seconds
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.timeout.connect(_check_input_status)
	timer.autostart = true
	add_child(timer)
	
	print("   Input monitoring started - will check every 3 seconds")
	
	# REMOVED: Direct viewport input approach (gui_input signal doesn't exist)
	# The viewport input approach isn't needed since we have proper focus now

## Check input status periodically
func _check_input_status():
	print("🔍 INPUT STATUS CHECK:")
	print("   This scene: ", self.name)
	print("   Has focus: ", has_focus())
	print("   Process input enabled: ", is_processing_input())
	print("   Process unhandled input enabled: ", is_processing_unhandled_input())
	print("   Process unhandled key input enabled: ", is_processing_unhandled_key_input())
	
	# CRITICAL FIX: Auto-regrab focus if it's been lost
	if not has_focus():
		print("⚠️  Focus lost - regrabbing focus automatically")
		grab_focus()
		if input_debug_label:
			input_debug_label.text = "Auto-regrabbed focus at " + str(Time.get_ticks_msec())
	
	# Try to detect if any keys are currently pressed
	if Input.is_anything_pressed():
		print("   Something is currently pressed")
	else:
		print("   Nothing is currently pressed")
	
	# Also check specific keys manually
	if Input.is_key_pressed(KEY_ESCAPE):
		print("   ESC key is pressed (via Input.is_key_pressed)")
		if input_debug_label:
			input_debug_label.text = "ESC detected via polling!"
		show_game_menu()
	
	if Input.is_key_pressed(KEY_C):
		print("   C key is pressed (via Input.is_key_pressed)")
		if input_debug_label:
			input_debug_label.text = "C detected via polling!"
		enter_colony_view()
	
	if Input.is_key_pressed(KEY_P):
		print("   P key is pressed (via Input.is_key_pressed)")
		if input_debug_label:
			input_debug_label.text = "P detected via polling!"
		show_pause_menu()

## Primary input handler - processes ALL input events first
func _input(event):
	# Debug: Print ALL input events to see what's happening
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		print("🔍 _input: Key pressed: ", event.keycode, " (", key_name, ")")
		
		# Update debug label IMMEDIATELY
		if input_debug_label:
			input_debug_label.text = "DETECTED: " + key_name + " at " + str(Time.get_ticks_msec())
		
		# Handle ESC key immediately in _input
		if event.keycode == KEY_ESCAPE:
			print("🔍 _input: ESC key detected - showing game menu")
			if input_debug_label:
				input_debug_label.text = "ESC DETECTED in _input - Showing game menu"
			# Accept the event to prevent further processing
			accept_event()
			get_viewport().set_input_as_handled()
			show_game_menu()
			return
		
		# Handle C key immediately in _input
		if event.keycode == KEY_C:
			print("🔍 _input: C key detected - entering colony view")
			if input_debug_label:
				input_debug_label.text = "C DETECTED in _input - Entering colony view"
			# Accept the event to prevent further processing
			accept_event()
			get_viewport().set_input_as_handled()
			enter_colony_view()
			return
		
		# Handle P key immediately in _input
		if event.keycode == KEY_P:
			print("🔍 _input: P key detected - showing pause menu")
			if input_debug_label:
				input_debug_label.text = "P DETECTED in _input - Showing pause menu"
			# Accept the event to prevent further processing
			accept_event()
			get_viewport().set_input_as_handled()
			show_pause_menu()
			return

## Additional input handler for keys that might be missed
func _gui_input(event):
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		print("🔍 _gui_input: Key pressed: ", event.keycode, " (", key_name, ")")
		
		if input_debug_label:
			input_debug_label.text = "GUI INPUT: " + key_name + " at " + str(Time.get_ticks_msec())
	
	# Handle mouse clicks in GUI input to maintain focus
	if event is InputEventMouseButton and event.pressed:
		print("🔍 _gui_input: Mouse click detected - maintaining focus")
		grab_focus()  # Always grab focus on mouse click
		if input_debug_label:
			input_debug_label.text = "Focus maintained via _gui_input"

## Final fallback input handler for unhandled input
func _unhandled_key_input(event):
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		print("🔍 _unhandled_key_input: Key pressed: ", event.keycode, " (", key_name, ")")
		
		if input_debug_label:
			input_debug_label.text = "UNHANDLED KEY: " + key_name + " at " + str(Time.get_ticks_msec())
		
		# Handle keys here as final fallback
		match event.keycode:
			KEY_ESCAPE:
				print("🔍 _unhandled_key_input: ESC key - showing game menu")
				accept_event()
				show_game_menu()
			KEY_C:
				print("🔍 _unhandled_key_input: C key - entering colony view")
				accept_event()
				enter_colony_view()
			KEY_P:
				print("🔍 _unhandled_key_input: P key - showing pause menu")
				accept_event()
				show_pause_menu()

## Alternative input handler that gets called after UI elements
func _unhandled_input(event):
	# Debug: Print all key presses to help diagnose issues
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		print("🔍 _unhandled_input: Key pressed: ", event.keycode, " (", key_name, ")")
		
		# Update debug label
		if input_debug_label:
			input_debug_label.text = "Last key pressed: " + key_name + " at " + str(Time.get_ticks_msec())
	
	# Return to main menu on ESC (ui_cancel)
	if event.is_action_pressed("ui_cancel"):
		print("🔍 _unhandled_input: ESC key detected (ui_cancel) - showing game menu")
		if input_debug_label:
			input_debug_label.text = "ESC DETECTED - Showing game menu"
		get_viewport().set_input_as_handled()
		show_game_menu()
		return
	
	# Alternative ESC key detection (direct keycode check)
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		print("🔍 _unhandled_input: ESC key detected (direct) - showing game menu")
		if input_debug_label:
			input_debug_label.text = "ESC DETECTED (direct) - Showing game menu"
		get_viewport().set_input_as_handled()
		show_game_menu()
		return
	
	# Enter colony view on C key
	if event is InputEventKey and event.keycode == KEY_C and event.pressed:
		print("🔍 _unhandled_input: C key detected - entering colony view")
		if input_debug_label:
			input_debug_label.text = "C DETECTED - Entering colony view"
		get_viewport().set_input_as_handled()
		enter_colony_view()
		return
	
	# Show pause menu on P key
	if event is InputEventKey and event.keycode == KEY_P and event.pressed:
		print("🔍 _unhandled_input: P key detected - showing pause menu")
		if input_debug_label:
			input_debug_label.text = "P DETECTED - Showing pause menu"
		get_viewport().set_input_as_handled()
		show_pause_menu()
		return
	
	## Debug mouse input to see if ANY clicks are detected
	if event is InputEventMouseButton and event.pressed:
		print("Mouse click detected at: ", event.position)
		print("Button: ", event.button_index)
		
		# CRITICAL FIX: Always grab focus back after any mouse click
		# This prevents the scene from losing keyboard input capability
		if not has_focus():
			print("🔍 Regrabbing focus after mouse click")
			grab_focus()
			if input_debug_label:
				input_debug_label.text = "Focus regrabbed after click"

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
# HELPER FUNCTIONS
# ------------------------------------------------------------------------------

## Recursively set mouse filter for a node and all its children
func _set_mouse_filter_recursive(node: Node, filter: Control.MouseFilter):
	if node is Control:
		node.mouse_filter = filter
	
	for child in node.get_children():
		_set_mouse_filter_recursive(child, filter)

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
