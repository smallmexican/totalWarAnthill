# ==============================================================================
# COLONY - High-level Colony Management
# ==============================================================================
# Purpose: Central management hub for ant colonies with population, resources,
#          territory, and AI coordination
# 
# The Colony is the brain of your ant empire. It handles:
# - Ant spawning and population management
# - Resource storage and distribution
# - Task creation and assignment
# - Building construction and upgrades
# - Territory expansion and defense
#
# Usage:
# - One per player/AI faction
# - Managed by GameState singleton
# - Interfaces with UI for player colonies
# - Controlled by AI for computer opponents
# ==============================================================================

class_name Colony
extends Node2D

# ==============================================================================
# SIGNALS
# ==============================================================================

signal population_changed(colony: Colony, new_population: int)
signal resource_changed(colony: Colony, resource_type: String, new_amount: int)
signal territory_expanded(colony: Colony, new_tiles: Array)
signal building_constructed(colony: Colony, building: Building)
signal ant_spawned(colony: Colony, ant: Ant)
signal ant_died(colony: Colony, ant: Ant)
signal colony_attacked(colony: Colony, attacker: Colony)
signal research_completed(colony: Colony, research_name: String)

# ==============================================================================
# CORE PROPERTIES
# ==============================================================================

## Colony identification
@export var colony_name: String = "Unnamed Colony"
@export var colony_id: int = -1
@export var species: String = "Fire Ant"
@export var player_controlled: bool = true

## Population management
@export var population: int = 0
@export var max_population: int = 100
@export var population_growth_rate: float = 1.0
var ants: Array[Ant] = []
var ant_types_count: Dictionary = {}  # ant_type: count

## Resource storage
@export var max_food_storage: int = 1000
@export var max_material_storage: int = 500
@export var max_larvae_storage: int = 50
var resources: Dictionary = {
	"food": 100,
	"materials": 50,
	"larvae": 5,
	"water": 20
}

## Territory and expansion
@export var territory_size: int = 1
@export var territory_tiles: Array[Vector2] = []
@export var expansion_rate: float = 0.1
var controlled_resource_nodes: Array[Node2D] = []

## Buildings and infrastructure
var buildings: Array[Building] = []
var building_slots: Dictionary = {}  # position: building_type
var construction_queue: Array[Dictionary] = []

## Task management system
var active_tasks: Array[Task] = []
var completed_tasks: Array[Task] = []
var task_queue: Array[Task] = []
var task_priority_queue: Array[Task] = []

## Research and technology
var available_research: Array[String] = ["Basic Tunneling", "Food Storage", "Soldier Training"]
var researched_technologies: Array[String] = []
var current_research: String = ""
var research_progress: float = 0.0
var research_points_per_second: float = 1.0

## Colony stats and modifiers
var colony_level: int = 1
var experience_points: int = 0
var attack_bonus: float = 1.0
var defense_bonus: float = 1.0
var resource_efficiency: float = 1.0
var construction_speed: float = 1.0

## AI and automation
var ai_controller: AIController
var automation_level: int = 0  # 0 = manual, 3 = full auto
var colony_strategy: String = "balanced"  # aggressive, defensive, economic, balanced

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func _ready():
	# Initialize colony
	setup_colony()
	setup_starting_resources()
	setup_starting_ants()
	setup_task_system()
	
	# Start colony processes
	start_colony_processes()
	
	print("🏛️ Colony initialized: ", colony_name, " (", species, ")")

func _process(delta):
	# Core colony update loop
	update_population(delta)
	update_resources(delta)
	update_tasks(delta)
	update_research(delta)
	update_ai_decisions(delta)

# ==============================================================================
# COLONY SETUP AND INITIALIZATION
# ==============================================================================

## Setup colony with initial configuration
func setup_colony():
	# Set unique ID if not assigned
	if colony_id == -1:
		colony_id = Time.get_time_dict_from_system().get("unix", 0) + randi() % 1000
	
	# Initialize ant type counter
	ant_types_count = {
		"Worker": 0,
		"Soldier": 0,
		"Queen": 0,
		"Scout": 0
	}
	
	# Setup territory
	territory_tiles.append(Vector2.ZERO)  # Starting tile
	territory_size = territory_tiles.size()

