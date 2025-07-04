# ==============================================================================
# COLONY VIEW - PLACEHOLDER
# ==============================================================================
# Purpose: Underground view of ant colony with tunnels, rooms, and workers
# 
# CURRENT STATUS: PLACEHOLDER - Basic functionality for testing scene transitions
# 
# PLANNED FEATURES:
# - 2D side-view of underground tunnel system
# - Room construction (nursery, food storage, barracks)
# - Worker ant management and role assignment
# - Digging mechanics to expand the colony
# - Resource management (food, larvae, materials)
# - Ant traffic visualization and pathfinding
# - Pheromone trail system
#
# USAGE:
# - Accessed from Strategic Map by selecting a colony
# - Press ESC or B to return to Strategic Map
# - Press D to simulate digging (placeholder)
#
# TODO: Replace with actual colony management implementation
# ==============================================================================

extends Control

# ------------------------------------------------------------------------------
# PLACEHOLDER VARIABLES
# ------------------------------------------------------------------------------

## Reference to the main scene manager for transitions
var main_scene_manager: Node

## Reference to the background node for color changes
@export var background: ColorRect

## Placeholder colony data
var colony_data = {
	"name": "Main Colony",
	"population": 50,
	"food_storage": 100,
	"rooms": ["Nursery", "Food Storage", "Barracks"]
}

# ------------------------------------------------------------------------------
# GODOT LIFECYCLE METHODS
# ------------------------------------------------------------------------------

## Initialize the colony view
func _ready():
	# Ensure the Control node fills the entire viewport when added to Node2D parent
	# This fixes centering issues when Control is child of Node2D (GameLayer)
	call_deferred("_setup_viewport_size")
	
	# Get reference to the main scene manager
	main_scene_manager = get_tree().root.get_node("Main")
	
	# Display placeholder information
	print("=== COLONY VIEW LOADED ===")
	print("Colony: ", colony_data.name)
	print("Population: ", colony_data.population)
	print("Food: ", colony_data.food_storage)
	print("Controls:")
	print("  ESC/B - Return to Strategic Map")
	print("  D - Dig new tunnel (placeholder)")
	print("  W - Assign worker roles (placeholder)")

## Setup proper viewport sizing after the node is in the scene tree
func _setup_viewport_size():
	# Get the current viewport size
	var viewport = get_viewport()
	if viewport:
		var viewport_size = viewport.get_visible_rect().size
		
		# Set this Control node to fill the entire viewport
		set_size(viewport_size)
		set_position(Vector2.ZERO)
		
		print("=== COLONY VIEW SIZING ===")
		print("Viewport size: ", viewport_size)
		print("Control size: ", get_size())
		print("Control position: ", get_position())
	else:
		print("ERROR: Cannot get viewport for sizing!")

## Handle input for placeholder functionality
func _input(event):
	# Return to strategic map on ESC or B
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_B and event.pressed):
		return_to_strategic_map()
	
	# Simulate digging on D key
	if event is InputEventKey and event.keycode == KEY_D and event.pressed:
		simulate_digging()
	
	# Simulate worker assignment on W key
	if event is InputEventKey and event.keycode == KEY_W and event.pressed:
		simulate_worker_assignment()

# ------------------------------------------------------------------------------
# SCENE TRANSITION METHODS
# ------------------------------------------------------------------------------

## Return to the strategic map
func return_to_strategic_map():
	print("=== BACK BUTTON CLICKED ===")
	print("Returning to Strategic Map...")
	if main_scene_manager:
		main_scene_manager.load_game_scene("res://scenes/game/StrategicMap.tscn")
	else:
		print("ERROR: main_scene_manager is null!")

# ------------------------------------------------------------------------------
# PLACEHOLDER FUNCTIONALITY
# ------------------------------------------------------------------------------

## Simulate the digging mechanic
## TODO: Implement actual tunnel creation system
func simulate_digging():
	print("=== DIG BUTTON CLICKED ===")
	print("🐜 Workers are digging a new tunnel...")
	print("💡 Future: Click and drag to create tunnel paths")
	print("💡 Future: Different room types (nursery, storage, etc.)")

## Simulate worker role assignment
## TODO: Implement actual worker management system
func simulate_worker_assignment():
	print("=== MANAGE WORKERS BUTTON CLICKED ===")
	print("👷 Assigning worker roles...")
	print("Current workers:")
	print("  - Diggers: 15")
	print("  - Nurses: 10") 
	print("  - Foragers: 20")
	print("  - Guards: 5")
	print("💡 Future: Drag workers between roles")

## Setup the colony with provided data
## @param data: Dictionary containing colony information
## TODO: Implement actual colony setup
func setup_colony(data: Dictionary):
	colony_data = data
	print("Colony setup with data: ", data)

# ------------------------------------------------------------------------------
# FUTURE IMPLEMENTATION METHODS (PLACEHOLDER STUBS)
# ------------------------------------------------------------------------------

## Create a new room in the colony
## TODO: Implement room construction system
func create_room(room_type: String, position: Vector2):
	pass

## Assign a worker to a specific role
## TODO: Implement worker management system
func assign_worker(worker_id: int, role: String):
	pass

## Update resource counts (food, materials, etc.)
## TODO: Implement resource management system
func update_resources():
	pass

## Manage ant movement and pathfinding
## TODO: Implement ant traffic system
func update_ant_traffic():
	pass

## Handle pheromone trail visualization
## TODO: Implement pheromone system
func update_pheromone_trails():
	pass

## Process colony growth and expansion
## TODO: Implement colony progression system
func process_colony_growth():
	pass

# ------------------------------------------------------------------------------
# BUTTON HANDLERS
# ------------------------------------------------------------------------------

## Handle the Manage Colony button click
func _on_manage_button_pressed():
	print("=== MANAGE BUTTON CLICKED ===")
	print("🐜 Managing colony operations...")
	simulate_worker_assignment()

## Handle the Build Structures button click
func _on_build_button_pressed():
	print("=== BUILD BUTTON CLICKED ===")
	print("🏗️ Building structures...")
	simulate_digging()

## Handle the View Resources button click
func _on_resources_button_pressed():
	print("=== RESOURCES BUTTON CLICKED ===")
	print("📦 Viewing colony resources...")
	print("Food Storage: ", colony_data.food_storage)
	print("Population: ", colony_data.population)
	print("Available Materials: Stone x15, Dirt x50")

## Handle the Back button click
func _on_back_button_pressed():
	print("=== BACK BUTTON CLICKED ===")
	return_to_strategic_map()
