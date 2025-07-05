# ==============================================================================
# GAMEPLAY INTEGRATION - Connect Menu System with Core Classes
# ==============================================================================
# Purpose: Bridge between your existing menu system and the new core gameplay
#          classes, handling the transition from SkirmishSetupMenu to actual gameplay
# 
# This script handles:
# - Receiving configuration from SkirmishSetupMenu
# - Initializing GameState with match configuration
# - Loading appropriate scenes with live gameplay
# - Updating placeholder scenes to use real gameplay systems
#
# Usage:
# - Called from SkirmishSetupMenu when "Start Match" is pressed
# - Replaces placeholder functionality with real gameplay
# - Manages scene transitions and game initialization
# ==============================================================================

extends Node

# ==============================================================================
# SIGNALS
# ==============================================================================

signal gameplay_initialized(config: Dictionary)
signal scene_transition_started(from_scene: String, to_scene: String)
signal scene_transition_completed(scene_name: String)

# ==============================================================================
# INTEGRATION FUNCTIONS
# ==============================================================================

## Initialize gameplay with configuration from SkirmishSetupMenu
static func start_skirmish_match(config: Dictionary):
	print("🚀 Starting skirmish match with configuration:")
	print("   Player Species: ", config.get("player_species", "Unknown"))
	print("   Opponent Species: ", config.get("opponent_species", "Unknown"))
	print("   Opponent Difficulty: ", config.get("opponent_difficulty", "Unknown"))
	print("   Map: ", config.get("map", "Unknown"))
	
	# Initialize GameState
	if not has_singleton("GameState"):
		setup_game_state_singleton()
	
	var game_state = get_singleton("GameState")
	game_state.initialize_match(config)
	
	# Load Strategic Map with live gameplay
	load_strategic_map_with_gameplay(config)

## Setup GameState as singleton if not already configured
static func setup_game_state_singleton():
	# Add GameState to autoloads programmatically
	var game_state = preload("res://scripts/core/systems/game_state.gd").new()
	game_state.name = "GameState"
	
	# Add to scene tree as singleton
	var main_tree = Engine.get_main_loop() as SceneTree
	main_tree.root.add_child(game_state)
	
	# Also setup SpeciesManager if not present
	if not has_singleton("SpeciesManager"):
		setup_species_manager_singleton()
	
	print("🎮 GameState singleton created")

## Setup SpeciesManager as singleton
static func setup_species_manager_singleton():
	var species_manager = preload("res://scripts/core/systems/species_manager.gd").new()
	species_manager.name = "SpeciesManager"
	
	var main_tree = Engine.get_main_loop() as SceneTree
	main_tree.root.add_child(species_manager)
	
	print("🧬 SpeciesManager singleton created")

## Load Strategic Map scene with live gameplay integration
static func load_strategic_map_with_gameplay(config: Dictionary):
	print("🗺️ Loading Strategic Map with live gameplay...")
	
	# Load the Strategic Map scene
	var strategic_map_scene = preload("res://scenes/game/StrategicMap.tscn")
	var strategic_map = strategic_map_scene.instantiate()
	
	# Initialize with gameplay systems
	if strategic_map.has_method("initialize_with_gameplay"):
		strategic_map.initialize_with_gameplay(config)
	
	# Switch to Strategic Map
	var main = get_main_scene()
	if main:
		main.load_scene("StrategicMap", strategic_map)

## Update existing placeholder scenes to use real gameplay
static func upgrade_placeholder_scenes():
	print("⬆️ Upgrading placeholder scenes to use real gameplay...")
	
	# This function would update your existing scene scripts
	# to integrate with the new core classes
	
	upgrade_strategic_map_scene()
	upgrade_colony_view_scene()

## Upgrade Strategic Map to use real colonies and resources
static func upgrade_strategic_map_scene():
	# Update StrategicMap.gd to show real colonies and resources
	var strategic_map_script_path = "res://scripts/game/strategic_map.gd"
	
	print("📝 Strategic Map will be updated to show:")
	print("   - Real colony locations and info")
	print("   - Resource node positions")
	print("   - Territory boundaries")
	print("   - AI colony movements")

## Upgrade Colony View to use real ant and building management
static func upgrade_colony_view_scene():
	# Update ColonyView.gd to manage real ants and buildings
	var colony_view_script_path = "res://scripts/game/colony_view.gd"
	
	print("📝 Colony View will be updated to show:")
	print("   - Real ant sprites and behavior")
	print("   - Actual building construction")
	print("   - Live resource counts")
	print("   - Worker task assignments")

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

## Check if singleton exists
static func has_singleton(singleton_name: String) -> bool:
	return Engine.has_singleton(singleton_name)