## Setup starting resources based on species
func setup_starting_resources():
	match species:
		"Fire Ant":
			resources["food"] = 150
			resources["materials"] = 75
			resources["larvae"] = 8
			attack_bonus = 1.2
		"Carpenter Ant":
			resources["food"] = 100
			resources["materials"] = 100
			resources["larvae"] = 6
			construction_speed = 1.3
		"Leaf Cutter Ant":
			resources["food"] = 200
			resources["materials"] = 30
			resources["larvae"] = 10
			resource_efficiency = 1.4
		_:
			# Default resources
			pass

## Setup starting ant population
func setup_starting_ants():
	# Spawn initial ants
	spawn_ant("Queen", global_position)
	for i in range(3):
		spawn_ant("Worker", global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20)))
	
	spawn_ant("Soldier", global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30)))

## Setup task management system
func setup_task_system():
	# Create initial tasks
	create_gather_task(global_position + Vector2(100, 0))
	create_build_task("Storage", global_position + Vector2(50, 50))

## Start ongoing colony processes
func start_colony_processes():
	# Start resource generation
	var resource_timer = Timer.new()
	resource_timer.wait_time = 5.0
	resource_timer.timeout.connect(_on_resource_generation_tick)
	resource_timer.autostart = true
	add_child(resource_timer)
	
	# Start population growth check
	var population_timer = Timer.new()
	population_timer.wait_time = 10.0
	population_timer.timeout.connect(_on_population_growth_tick)
	population_timer.autostart = true
	add_child(population_timer)

# ==============================================================================
# ANT MANAGEMENT
# ==============================================================================

## Spawn a new ant of the specified type
func spawn_ant(ant_type: String, spawn_position: Vector2 = Vector2.ZERO) -> Ant:
	if population >= max_population:
		print("⚠️ Cannot spawn ant: population limit reached")
		return null
	
	# Check resource cost
	var spawn_cost = get_ant_spawn_cost(ant_type)
	if not can_afford_resources(spawn_cost):
		print("⚠️ Cannot spawn ant: insufficient resources")
		return null
	
	# Consume resources
	consume_resources(spawn_cost)
	
	# Create ant
	var ant = preload("res://scripts/core/entities/ant.gd").new()
	ant.ant_type = ant_type
	ant.species = species
	ant.ant_id = generate_ant_id()
	ant.home_colony = self
	
	# Position ant
	if spawn_position == Vector2.ZERO:
		spawn_position = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	
	ant.global_position = spawn_position
	
	# Add to scene
	get_parent().add_child(ant)
	
	# Add to colony tracking
	ants.append(ant)
	ant_types_count[ant_type] += 1
	population = ants.size()
	
	# Connect signals
	ant.died.connect(_on_ant_died)
	ant.task_completed.connect(_on_ant_task_completed)
	
	# Emit signals
	ant_spawned.emit(self, ant)
	population_changed.emit(self, population)
	
	print("🐜 Spawned ", ant_type, " ant #", ant.ant_id, " for colony ", colony_name)
	return ant

## Remove ant from colony (when it dies)
func remove_ant(ant: Ant):
	if ant not in ants:
		return
	
	ants.erase(ant)
	ant_types_count[ant.ant_type] -= 1
	population = ants.size()
	
	ant_died.emit(self, ant)
	population_changed.emit(self, population)
	
	print("💀 Ant removed from colony: ", ant.ant_id)

## Get spawn cost for ant type
func get_ant_spawn_cost(ant_type: String) -> Dictionary:
	match ant_type:
		"Worker":
			return {"food": 10, "larvae": 1}
		"Soldier":
			return {"food": 20, "larvae": 1, "materials": 5}
		"Queen":
			return {"food": 100, "larvae": 3, "materials": 50}
		"Scout":
			return {"food": 15, "larvae": 1}
		_:
			return {"food": 10, "larvae": 1}

## Generate unique ant ID
func generate_ant_id() -> int:
	return colony_id * 10000 + ants.size() + 1

## Get ants of specific type
func get_ants_by_type(ant_type: String) -> Array[Ant]:
	var filtered_ants: Array[Ant] = []
	for ant in ants:
		if ant.ant_type == ant_type:
			filtered_ants.append(ant)
	return filtered_ants

## Get idle ants available for tasks
func get_idle_ants() -> Array[Ant]:
	var idle_ants: Array[Ant] = []
	for ant in ants:
		if ant.is_idle and ant.current_task == null:
			idle_ants.append(ant)
	return idle_ants

