# ==============================================================================
# ANT - Core Entity Class
# ==============================================================================
# Purpose: Individual ant units with roles, behaviors, and AI
# 
# This is the fundamental unit of your ant colony. Each ant has:
# - Specific role (Worker, Soldier, Queen, etc.)
# - Species characteristics and abilities
# - Task assignment and pathfinding
# - Resource carrying and combat capabilities
#
# Usage:
# - Spawned by Colony when needed
# - Assigned tasks through Task system
# - Moves around map gathering resources or fighting
# - Can be controlled by player or AI
# ==============================================================================

class_name Ant
extends CharacterBody2D

# ==============================================================================
# SIGNALS
# ==============================================================================

signal task_completed(ant: Ant, task)
signal health_changed(ant: Ant, old_health: int, new_health: int)
signal died(ant: Ant)
signal resource_gathered(ant: Ant, resource_type: String, amount: int)

# ==============================================================================
# CORE PROPERTIES
# ==============================================================================

## Ant identification and type
@export var ant_type: String = "Worker"  # Worker, Soldier, Queen, Scout
@export var species: String = "Fire Ant"  # Fire Ant, Carpenter Ant, etc.
@export var ant_id: int = -1

## Health and energy
@export var max_health: int = 100
@export var current_health: int = 100
@export var max_energy: int = 100
@export var current_energy: int = 100
@export var energy_drain_rate: float = 1.0  # Energy per second
@export var energy_regen_rate: float = 0.5  # Energy regen when resting

## Movement and navigation
@export var base_movement_speed: float = 50.0
@export var current_movement_speed: float = 50.0
@export var acceleration: float = 200.0
var target_position: Vector2
var navigation_path: PackedVector2Array
var current_path_index: int = 0

## Combat stats
@export var attack_power: int = 10
@export var defense_rating: int = 5
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 1.0
var last_attack_time: float = 0.0

## Resource carrying
@export var carrying_capacity: int = 10
var carrying_resource: String = ""
var carrying_amount: int = 0

## Task management
var current_task = null  # Task object
var task_queue: Array = []  # Array of Task objects
var is_idle: bool = true

## AI and behavior
var home_colony: Colony
var current_state: String = "idle"  # idle, moving, working, fighting, returning
var target_node: Node2D
var behavior_tree = null  # Simple state machine for now

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func _ready():
	# Initialize ant with default values
	setup_ant_visuals()
	setup_navigation()
	current_health = max_health
	current_energy = max_energy
	current_movement_speed = base_movement_speed
	
	# Connect to navigation system
	setup_pathfinding()
	
	print("🐜 Ant spawned: ", ant_type, " (", species, ") - ID: ", ant_id)

func _physics_process(delta):
	# Core ant update loop
	update_energy(delta)
	update_movement(delta)
	update_task_execution(delta)
	update_ai_behavior(delta)
	
	# Apply movement
	if velocity.length() > 0:
		move_and_slide()

# ==============================================================================
# TASK MANAGEMENT
# ==============================================================================

## Assign a new task to this ant
func assign_task(task: Task):
	if task == null:
		push_warning("Attempted to assign null task to ant ", ant_id)
		return
	
	# Add to task queue
	task_queue.append(task)
	task.assign_ant(self)
	
	# If currently idle, start this task immediately
	if current_task == null and is_idle:
		start_next_task()
	
	print("📋 Task assigned to ant ", ant_id, ": ", task.task_type)

## Start the next task in the queue
func start_next_task():
	if task_queue.is_empty():
		set_idle_state()
		return
	
	# Get next task
	current_task = task_queue.pop_front()
	is_idle = false
	
	# Update state based on task type
	match current_task.task_type:
		"gather":
			current_state = "moving"
			set_target_position(current_task.target_location)
		"build":
			current_state = "moving" 
			set_target_position(current_task.target_location)
		"fight":
			current_state = "moving"
			if current_task != null and current_task.get("target_node"):
				set_target_node(current_task.get("target_node"))
		"patrol":
			current_state = "moving"
			set_target_position(current_task.target_location)
		_:
			print("⚠️ Unknown task type: ", current_task.task_type)

## Complete current task and move to next
func complete_current_task():
	if current_task == null:
		return
	
	# Emit signal for colony tracking
	task_completed.emit(self, current_task)
	
	print("✅ Task completed by ant ", ant_id, ": ", current_task.task_type)
	
	# Clear current task
	current_task = null
	
	# Start next task or go idle
	start_next_task()

# ==============================================================================
# MOVEMENT AND NAVIGATION
# ==============================================================================

## Set target position for movement
func set_target_position(pos: Vector2):
	target_position = pos
	calculate_path_to_target()

## Set target node to follow/attack
func set_target_node(node: Node2D):
	if node == null:
		return
	target_node = node
	target_position = node.global_position
	calculate_path_to_target()