## Get singleton instance
static func get_singleton(singleton_name: String) -> Node:
	return Engine.get_singleton(singleton_name)

## Get main scene reference
static func get_main_scene() -> Node:
	var main_tree = Engine.get_main_loop() as SceneTree
	return main_tree.current_scene

# ==============================================================================
# SCENE INTEGRATION EXAMPLES
# ==============================================================================

## Example: How to integrate Strategic Map with real colonies
static func example_strategic_map_integration():
	"""
	Add this to your StrategicMap.gd script:
	
	# In _ready():
	func _ready():
		# ... existing code ...
		
		# Connect to GameState for live updates
		if GameState:
			GameState.colony_created.connect(_on_colony_created)
			GameState.resource_node_discovered.connect(_on_resource_discovered)
			update_map_display()
	
	# Show real colonies on map
	func update_map_display():
		for colony in GameState.all_colonies:
			create_colony_marker(colony)
		
		for resource in GameState.world_resources:
			create_resource_marker(resource)
	
	func create_colony_marker(colony: Colony):
		var marker = ColorRect.new()
		marker.size = Vector2(20, 20)
		marker.position = colony.global_position
		marker.color = Color.BLUE if colony.player_controlled else Color.RED
		add_child(marker)
	"""
	pass

## Example: How to integrate Colony View with real ant management
static func example_colony_view_integration():
	"""
	Add this to your ColonyView.gd script:
	
	# Connect to active colony
	var active_colony: Colony
	
	func initialize_with_colony(colony: Colony):
		active_colony = colony
		colony.ant_spawned.connect(_on_ant_spawned)
		colony.building_constructed.connect(_on_building_constructed)
		colony.resource_changed.connect(_on_resource_changed)
		update_colony_display()
	
	func update_colony_display():
		update_population_display()
		update_resource_display()
		update_building_display()
	
	func _on_manage_button_pressed():
		# Instead of placeholder, use real ant management
		var idle_ants = active_colony.get_idle_ants()
		for ant in idle_ants:
			if ant.ant_type == "Worker":
				var gather_task = active_colony.create_gather_task(Vector2(100, 100))
				ant.assign_task(gather_task)
	"""
	pass

# ==============================================================================
# INTEGRATION CHECKLIST
# ==============================================================================

## Print integration checklist for development
static func print_integration_checklist():
	print("\n🔧 INTEGRATION CHECKLIST:")
	print("✅ 1. Core classes implemented (Ant, Colony, Building, Resource, Task)")
	print("✅ 2. GameState system ready")
	print("✅ 3. SpeciesManager and SpeciesData system ready")
	print("⚠️  4. Update SkirmishSetupMenu to call GameplayIntegration.start_skirmish_match()")
	print("⚠️  5. Update StrategicMap.gd to display real colonies and resources")
	print("⚠️  6. Update ColonyView.gd to manage real ants and buildings")
	print("⚠️  7. Add GameState and SpeciesManager to project.godot autoloads")
	print("⚠️  8. Create visual assets for ants and buildings")
	print("⚠️  9. Test save/load functionality")
	print("⚠️  10. Implement AI decision making")
	print("⚠️  11. Add win/lose conditions to UI")
	print("\n📝 Next steps:")
	print("   1. Update your SkirmishSetupMenu.gd '_on_start_match_button_pressed()' function")
	print("   2. Add GameState and SpeciesManager to autoloads in project.godot")
	print("   3. Test the integration with your existing menu system")

# ==============================================================================
# AUTOLOAD SETUP INSTRUCTIONS
# ==============================================================================

## Instructions for setting up autoloads
static func print_autoload_instructions():
	print("\n🔧 AUTOLOAD SETUP INSTRUCTIONS:")
	print("1. Go to Project -> Project Settings -> Autoload")
	print("2. Add new autoload:")
	print("   - Path: res://scripts/core/systems/game_state.gd")
	print("   - Node Name: GameState")
	print("   - Enable Singleton: ✅")
	print("3. Click 'Add' and save project settings")
	print("4. GameState will now be accessible from any script as 'GameState'")

# ==============================================================================
# TESTING FUNCTIONS
# ==============================================================================

## Test the integration with sample data
static func test_integration():
	print("\n🧪 TESTING INTEGRATION:")
	
	# Sample configuration
	var test_config = {
		"player_species": "Fire Ant",
		"opponent_species": "Carpenter Ant",
		"opponent_difficulty": "Normal",
		"map": "Garden Valley"
	}
	
	print("Testing with config: ", test_config)
	
	# Test initialization
	start_skirmish_match(test_config)
	
	print("✅ Integration test completed")
