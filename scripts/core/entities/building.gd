# ==============================================================================
# BUILDING - Colony Structures and Rooms
# ==============================================================================
# Purpose: Buildings and rooms within ant colonies with specific functions,
#          upgrade paths, and worker management
# 
# Buildings are the infrastructure of your ant colony:
# - Different types serve different purposes (storage, breeding, defense)
# - Can be upgraded to improve efficiency
# - Require workers to operate at full capacity
# - Provide bonuses and unlock new capabilities
#
# Usage:
# - Constructed by Colony through build tasks
# - Managed by workers assigned to specific roles
# - Upgradeable with resources and research
# - Strategic choices affect colony development
# ==============================================================================

class_name Building
extends Node2D

# ==============================================================================
# SIGNALS
# ==============================================================================

signal construction_completed(building: Building)
signal construction_progress_updated(building: Building, progress: float)
signal building_upgraded(building: Building, old_level: int, new_level: int)
signal building_destroyed(building: Building)
signal worker_assigned(building: Building, worker: Ant)
signal worker_removed(building: Building, worker: Ant)
signal production_completed(building: Building, product_type: String, amount: int)

# ==============================================================================
# CORE PROPERTIES
# ==============================================================================

## Building identification
@export var building_type: String = "Storage"  # Storage, Nursery, Barracks, Workshop, etc.
@export var building_name: String = ""
@export var building_id: int = -1

## Health and durability
@export var max_health: int = 100
@export var current_health: int = 100
@export var armor: int = 0
@export var is_destroyed: bool = false

## Construction and upgrade
@export var construction_progress: float = 0.0  # 0.0 to 1.0
@export var is_under_construction: bool = true
@export var construction_time: float = 30.0
@export var building_level: int = 0
@export var max_level: int = 3

## Capacity and efficiency
@export var max_capacity: int = 100
@export var current_occupancy: int = 0
@export var efficiency: float = 1.0
@export var base_efficiency: float = 1.0

## Resource requirements and costs
@export var resource_cost: Dictionary = {}  # Cost to build
@export var upgrade_cost: Dictionary = {}  # Cost to upgrade
@export var maintenance_cost: Dictionary = {}  # Ongoing cost per day
@export var upkeep_frequency: float = 60.0  # Seconds between upkeep payments

## Worker management
@export var required_workers: int = 0
@export var max_workers: int = 2
var assigned_workers: Array[Ant] = []
var worker_efficiency: float = 1.0

## Production and function
@export var production_rate: float = 1.0  # Units per second
@export var production_type: String = ""  # What this building produces
@export var processing_queue: Array[Dictionary] = []
var last_production_time: float = 0.0
var production_timer: float = 0.0

## Colony integration
var owning_colony: Colony
@export var provides_bonus: Dictionary = {}  # Bonuses to colony
@export var unlocks_research: Array[String] = []  # Research this building enables
@export var species_bonuses: Dictionary = {}  # Species-specific bonuses

## Positioning and territory
@export var footprint_size: Vector2 = Vector2(32, 32)
@export var required_adjacency: Array[String] = []  # Buildings that must be adjacent
@export var blocks_placement: bool = true  # Prevents other buildings here

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func _ready():
	# Initialize building
	setup_building()
	setup_visuals()
	setup_production_system()
	
	# Generate unique ID
	if building_id == -1:
		building_id = generate_building_id()
	
	# Set building name if empty
	if building_name.is_empty():
		building_name = building_type
	
	# Start construction if needed
	if is_under_construction:
		start_construction()
	else:
		complete_construction()
	
	print("🏗️ Building created: ", building_name, " at ", global_position)

func _process(delta):
	# Update building systems
	update_construction(delta)
	update_production(delta)
	update_worker_management(delta)
	update_maintenance(delta)

# ==============================================================================
# SETUP AND INITIALIZATION
# ==============================================================================

## Setup building based on type
func setup_building():
	match building_type:
		"Storage":
			setup_storage_building()
		"Nursery":
			setup_nursery_building()
		"Barracks":
			setup_barracks_building()
		"Workshop":
			setup_workshop_building()
		"Food_Storage":
			setup_food_storage_building()
		"Tunnel":
			setup_tunnel_building()
		"Queen_Chamber":
			setup_queen_chamber()
		_:
			setup_default_building()

## Setup storage building
func setup_storage_building():
	max_capacity = 200
	required_workers = 1
	max_workers = 2
	construction_time = 20.0
	resource_cost = {"materials": 30, "food": 10}
	provides_bonus = {"storage_capacity": 200}
	production_type = "storage"
	max_health = 80