## Calculate navigation path to target
func calculate_path_to_target():
	# For now, simple direct movement
	# TODO: Integrate with NavigationRegion2D for proper pathfinding
	navigation_path = PackedVector2Array([global_position, target_position])
	current_path_index = 0

## Update movement towards target
func update_movement(delta: float):
	if current_state != "moving" or navigation_path.is_empty():
		velocity = Vector2.ZERO
		return
	
	# Get current target point in path
	if current_path_index >= navigation_path.size():
		arrive_at_destination()
		return
	
	var target_point = navigation_path[current_path_index]
	var direction = (target_point - global_position).normalized()
	var distance = global_position.distance_to(target_point)
	
	# Check if we've reached this point
	if distance < 5.0:  # Close enough threshold
		current_path_index += 1
		if current_path_index >= navigation_path.size():
			arrive_at_destination()
			return
		return
	
	# Move towards target
	var desired_velocity = direction * current_movement_speed
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)

## Called when ant reaches its destination
func arrive_at_destination():
	velocity = Vector2.ZERO
	
	match current_state:
		"moving":
			if current_task:
				execute_task_at_location()
			else:
				set_idle_state()

# ==============================================================================
# TASK EXECUTION
# ==============================================================================

## Execute the current task at the target location
func execute_task_at_location():
	if current_task == null:
		return
	
	match current_task.task_type:
		"gather":
			start_gathering()
		"build":
			start_building()
		"fight":
			start_combat()
		"patrol":
			patrol_area()

## Start gathering resources
func start_gathering():
	current_state = "working"
	print("🔄 Ant ", ant_id, " started gathering at ", global_position)
	
	# Simulate gathering (replace with actual resource interaction)
	await get_tree().create_timer(2.0).timeout
	
	# Pick up resource
	carrying_resource = "food"
	carrying_amount = min(carrying_capacity, 5)
	resource_gathered.emit(self, carrying_resource, carrying_amount)
	
	# Return to colony
	return_to_colony()

## Start building/construction
func start_building():
	current_state = "working"
	print("🔨 Ant ", ant_id, " started building at ", global_position)
	
	# Simulate building (replace with actual construction)
	await get_tree().create_timer(3.0).timeout
	
	complete_current_task()

## Start combat with target
func start_combat():
	current_state = "fighting"
	print("⚔️ Ant ", ant_id, " engaging in combat")
	
	# Implement combat logic
	if target_node and is_instance_valid(target_node):
		attack_target(target_node)
	else:
		complete_current_task()

## Patrol the assigned area
func patrol_area():
	print("👁️ Ant ", ant_id, " patrolling area")
	# TODO: Implement patrol behavior
	complete_current_task()

# ==============================================================================
# COMBAT SYSTEM
# ==============================================================================

## Attack a target node
func attack_target(target: Node2D):
	if target == null or not is_instance_valid(target):
		complete_current_task()
		return
	
	var current_time = Time.get_time_dict_from_system()
	var time_seconds = current_time.hour * 3600 + current_time.minute * 60 + current_time.second
	
	if time_seconds - last_attack_time < attack_cooldown:
		return  # Still on cooldown
	
	var distance = global_position.distance_to(target.global_position)
	if distance > attack_range:
		# Move closer
		set_target_position(target.global_position)
		return
	
	# Perform attack
	last_attack_time = time_seconds
	var damage = calculate_damage(target)
	
	if target.has_method("take_damage"):
		target.take_damage(damage)
		print("💥 Ant ", ant_id, " attacked target for ", damage, " damage")

## Calculate damage to deal to target
func calculate_damage(target: Node2D) -> int:
	var base_damage = attack_power
	
	# Apply species bonuses
	# Apply target defense
	# Apply random variation
	
	return max(1, base_damage)  # Minimum 1 damage

## Take damage from an attack
func take_damage(damage: int):
	var old_health = current_health
	current_health = max(0, current_health - damage)
	
	health_changed.emit(self, old_health, current_health)
	
	if current_health <= 0:
		die()

## Handle ant death
func die():
	print("💀 Ant ", ant_id, " has died")
	died.emit(self)
	
	# Drop any carried resources
	if carrying_amount > 0:
		drop_carried_resources()
	
	# Remove from colony
	if home_colony:
		home_colony.remove_ant(self)
	
	queue_free()

# ==============================================================================
# RESOURCE MANAGEMENT
# ==============================================================================

## Return to colony with carried resources
func return_to_colony():
	if home_colony == null:
		complete_current_task()
		return
	
	current_state = "returning"
	set_target_position(home_colony.global_position)
	
	print("🏠 Ant ", ant_id, " returning to colony with ", carrying_amount, " ", carrying_resource)

## Deposit resources at colony
func deposit_resources():
	if home_colony == null or carrying_amount <= 0:
		return
	
	home_colony.add_resource(carrying_resource, carrying_amount)
	print("📦 Deposited ", carrying_amount, " ", carrying_resource, " at colony")
	
	# Clear carried resources
	carrying_resource = ""
	carrying_amount = 0
	
	complete_current_task()

