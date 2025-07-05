# ==============================================================================
# TASK - Work Assignment System
# ==============================================================================
# Purpose: Individual work assignments for ants with priority and progress tracking
# 
# Tasks are the core of ant behavior coordination. They define:
# - What needs to be done (gather, build, fight, etc.)
# - Where it needs to be done
# - How many ants are needed
# - Priority and progress tracking
#
# Usage:
# - Created by Colony when work needs to be assigned
# - Assigned to available ants through the task queue system
# - Tracked for completion and resource allocation
# ==============================================================================

class_name Task
extends RefCounted

# ==============================================================================
# SIGNALS
# ==============================================================================

signal task_progress_updated(task: Task, progress: float)
signal task_completed(task: Task)
signal ant_assigned(task: Task, ant: Ant)
signal ant_removed(task: Task, ant: Ant)

# ==============================================================================
# CORE PROPERTIES
# ==============================================================================

## Task identification
@export var task_id: int = -1
@export var task_type: String = ""  # gather, build, fight, patrol, transport
@export var task_name: String = ""
@export var description: String = ""

## Priority and scheduling
@export var priority: int = 1  # 1 = low, 5 = critical
@export var is_urgent: bool = false
@export var creation_time: float
@export var deadline: float = -1  # -1 = no deadline

## Location and target
@export var target_location: Vector2 = Vector2.ZERO
@export var target_node: Node2D
@export var work_radius: float = 50.0  # Area around target where work happens

## Resource requirements
@export var required_resources: Dictionary = {}  # resource_type: amount
@export var resource_cost: Dictionary = {}  # Resources consumed by task
@export var resource_reward: Dictionary = {}  # Resources gained from completion

## Ant assignment
@export var required_ants: int = 1
@export var max_ants: int = 1
var assigned_ants: Array[Ant] = []
var preferred_ant_types: Array[String] = []  # Worker, Soldier, etc.

## Progress tracking
@export var completion_progress: float = 0.0  # 0.0 to 1.0
@export var estimated_time: float = 10.0  # Seconds to complete
@export var actual_start_time: float = -1
@export var work_rate: float = 1.0  # How fast the task progresses per ant per second

## Task state
@export var status: String = "pending"  # pending, assigned, in_progress, completed, failed, cancelled
@export var can_be_interrupted: bool = true
@export var requires_continuous_work: bool = true

## Dependencies
var prerequisite_tasks: Array[Task] = []
var dependent_tasks: Array[Task] = []
var blocks_other_tasks: bool = false

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func _init(type: String = "", location: Vector2 = Vector2.ZERO, ants_needed: int = 1):
	task_type = type
	target_location = location
	required_ants = ants_needed
	max_ants = ants_needed
	creation_time = Time.get_time_dict_from_system().get("unix", 0.0)
	task_id = generate_task_id()
	
	# Set default task name
	if task_name.is_empty():
		task_name = task_type.capitalize() + " Task"
	
	print("📋 Task created: ", task_name, " at ", target_location)

# ==============================================================================
# ANT ASSIGNMENT
# ==============================================================================

## Assign an ant to this task
func assign_ant(ant: Ant) -> bool:
	if ant == null:
		push_warning("Attempted to assign null ant to task ", task_id)
		return false
	
	# Check if already assigned
	if ant in assigned_ants:
		print("⚠️ Ant ", ant.ant_id, " already assigned to task ", task_id)
		return false
	
	# Check if we have room for more ants
	if assigned_ants.size() >= max_ants:
		print("⚠️ Task ", task_id, " is full (", max_ants, " ants)")
		return false
	
	# Check ant type preference
	if not preferred_ant_types.is_empty() and ant.ant_type not in preferred_ant_types:
		print("⚠️ Ant type ", ant.ant_type, " not preferred for task ", task_id)
		# Still allow assignment but with warning
	
	# Assign the ant
	assigned_ants.append(ant)
	ant.home_colony = ant.home_colony  # Ensure ant knows its colony
	
	# Update task status
	if status == "pending":
		status = "assigned"
		actual_start_time = Time.get_time_dict_from_system().get("unix", 0.0)
	
	ant_assigned.emit(self, ant)
	print("✅ Ant ", ant.ant_id, " assigned to task: ", task_name)
	
	return true

## Remove an ant from this task
func remove_ant(ant: Ant) -> bool:
	if ant == null or ant not in assigned_ants:
		return false
	
	assigned_ants.erase(ant)
	ant_removed.emit(self, ant)
	
	# Update status if no ants left
	if assigned_ants.is_empty():
		if status == "assigned" or status == "in_progress":
			status = "pending"
	
	print("➖ Ant ", ant.ant_id, " removed from task: ", task_name)
	return true

## Check if this task can accept more ants
func can_accept_ant(ant: Ant = null) -> bool:
	if assigned_ants.size() >= max_ants:
		return false
	
	if ant and ant in assigned_ants:
		return false
	
	if ant and not preferred_ant_types.is_empty() and ant.ant_type not in preferred_ant_types:
		return false  # Strict type checking for this version
	
	return true