## Setup nursery building
func setup_nursery_building():
	max_capacity = 50  # Larvae capacity
	required_workers = 2
	max_workers = 3
	construction_time = 40.0
	resource_cost = {"materials": 50, "food": 30}
	provides_bonus = {"population_growth": 1.5, "larvae_production": 2}
	production_type = "larvae"
	production_rate = 0.1  # Larvae per second
	max_health = 60
	unlocks_research = ["Advanced Breeding"]

## Setup barracks building
func setup_barracks_building():
	max_capacity = 20  # Soldier training capacity
	required_workers = 1
	max_workers = 2
	construction_time = 35.0
	resource_cost = {"materials": 40, "food": 25}
	provides_bonus = {"soldier_training": 1.3, "defense": 10}
	production_type = "soldier_training"
	max_health = 120
	unlocks_research = ["Combat Tactics", "Advanced Weapons"]

## Setup workshop building
func setup_workshop_building():
	max_capacity = 100  # Material processing capacity
	required_workers = 2
	max_workers = 4
	construction_time = 45.0
	resource_cost = {"materials": 60, "food": 20}
	provides_bonus = {"construction_speed": 1.2, "material_efficiency": 1.3}
	production_type = "tools"
	production_rate = 0.05
	max_health = 90
	unlocks_research = ["Advanced Tools", "Efficient Construction"]

## Setup food storage building
func setup_food_storage_building():
	max_capacity = 500  # Food storage capacity
	required_workers = 1
	max_workers = 2
	construction_time = 25.0
	resource_cost = {"materials": 35, "food": 15}
	provides_bonus = {"food_storage": 500, "food_preservation": 1.1}
	production_type = "food_preservation"
	max_health = 70

## Setup tunnel building
func setup_tunnel_building():
	max_capacity = 0  # Tunnels don't store things
	required_workers = 0
	max_workers = 0
	construction_time = 15.0
	resource_cost = {"materials": 15}
	provides_bonus = {"movement_speed": 1.2, "connectivity": 1}
	max_health = 50
	blocks_placement = false  # Tunnels don't block other buildings

## Setup queen chamber (special building)
func setup_queen_chamber():
	max_capacity = 1  # Only one queen
	required_workers = 3
	max_workers = 5
	construction_time = 60.0
	resource_cost = {"materials": 100, "food": 80, "rare_minerals": 10}
	provides_bonus = {"queen_safety": 1, "colony_coordination": 1.5, "research_speed": 1.2}
	production_type = "colony_management"
	max_health = 200
	unlocks_research = ["Royal Genetics", "Colony Expansion", "Advanced Coordination"]

## Setup default building properties
func setup_default_building():
	max_capacity = 50
	required_workers = 1
	max_workers = 2
	construction_time = 30.0
	resource_cost = {"materials": 25, "food": 10}
	max_health = 75

## Setup visual representation
func setup_visuals():
	# Create simple visual representation
	var sprite = ColorRect.new()
	sprite.size = footprint_size
	sprite.position = -footprint_size / 2
	
	# Color based on building type
	match building_type:
		"Storage":
			sprite.color = Color.BROWN
		"Nursery":
			sprite.color = Color.PINK
		"Barracks":
			sprite.color = Color.RED
		"Workshop":
			sprite.color = Color.ORANGE
		"Food_Storage":
			sprite.color = Color.GREEN
		"Tunnel":
			sprite.color = Color.GRAY
		"Queen_Chamber":
			sprite.color = Color.GOLD
		_:
			sprite.color = Color.WHITE
	
	add_child(sprite)
	
	# Add construction overlay if under construction
	if is_under_construction:
		add_construction_overlay()

## Add construction overlay visual
func add_construction_overlay():
	var overlay = ColorRect.new()
	overlay.size = footprint_size
	overlay.position = -footprint_size / 2
	overlay.color = Color(1, 1, 1, 0.5)
	overlay.name = "ConstructionOverlay"
	add_child(overlay)

## Setup production system
func setup_production_system():
	production_timer = 1.0 / production_rate if production_rate > 0 else 0
	last_production_time = Time.get_time_dict_from_system().get("unix", 0.0)

# ==============================================================================
# CONSTRUCTION SYSTEM
# ==============================================================================

## Start building construction
func start_construction():
	is_under_construction = true
	construction_progress = 0.0
	current_health = max_health * 0.3  # Partially built
	
	print("🔨 Construction started: ", building_name)