# ==============================================================================
# RESOURCE MANAGEMENT
# ==============================================================================

## Add resources to colony storage
func add_resource(resource_type: String, amount: int):
	if resource_type not in resources:
		resources[resource_type] = 0
	
	var old_amount = resources[resource_type]
	var max_storage = get_max_storage(resource_type)
	
	resources[resource_type] = min(max_storage, resources[resource_type] + amount)
	
	resource_changed.emit(self, resource_type, resources[resource_type])
	
	if resources[resource_type] != old_amount + amount:
		print("📦 Added ", resources[resource_type] - old_amount, "/", amount, " ", resource_type, " (storage full)")
	else:
		print("📦 Added ", amount, " ", resource_type, " to colony")

## Remove resources from colony storage
func consume_resource(resource_type: String, amount: int) -> bool:
	if resource_type not in resources:
		return false
	
	if resources[resource_type] < amount:
		return false
	
	resources[resource_type] -= amount
	resource_changed.emit(self, resource_type, resources[resource_type])
	
	print("📤 Consumed ", amount, " ", resource_type, " from colony")
	return true

## Check if colony has enough resources
func has_resource(resource_type: String, amount: int) -> bool:
	return resources.get(resource_type, 0) >= amount

## Check if colony can afford resource cost
func can_afford_resources(cost: Dictionary) -> bool:
	for resource_type in cost:
		if not has_resource(resource_type, cost[resource_type]):
			return false
	return true

## Consume multiple resources
func consume_resources(cost: Dictionary) -> bool:
	if not can_afford_resources(cost):
		return false
	
	for resource_type in cost:
		consume_resource(resource_type, cost[resource_type])
	
	return true

## Get maximum storage for resource type
func get_max_storage(resource_type: String) -> int:
	match resource_type:
		"food":
			return max_food_storage
		"materials":
			return max_material_storage
		"larvae":
			return max_larvae_storage
		_:
			return 100  # Default storage

## Resource generation from buildings and territory
func _on_resource_generation_tick():
	# Generate resources based on buildings and territory
	var food_income = calculate_food_income()
	var material_income = calculate_material_income()
	
	add_resource("food", food_income)
	add_resource("materials", material_income)
	
	# Generate larvae if queen is present
	if ant_types_count.get("Queen", 0) > 0:
		add_resource("larvae", 1)

## Calculate food income per tick
func calculate_food_income() -> int:
	var base_income = 5
	var building_bonus = 0
	var territory_bonus = territory_size * 2
	
	# Add building bonuses
	for building in buildings:
		if building.building_type == "Food Storage":
			building_bonus += 3
	
	return int((base_income + building_bonus + territory_bonus) * resource_efficiency)

## Calculate material income per tick
func calculate_material_income() -> int:
	var base_income = 2
	var building_bonus = 0
	var territory_bonus = territory_size * 1
	
	# Add building bonuses
	for building in buildings:
		if building.building_type == "Workshop":
			building_bonus += 2
	
	return int((base_income + building_bonus + territory_bonus) * resource_efficiency)

# ==============================================================================
# TASK MANAGEMENT
# ==============================================================================

## Create a new gather task
func create_gather_task(location: Vector2, resource_type: String = "food") -> Task:
	var task = Task.new("gather", location, 1)
	task.task_name = "Gather " + resource_type.capitalize()
	task.description = "Gather " + resource_type + " from the environment"
	task.resource_reward = {resource_type: 5}
	task.setup_task_type()
	
	add_task(task)
	return task

## Create a new build task
func create_build_task(building_type: String, location: Vector2) -> Task:
	var task = Task.new("build", location, 2)
	task.task_name = "Build " + building_type
	task.description = "Construct " + building_type + " building"
	task.required_resources = {"materials": 20}
	task.setup_task_type()
	
	add_task(task)
	return task

## Create a combat task
func create_combat_task(target: Node2D) -> Task:
	var task = Task.new("fight", target.global_position, 3)
	task.task_name = "Attack Enemy"
	task.target_node = target
	task.setup_task_type()
	
	add_task(task)
	return task

## Add task to colony task system
func add_task(task: Task):
	if task == null:
		return
	
	active_tasks.append(task)
	task.task_completed.connect(_on_task_completed)
	
	# Try to assign ants immediately
	assign_ants_to_task(task)
	
	print("📋 Task added to colony: ", task.task_name)