## Get the number of available ant slots
func get_available_slots() -> int:
	return max_ants - assigned_ants.size()

# ==============================================================================
# PROGRESS TRACKING
# ==============================================================================

## Update task progress based on work done
func update_progress(delta: float):
	if status != "assigned" and status != "in_progress":
		return
	
	if assigned_ants.is_empty():
		return
	
	# Calculate work done this frame
	var work_done = 0.0
	for ant in assigned_ants:
		if ant.current_state == "working":
			work_done += work_rate * delta
	
	# Update progress
	var old_progress = completion_progress
	completion_progress = min(1.0, completion_progress + work_done / estimated_time)
	
	# Update status
	if status == "assigned" and completion_progress > 0:
		status = "in_progress"
	
	# Emit progress signal if changed significantly
	if abs(completion_progress - old_progress) > 0.01:
		task_progress_updated.emit(self, completion_progress)
	
	# Check for completion
	if completion_progress >= 1.0:
		complete_task()

## Force complete the task
func complete_task():
	if status == "completed":
		return
	
	status = "completed"
	completion_progress = 1.0
	
	# Distribute rewards
	distribute_rewards()
	
	# Complete dependent tasks prerequisites
	for dependent_task in dependent_tasks:
		dependent_task.check_prerequisites()
	
	task_completed.emit(self)
	print("🎉 Task completed: ", task_name)

## Mark task as failed
func fail_task(reason: String = ""):
	status = "failed"
	print("❌ Task failed: ", task_name, " - ", reason)

## Cancel the task
func cancel_task(reason: String = ""):
	status = "cancelled"
	
	# Remove all assigned ants
	for ant in assigned_ants.duplicate():
		remove_ant(ant)
	
	print("🚫 Task cancelled: ", task_name, " - ", reason)

# ==============================================================================
# RESOURCE MANAGEMENT
# ==============================================================================

## Check if required resources are available
func check_resource_requirements(resource_manager: Node) -> bool:
	if required_resources.is_empty():
		return true
	
	for resource_type in required_resources:
		var needed_amount = required_resources[resource_type]
		if not resource_manager.has_resource(resource_type, needed_amount):
			return false
	
	return true

## Consume required resources for task execution
func consume_resources(resource_manager: Node) -> bool:
	if not check_resource_requirements(resource_manager):
		return false
	
	for resource_type in resource_cost:
		var cost_amount = resource_cost[resource_type]
		resource_manager.consume_resource(resource_type, cost_amount)
	
	return true

## Distribute rewards to colony upon completion
func distribute_rewards():
	if resource_reward.is_empty():
		return
	
	# Find the colony to reward (through assigned ants)
	var colony = null
	if not assigned_ants.is_empty() and assigned_ants[0].home_colony:
		colony = assigned_ants[0].home_colony
	
	if colony == null:
		print("⚠️ No colony found to distribute rewards for task ", task_id)
		return
	
	# Distribute rewards
	for resource_type in resource_reward:
		var reward_amount = resource_reward[resource_type]
		colony.add_resource(resource_type, reward_amount)
		print("💰 Reward distributed: ", reward_amount, " ", resource_type)

# ==============================================================================
# DEPENDENCIES AND PREREQUISITES
# ==============================================================================

## Add a prerequisite task that must be completed first
func add_prerequisite(task: Task):
	if task and task not in prerequisite_tasks:
		prerequisite_tasks.append(task)
		task.dependent_tasks.append(self)

## Remove a prerequisite task
func remove_prerequisite(task: Task):
	if task in prerequisite_tasks:
		prerequisite_tasks.erase(task)
		task.dependent_tasks.erase(self)

## Check if all prerequisite tasks are completed
func check_prerequisites() -> bool:
	for prereq_task in prerequisite_tasks:
		if prereq_task.status != "completed":
			return false
	return true

## Get status including prerequisite check
func get_effective_status() -> String:
	if not check_prerequisites():
		return "blocked"
	return status

# ==============================================================================
# TASK TYPES AND VALIDATION
# ==============================================================================

## Validate task configuration
func validate_task() -> bool:
	if task_type.is_empty():
		push_error("Task type cannot be empty")
		return false
	
	if required_ants <= 0:
		push_error("Task must require at least 1 ant")
		return false
	
	if max_ants < required_ants:
		push_error("Max ants cannot be less than required ants")
		return false
	
	if estimated_time <= 0:
		push_error("Estimated time must be positive")
		return false
	
	return true

## Setup task based on type
func setup_task_type():
	match task_type:
		"gather":
			setup_gather_task()
		"build":
			setup_build_task()
		"fight":
			setup_combat_task()
		"patrol":
			setup_patrol_task()
		"transport":
			setup_transport_task()
		_:
			print("⚠️ Unknown task type: ", task_type)