## Update construction progress
func update_construction(delta: float):
	if not is_under_construction:
		return
	
	# Calculate construction speed based on assigned workers
	var construction_speed = calculate_construction_speed()
	
	# Update progress
	var old_progress = construction_progress
	construction_progress += (construction_speed / construction_time) * delta
	construction_progress = min(1.0, construction_progress)
	
	# Update health as construction progresses
	current_health = int(max_health * (0.3 + construction_progress * 0.7))
	
	# Emit progress signal
	if abs(construction_progress - old_progress) > 0.01:
		construction_progress_updated.emit(self, construction_progress)
	
	# Check for completion
	if construction_progress >= 1.0:
		complete_construction()

## Calculate construction speed based on workers
func calculate_construction_speed() -> float:
	if assigned_workers.is_empty():
		return 0.1  # Very slow progress without workers
	
	var speed = 0.0
	for worker in assigned_workers:
		if worker.current_state == "working":
			speed += 1.0  # Each working ant contributes
	
	# Apply colony construction speed bonus
	if owning_colony:
		speed *= owning_colony.construction_speed
	
	return speed

## Complete building construction
func complete_construction():
	is_under_construction = false
	construction_progress = 1.0
	current_health = max_health
	
	# Remove construction overlay
	var overlay = get_node_or_null("ConstructionOverlay")
	if overlay:
		overlay.queue_free()
	
	# Apply bonuses to colony
	apply_bonuses_to_colony()
	
	# Unlock research
	unlock_research_options()
	
	construction_completed.emit(self)
	print("🎉 Construction completed: ", building_name)

# ==============================================================================
# WORKER MANAGEMENT
# ==============================================================================

## Assign a worker to this building
func assign_worker(worker: Ant) -> bool:
	if worker == null:
		push_warning("Attempted to assign null worker to building")
		return false
	
	# Check if worker is already assigned
	if worker in assigned_workers:
		print("⚠️ Worker already assigned to building")
		return false
	
	# Check capacity
	if assigned_workers.size() >= max_workers:
		print("⚠️ Building at maximum worker capacity")
		return false
	
	# Check if worker is suitable for this building
	if not can_worker_be_assigned(worker):
		return false
	
	# Assign worker
	assigned_workers.append(worker)
	current_occupancy += 1
	
	# Update efficiency
	update_worker_efficiency()
	
	worker_assigned.emit(self, worker)
	print("👷 Worker assigned to ", building_name, ": Ant #", worker.ant_id)
	
	return true

## Remove worker from building
func remove_worker(worker: Ant) -> bool:
	if worker not in assigned_workers:
		return false
	
	assigned_workers.erase(worker)
	current_occupancy -= 1
	
	# Update efficiency
	update_worker_efficiency()
	
	worker_removed.emit(self, worker)
	print("👷 Worker removed from ", building_name, ": Ant #", worker.ant_id)
	
	return true

## Check if worker can be assigned to this building
func can_worker_be_assigned(worker: Ant) -> bool:
	# Check building type requirements
	match building_type:
		"Barracks":
			return worker.ant_type in ["Soldier", "Worker"]
		"Nursery":
			return worker.ant_type in ["Worker", "Queen"]
		"Workshop":
			return worker.ant_type == "Worker"
		_:
			return true  # Most buildings accept any worker

## Update worker efficiency based on assigned workers
func update_worker_efficiency():
	if assigned_workers.is_empty():
		worker_efficiency = 0.0
		return
	
	# Base efficiency from having workers
	worker_efficiency = 0.5 + (float(assigned_workers.size()) / float(max_workers)) * 0.5
	
	# Bonus for having required workers
	if assigned_workers.size() >= required_workers:
		worker_efficiency *= 1.2
	
	# Apply overall efficiency
	efficiency = base_efficiency * worker_efficiency

## Update worker management
func update_worker_management(delta: float):
	# Check if workers are still valid
	for worker in assigned_workers.duplicate():
		if not is_instance_valid(worker) or worker.home_colony != owning_colony:
			remove_worker(worker)

# ==============================================================================
# PRODUCTION SYSTEM
# ==============================================================================

## Update building production
func update_production(delta: float):
	if is_under_construction or production_type.is_empty():
		return
	
	production_timer -= delta
	if production_timer <= 0:
		produce_output()
		production_timer = 1.0 / (production_rate * efficiency) if production_rate > 0 else 1.0

## Produce building output
func produce_output():
	if not can_produce():
		return
	
	match production_type:
		"storage":
			# Storage buildings don't produce, they just store
			pass
		"larvae":
			produce_larvae()
		"soldier_training":
			enhance_soldier_training()
		"tools":
			produce_tools()
		"food_preservation":
			preserve_food()
		"colony_management":
			enhance_colony_management()