## Drop carried resources (when dying or abandoning task)
func drop_carried_resources():
	if carrying_amount <= 0:
		return
	
	# Create resource pickup at current location
	# TODO: Implement resource drop system
	print("📤 Dropped ", carrying_amount, " ", carrying_resource, " at ", global_position)
	
	carrying_resource = ""
	carrying_amount = 0

# ==============================================================================
# ENERGY AND STATE MANAGEMENT
# ==============================================================================

## Update energy levels
func update_energy(delta: float):
	match current_state:
		"idle", "returning":
			# Regenerate energy when idle or returning
			current_energy = min(max_energy, current_energy + energy_regen_rate * delta)
		_:
			# Drain energy when working/fighting/moving
			current_energy = max(0, current_energy - energy_drain_rate * delta)
	
	# Check if exhausted
	if current_energy <= 0:
		handle_exhaustion()

## Handle ant exhaustion
func handle_exhaustion():
	print("😴 Ant ", ant_id, " is exhausted and needs rest")
	
	# Slow down movement
	current_movement_speed = base_movement_speed * 0.5
	
	# If critical, force rest
	if current_energy <= 0:
		force_rest()

## Force ant to rest and recover
func force_rest():
	current_state = "resting"
	velocity = Vector2.ZERO
	
	# Rest until energy is restored
	while current_energy < max_energy * 0.8:
		await get_tree().process_frame
		current_energy = min(max_energy, current_energy + energy_regen_rate * 2.0 * get_process_delta_time())
	
	# Resume normal speed
	current_movement_speed = base_movement_speed
	
	# Return to previous task or go idle
	if current_task:
		current_state = "moving"
	else:
		set_idle_state()

## Set ant to idle state
func set_idle_state():
	current_state = "idle"
	current_task = null
	is_idle = true
	velocity = Vector2.ZERO
	print("💤 Ant ", ant_id, " is now idle")

# ==============================================================================
# AI BEHAVIOR
# ==============================================================================

## Update AI behavior and decision making
func update_ai_behavior(delta: float):
	# Simple AI behavior tree
	if current_task == null and is_idle:
		# Look for new tasks from colony
		request_task_from_colony()

## Update task execution progress
func update_task_execution(delta: float):
	if current_task == null:
		return
	
	# Update task progress based on current activity
	match current_state:
		"working":
			current_task.update_progress(delta)
		"fighting":
			# Combat tasks don't have traditional progress
			pass

## Request a new task from the home colony
func request_task_from_colony():
	if home_colony == null:
		return
	
	var new_task = home_colony.get_task_for_ant(self)
	if new_task:
		assign_task(new_task)

# ==============================================================================
# SETUP AND INITIALIZATION
# ==============================================================================

## Setup ant visuals (sprite, animations, etc.)
func setup_ant_visuals():
	# TODO: Add sprite, animation player, etc.
	# For now, use a simple colored square
	var sprite = ColorRect.new()
	sprite.size = Vector2(8, 8)
	sprite.position = Vector2(-4, -4)
	
	match ant_type:
		"Worker":
			sprite.color = Color.BROWN
		"Soldier":
			sprite.color = Color.RED
		"Queen":
			sprite.color = Color.GOLD
		"Scout":
			sprite.color = Color.GREEN
		_:
			sprite.color = Color.WHITE
	
	add_child(sprite)

## Setup navigation system
func setup_navigation():
	# TODO: Connect to NavigationAgent2D for proper pathfinding
	pass

## Setup pathfinding integration
func setup_pathfinding():
	# TODO: Integrate with Godot's navigation system
	pass

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

## Get ant info as dictionary for saving/loading
func get_ant_data() -> Dictionary:
	return {
		"ant_id": ant_id,
		"ant_type": ant_type,
		"species": species,
		"position": global_position,
		"health": current_health,
		"energy": current_energy,
		"carrying_resource": carrying_resource,
		"carrying_amount": carrying_amount,
		"current_state": current_state
	}

## Load ant from saved data
func load_ant_data(data: Dictionary):
	ant_id = data.get("ant_id", -1)
	ant_type = data.get("ant_type", "Worker")
	species = data.get("species", "Fire Ant")
	global_position = data.get("position", Vector2.ZERO)
	current_health = data.get("health", max_health)
	current_energy = data.get("energy", max_energy)
	carrying_resource = data.get("carrying_resource", "")
	carrying_amount = data.get("carrying_amount", 0)
	current_state = data.get("current_state", "idle")

## Get debug info string
func get_debug_info() -> String:
	return "Ant %d [%s]: %s | Health: %d/%d | Energy: %d/%d | Task: %s" % [
		ant_id, ant_type, current_state, current_health, max_health, 
		current_energy, max_energy, current_task.task_type if current_task else "None"
	]