## Setup gathering task
func setup_gather_task():
	description = "Gather resources from the environment"
	preferred_ant_types = ["Worker"]
	estimated_time = 5.0
	work_rate = 0.2
	can_be_interrupted = true
	
	# Set resource rewards based on location
	resource_reward = {"food": 5}

## Setup building task
func setup_build_task():
	description = "Construct buildings or expand tunnels"
	preferred_ant_types = ["Worker"]
	estimated_time = 15.0
	work_rate = 0.1
	can_be_interrupted = false
	requires_continuous_work = true
	
	# Building tasks usually require materials
	required_resources = {"materials": 10}

## Setup combat task
func setup_combat_task():
	description = "Attack enemies or defend territory"
	preferred_ant_types = ["Soldier"]
	estimated_time = 3.0
	work_rate = 0.3
	can_be_interrupted = true
	requires_continuous_work = false

## Setup patrol task
func setup_patrol_task():
	description = "Patrol and scout the area"
	preferred_ant_types = ["Soldier", "Scout"]
	estimated_time = 20.0
	work_rate = 0.05
	can_be_interrupted = true

## Setup transport task
func setup_transport_task():
	description = "Move resources between locations"
	preferred_ant_types = ["Worker"]
	estimated_time = 8.0
	work_rate = 0.15
	can_be_interrupted = true

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

## Generate unique task ID
func generate_task_id() -> int:
	# Simple ID generation - in real game, use better system
	return Time.get_time_dict_from_system().get("unix", 0) + randi() % 1000

## Get task priority score for sorting
func get_priority_score() -> int:
	var score = priority * 100
	
	if is_urgent:
		score += 500
	
	# Factor in deadline urgency
	if deadline > 0:
		var current_time = Time.get_time_dict_from_system().get("unix", 0.0)
		var time_left = deadline - current_time
		if time_left < 60:  # Less than 1 minute
			score += 200
		elif time_left < 300:  # Less than 5 minutes
			score += 100
	
	# Factor in progress (prefer tasks that are already started)
	if completion_progress > 0:
		score += int(completion_progress * 50)
	
	return score

## Get estimated completion time
func get_estimated_completion_time() -> float:
	if assigned_ants.is_empty():
		return estimated_time
	
	var effective_work_rate = work_rate * assigned_ants.size()
	var remaining_work = (1.0 - completion_progress) * estimated_time
	
	return remaining_work / effective_work_rate

## Check if task is overdue
func is_overdue() -> bool:
	if deadline <= 0:
		return false
	
	var current_time = Time.get_time_dict_from_system().get("unix", 0.0)
	return current_time > deadline

## Get task data for saving
func get_task_data() -> Dictionary:
	return {
		"task_id": task_id,
		"task_type": task_type,
		"task_name": task_name,
		"description": description,
		"priority": priority,
		"is_urgent": is_urgent,
		"creation_time": creation_time,
		"deadline": deadline,
		"target_location": target_location,
		"work_radius": work_radius,
		"required_resources": required_resources,
		"resource_cost": resource_cost,
		"resource_reward": resource_reward,
		"required_ants": required_ants,
		"max_ants": max_ants,
		"preferred_ant_types": preferred_ant_types,
		"completion_progress": completion_progress,
		"estimated_time": estimated_time,
		"actual_start_time": actual_start_time,
		"work_rate": work_rate,
		"status": status,
		"can_be_interrupted": can_be_interrupted,
		"requires_continuous_work": requires_continuous_work
	}

## Load task from saved data
func load_task_data(data: Dictionary):
	task_id = data.get("task_id", -1)
	task_type = data.get("task_type", "")
	task_name = data.get("task_name", "")
	description = data.get("description", "")
	priority = data.get("priority", 1)
	is_urgent = data.get("is_urgent", false)
	creation_time = data.get("creation_time", 0.0)
	deadline = data.get("deadline", -1.0)
	target_location = data.get("target_location", Vector2.ZERO)
	work_radius = data.get("work_radius", 50.0)
	required_resources = data.get("required_resources", {})
	resource_cost = data.get("resource_cost", {})
	resource_reward = data.get("resource_reward", {})
	required_ants = data.get("required_ants", 1)
	max_ants = data.get("max_ants", 1)
	preferred_ant_types = data.get("preferred_ant_types", [])
	completion_progress = data.get("completion_progress", 0.0)
	estimated_time = data.get("estimated_time", 10.0)
	actual_start_time = data.get("actual_start_time", -1.0)
	work_rate = data.get("work_rate", 1.0)
	status = data.get("status", "pending")
	can_be_interrupted = data.get("can_be_interrupted", true)
	requires_continuous_work = data.get("requires_continuous_work", true)

## Get debug info string
func get_debug_info() -> String:
	return "Task %d [%s]: %s | Progress: %.1f%% | Ants: %d/%d | Status: %s" % [
		task_id, task_type, task_name, completion_progress * 100, 
		assigned_ants.size(), required_ants, status
	]