## Check if building can produce
func can_produce() -> bool:
	# Must have minimum workers for production
	if assigned_workers.size() < required_workers:
		return false
	
	# Must not be damaged too severely
	if float(current_health) / float(max_health) < 0.3:
		return false
	
	return true

## Produce larvae (Nursery)
func produce_larvae():
	if owning_colony == null:
		return
	
	var larvae_produced = int(production_rate * efficiency * assigned_workers.size())
	owning_colony.add_resource("larvae", larvae_produced)
	
	production_completed.emit(self, "larvae", larvae_produced)
	print("👶 Nursery produced ", larvae_produced, " larvae")

## Enhance soldier training (Barracks)
func enhance_soldier_training():
	# Improve training efficiency for soldiers in colony
	for ant in assigned_workers:
		if ant.ant_type == "Soldier":
			ant.attack_power = int(ant.attack_power * 1.01)  # Small incremental improvement
	
	production_completed.emit(self, "soldier_training", 1)

## Produce tools (Workshop)
func produce_tools():
	if owning_colony == null:
		return
	
	var tools_produced = int(production_rate * efficiency)
	owning_colony.add_resource("tools", tools_produced)
	
	production_completed.emit(self, "tools", tools_produced)
	print("🔧 Workshop produced ", tools_produced, " tools")

## Preserve food (Food Storage)
func preserve_food():
	# Reduce food spoilage in colony
	if owning_colony and owning_colony.resources.has("food"):
		var preservation_bonus = int(efficiency * 2)
		# This would prevent food loss rather than generate food
		print("🥫 Food preservation active: +", preservation_bonus, " efficiency")

## Enhance colony management (Queen Chamber)
func enhance_colony_management():
	if owning_colony == null:
		return
	
	# Boost research and coordination
	owning_colony.research_points_per_second *= (1.0 + efficiency * 0.1)
	
	production_completed.emit(self, "colony_management", 1)

# ==============================================================================
# UPGRADE SYSTEM
# ==============================================================================

## Attempt to upgrade building
func upgrade_building() -> bool:
	if building_level >= max_level:
		print("⚠️ Building already at maximum level")
		return false
	
	if is_under_construction:
		print("⚠️ Cannot upgrade building under construction")
		return false
	
	# Check upgrade cost
	var cost = get_upgrade_cost()
	if owning_colony == null or not owning_colony.can_afford_resources(cost):
		print("⚠️ Cannot afford upgrade cost")
		return false
	
	# Consume resources
	owning_colony.consume_resources(cost)
	
	# Perform upgrade
	var old_level = building_level
	building_level += 1
	apply_upgrade_benefits()
	
	building_upgraded.emit(self, old_level, building_level)
	print("⬆️ Building upgraded: ", building_name, " to level ", building_level)
	
	return true

## Get upgrade cost for current level
func get_upgrade_cost() -> Dictionary:
	var base_cost = resource_cost.duplicate()
	var multiplier = 1.5 + (building_level * 0.3)
	
	for resource_type in base_cost:
		base_cost[resource_type] = int(base_cost[resource_type] * multiplier)
	
	return base_cost

## Apply benefits from upgrade
func apply_upgrade_benefits():
	# Increase capacity and efficiency
	max_capacity = int(max_capacity * 1.2)
	base_efficiency *= 1.15
	max_health = int(max_health * 1.1)
	current_health = max_health  # Repair to full on upgrade
	
	# Increase production rate
	production_rate *= 1.1
	
	# Update worker efficiency
	update_worker_efficiency()
	
	# Re-apply bonuses to colony
	apply_bonuses_to_colony()

# ==============================================================================
# COLONY INTEGRATION
# ==============================================================================

## Apply building bonuses to owning colony
func apply_bonuses_to_colony():
	if owning_colony == null or is_under_construction:
		return
	
	# Apply bonuses from provides_bonus dictionary
	for bonus_type in provides_bonus:
		var bonus_value = provides_bonus[bonus_type] * efficiency
		apply_specific_bonus(bonus_type, bonus_value)

## Apply specific bonus to colony
func apply_specific_bonus(bonus_type: String, value: float):
	if owning_colony == null:
		return
	
	match bonus_type:
		"storage_capacity":
			if building_type == "Storage":
				owning_colony.max_food_storage += int(value)
			elif building_type == "Food_Storage":
				owning_colony.max_food_storage += int(value)
		"population_growth":
			owning_colony.population_growth_rate *= value
		"defense":
			owning_colony.defense_bonus += value * 0.1
		"construction_speed":
			owning_colony.construction_speed *= value
		"research_speed":
			owning_colony.research_points_per_second *= value