## Remove task from active tasks
func remove_task(task: Task):
	if task in active_tasks:
		active_tasks.erase(task)
	
	if task in task_queue:
		task_queue.erase(task)

## Assign available ants to a task
func assign_ants_to_task(task: Task):
	var idle_ants = get_idle_ants()
	var needed_ants = task.get_available_slots()
	
	for i in range(min(needed_ants, idle_ants.size())):
		var ant = idle_ants[i]
		if task.can_accept_ant(ant):
			ant.assign_task(task)

## Get a task for an idle ant
func get_task_for_ant(ant: Ant) -> Task:
	# Find highest priority task that needs ants
	var best_task: Task = null
	var best_priority = -1
	
	for task in active_tasks:
		if task.can_accept_ant(ant) and task.get_priority_score() > best_priority:
			best_task = task
			best_priority = task.get_priority_score()
	
	return best_task

## Update all active tasks
func update_tasks(delta: float):
	# Update task progress
	for task in active_tasks.duplicate():
		task.update_progress(delta)
		
		# Remove completed or failed tasks
		if task.status == "completed" or task.status == "failed":
			remove_task(task)

## Task completion handler
func _on_task_completed(task: Task):
	print("✅ Colony task completed: ", task.task_name)
	completed_tasks.append(task)
	remove_task(task)

## Ant task completion handler
func _on_ant_task_completed(ant: Ant, task: Task):
	print("🐜 Ant ", ant.ant_id, " completed task: ", task.task_name)

# ==============================================================================
# BUILDING AND CONSTRUCTION
# ==============================================================================

## Construct a building at the specified location
func construct_building(building_type: String, location: Vector2) -> Building:
	# Check if we can afford the building
	var build_cost = get_building_cost(building_type)
	if not can_afford_resources(build_cost):
		print("⚠️ Cannot afford building: ", building_type)
		return null
	
	# Check if location is valid
	if not can_build_at_location(location):
		print("⚠️ Cannot build at location: ", location)
		return null
	
	# Consume resources
	consume_resources(build_cost)
	
	# Create building (simplified for now)
	var building = Building.new()
	building.building_type = building_type
	building.global_position = location
	building.owning_colony = self
	
	# Add to scene and tracking
	get_parent().add_child(building)
	buildings.append(building)
	
	building_constructed.emit(self, building)
	
	print("🏗️ Constructed ", building_type, " at ", location)
	return building

## Get building construction cost
func get_building_cost(building_type: String) -> Dictionary:
	match building_type:
		"Storage":
			return {"materials": 30, "food": 10}
		"Nursery":
			return {"materials": 40, "food": 20}
		"Barracks":
			return {"materials": 50, "food": 30}
		"Workshop":
			return {"materials": 35, "food": 15}
		_:
			return {"materials": 20, "food": 10}

## Check if building can be constructed at location
func can_build_at_location(location: Vector2) -> bool:
	# Simple check - ensure location is in territory
	# TODO: Add more sophisticated building placement rules
	return true

# ==============================================================================
# POPULATION AND GROWTH
# ==============================================================================

## Update population and growth
func update_population(delta: float):
	# Population growth is handled by spawning ants
	# This function tracks population changes
	population = ants.size()

## Population growth tick
func _on_population_growth_tick():
	# Attempt to grow population if resources allow
	if population < max_population and has_resource("food", 50):
		# Decide what type of ant to spawn based on colony needs
		var ant_type = decide_ant_type_to_spawn()
		spawn_ant(ant_type)

## Decide what type of ant to spawn based on colony needs
func decide_ant_type_to_spawn() -> String:
	var worker_ratio = float(ant_types_count.get("Worker", 0)) / max(population, 1)
	var soldier_ratio = float(ant_types_count.get("Soldier", 0)) / max(population, 1)
	
	# Maintain balance: 60% workers, 30% soldiers, 10% others
	if worker_ratio < 0.6:
		return "Worker"
	elif soldier_ratio < 0.3:
		return "Soldier"
	else:
		return "Scout"

# ==============================================================================
# RESEARCH AND TECHNOLOGY
# ==============================================================================

## Start researching a technology
func start_research(tech_name: String) -> bool:
	if tech_name not in available_research:
		print("⚠️ Technology not available: ", tech_name)
		return false
	
	if tech_name in researched_technologies:
		print("⚠️ Technology already researched: ", tech_name)
		return false
	
	current_research = tech_name
	research_progress = 0.0
	
	print("🔬 Started researching: ", tech_name)
	return true

## Update research progress
func update_research(delta: float):
	if current_research.is_empty():
		return
	
	research_progress += research_points_per_second * delta
	
	# Check for completion
	var required_progress = get_research_cost(current_research)
	if research_progress >= required_progress:
		complete_research()

## Complete current research
func complete_research():
	if current_research.is_empty():
		return
	
	researched_technologies.append(current_research)
	apply_research_benefits(current_research)
	
	research_completed.emit(self, current_research)
	print("🎉 Research completed: ", current_research)
	
	current_research = ""
	research_progress = 0.0

## Get research cost (in research points)
func get_research_cost(tech_name: String) -> float:
	match tech_name:
		"Basic Tunneling":
			return 100.0
		"Food Storage":
			return 150.0
		"Soldier Training":
			return 200.0
		_:
			return 100.0

## Apply benefits from completed research
func apply_research_benefits(tech_name: String):
	match tech_name:
		"Basic Tunneling":
			construction_speed *= 1.2
		"Food Storage":
			max_food_storage += 500
		"Soldier Training":
			attack_bonus *= 1.1

# ==============================================================================
# AI DECISION MAKING
# ==============================================================================

## Update AI decisions for computer-controlled colonies
func update_ai_decisions(delta: float):
	if player_controlled or ai_controller == null:
		return
	
	# AI makes decisions periodically
	ai_controller.make_decision()

## Set AI controller for this colony
func set_ai_controller(controller: AIController):
	ai_controller = controller
	player_controlled = false

# ==============================================================================
# TERRITORY AND EXPANSION
# ==============================================================================

## Expand territory to new tile
func expand_territory(new_tile: Vector2) -> bool:
	if new_tile in territory_tiles:
		return false
	
	# Check if expansion is valid (adjacent to existing territory)
	if not is_adjacent_to_territory(new_tile):
		return false
	
	territory_tiles.append(new_tile)
	territory_size = territory_tiles.size()
	
	territory_expanded.emit(self, [new_tile])
	print("🌍 Territory expanded to: ", new_tile)
	
	return true

## Check if tile is adjacent to existing territory
func is_adjacent_to_territory(tile: Vector2) -> bool:
	for existing_tile in territory_tiles:
		if existing_tile.distance_to(tile) <= 1.0:
			return true
	return false

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

## Get colony data for saving
func get_colony_data() -> Dictionary:
	return {
		"colony_id": colony_id,
		"colony_name": colony_name,
		"species": species,
		"player_controlled": player_controlled,
		"position": global_position,
		"population": population,
		"max_population": max_population,
		"resources": resources,
		"territory_size": territory_size,
		"territory_tiles": territory_tiles,
		"researched_technologies": researched_technologies,
		"current_research": current_research,
		"research_progress": research_progress,
		"colony_level": colony_level,
		"experience_points": experience_points
	}

## Load colony from saved data
func load_colony_data(data: Dictionary):
	colony_id = data.get("colony_id", -1)
	colony_name = data.get("colony_name", "Unnamed Colony")
	species = data.get("species", "Fire Ant")
	player_controlled = data.get("player_controlled", true)
	global_position = data.get("position", Vector2.ZERO)
	population = data.get("population", 0)
	max_population = data.get("max_population", 100)
	resources = data.get("resources", {})
	territory_size = data.get("territory_size", 1)
	territory_tiles = data.get("territory_tiles", [])
	researched_technologies = data.get("researched_technologies", [])
	current_research = data.get("current_research", "")
	research_progress = data.get("research_progress", 0.0)
	colony_level = data.get("colony_level", 1)
	experience_points = data.get("experience_points", 0)

## Get debug info string
func get_debug_info() -> String:
	return "Colony: %s | Pop: %d/%d | Food: %d | Materials: %d | Tasks: %d" % [
		colony_name, population, max_population, 
		resources.get("food", 0), resources.get("materials", 0), active_tasks.size()
	]

## Handle ant death
func _on_ant_died(ant: Ant):
	remove_ant(ant)