## Unlock research options
func unlock_research_options():
	if owning_colony == null:
		return
	
	for research in unlocks_research:
		if research not in owning_colony.available_research:
			owning_colony.available_research.append(research)
			print("🔓 Research unlocked: ", research)

# ==============================================================================
# DAMAGE AND MAINTENANCE
# ==============================================================================

## Take damage from attacks or deterioration
func take_damage(damage: int):
	current_health = max(0, current_health - damage)
	
	# Update efficiency based on damage
	var health_ratio = float(current_health) / float(max_health)
	efficiency = base_efficiency * health_ratio * worker_efficiency
	
	# Check for destruction
	if current_health <= 0:
		destroy_building()
	
	print("💥 Building took ", damage, " damage: ", current_health, "/", max_health)

## Repair building
func repair_building(repair_amount: int):
	current_health = min(max_health, current_health + repair_amount)
	
	# Update efficiency
	var health_ratio = float(current_health) / float(max_health)
	efficiency = base_efficiency * health_ratio * worker_efficiency
	
	print("🔧 Building repaired: ", current_health, "/", max_health)

## Handle building destruction
func destroy_building():
	is_destroyed = true
	
	# Remove all workers
	for worker in assigned_workers.duplicate():
		remove_worker(worker)
	
	# Remove from colony
	if owning_colony:
		owning_colony.buildings.erase(self)
	
	building_destroyed.emit(self)
	print("💥 Building destroyed: ", building_name)
	
	# Create debris/ruins
	create_ruins()
	
	queue_free()

## Create ruins when building is destroyed
func create_ruins():
	# TODO: Create ruins object that can be salvaged for materials
	pass

## Update maintenance costs
func update_maintenance(delta: float):
	# Simple maintenance system - costs resources periodically
	if maintenance_cost.is_empty() or is_under_construction:
		return
	
	# Check if it's time for maintenance
	var current_time = Time.get_time_dict_from_system().get("unix", 0.0)
	if current_time - last_production_time > upkeep_frequency:
		pay_maintenance_cost()
		last_production_time = current_time

## Pay maintenance costs
func pay_maintenance_cost():
	if owning_colony == null:
		return
	
	if owning_colony.can_afford_resources(maintenance_cost):
		owning_colony.consume_resources(maintenance_cost)
	else:
		# Cannot pay maintenance - reduce efficiency
		efficiency *= 0.9
		print("⚠️ ", building_name, " maintenance overdue - efficiency reduced")

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

## Generate unique building ID
func generate_building_id() -> int:
	return Time.get_time_dict_from_system().get("unix", 0) + randi() % 10000

## Check if building can function (has workers, not too damaged)
func can_function() -> bool:
	return not is_under_construction and not is_destroyed and current_health > 0

## Get building data for saving
func get_building_data() -> Dictionary:
	return {
		"building_id": building_id,
		"building_type": building_type,
		"building_name": building_name,
		"position": global_position,
		"current_health": current_health,
		"max_health": max_health,
		"building_level": building_level,
		"construction_progress": construction_progress,
		"is_under_construction": is_under_construction,
		"is_destroyed": is_destroyed,
		"efficiency": efficiency,
		"current_occupancy": current_occupancy,
		"assigned_worker_ids": assigned_workers.map(func(ant): return ant.ant_id),
		"production_timer": production_timer
	}

## Load building from saved data
func load_building_data(data: Dictionary):
	building_id = data.get("building_id", -1)
	building_type = data.get("building_type", "Storage")
	building_name = data.get("building_name", "")
	global_position = data.get("position", Vector2.ZERO)
	current_health = data.get("current_health", max_health)
	max_health = data.get("max_health", 100)
	building_level = data.get("building_level", 0)
	construction_progress = data.get("construction_progress", 0.0)
	is_under_construction = data.get("is_under_construction", false)
	is_destroyed = data.get("is_destroyed", false)
	efficiency = data.get("efficiency", 1.0)
	current_occupancy = data.get("current_occupancy", 0)
	production_timer = data.get("production_timer", 0.0)

## Get debug info string
func get_debug_info() -> String:
	return "Building: %s [L%d] | Health: %d/%d | Workers: %d/%d | Efficiency: %.2f" % [
		building_name, building_level, current_health, max_health, 
		assigned_workers.size(), max_workers, efficiency
	]
