# ==============================================================================
# RESOURCE - Harvestable Materials and Consumables
# ==============================================================================
# Purpose: All harvestable materials (food, stone, wood, water) with
#          depletion, regeneration, and accessibility mechanics
# 
# Resources are scattered throughout the game world and provide:
# - Different types of materials needed by colonies
# - Varying accessibility and harvest rates
# - Regeneration over time for renewable resources
# - Strategic value for territory control
#
# Usage:
# - Placed on map during world generation
# - Targeted by gather tasks from colonies
# - Provides ongoing income when controlled
# - Creates strategic points of interest
# ==============================================================================

class_name GameResource
extends Node2D

# ==============================================================================
# SIGNALS
# ==============================================================================

signal resource_harvested(resource: GameResource, amount: int, harvester: Ant)
signal resource_depleted(resource: GameResource)
signal resource_regenerated(resource: GameResource, amount: int)
signal accessibility_changed(resource: GameResource, new_accessibility: float)

# ==============================================================================
# CORE PROPERTIES
# ==============================================================================

## Resource identification
@export var resource_type: String = "food"  # food, materials, water, rare_minerals
@export var resource_name: String = ""
@export var resource_id: int = -1

## Quantity and capacity
@export var quantity: int = 100
@export var max_quantity: int = 100
@export var base_quantity: int = 100  # Original amount when spawned
@export var minimum_quantity: int = 0  # Minimum before depletion

## Regeneration system
@export var is_renewable: bool = true
@export var regeneration_rate: float = 1.0  # Units per second
@export var regeneration_delay: float = 5.0  # Seconds after harvest before regen
@export var depletion_rate: float = 0.0  # Natural depletion rate
var last_harvest_time: float = 0.0
var regeneration_timer: float = 0.0

## Accessibility and harvest difficulty
@export var accessibility: float = 1.0  # 0.0 to 1.0 (how easy to harvest)
@export var base_accessibility: float = 1.0
@export var harvest_difficulty: float = 1.0  # Time multiplier for harvesting
@export var requires_tools: bool = false
@export var required_ant_type: String = ""  # Specific ant type needed, or empty for any

## Location and environment
@export var harvest_radius: float = 30.0  # How close ants need to be
@export var territory_value: int = 10  # Strategic value for territory control
@export var environmental_factors: Dictionary = {}  # weather, season effects
@export var is_contested: bool = false  # Currently being fought over

## Visual and audio
@export var depletion_visual_threshold: float = 0.3  # When to show depletion effects
@export var resource_color: Color = Color.GREEN
var visual_effects: Node2D
var audio_effects: AudioStreamPlayer2D

## Control and ownership
var controlling_colony: Colony
var harvesters: Array[Ant] = []
var max_harvesters: int = 3
var harvest_efficiency: float = 1.0

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func _ready():
	# Initialize resource
	setup_resource()
	setup_visuals()
	setup_regeneration_system()
	
	# Generate unique ID
	if resource_id == -1:
		resource_id = generate_resource_id()
	
	# Set resource name if empty
	if resource_name.is_empty():
		resource_name = resource_type.capitalize() + " Source"
	
	print("🌿 Resource spawned: ", resource_name, " (", quantity, "/", max_quantity, ")")

func _process(delta):
	# Update resource state
	update_regeneration(delta)
	update_depletion(delta)
	update_environmental_effects(delta)
	update_visuals()

# ==============================================================================
# SETUP AND INITIALIZATION
# ==============================================================================

## Setup resource based on type
func setup_resource():
	match resource_type:
		"food":
			setup_food_resource()
		"materials":
			setup_material_resource()
		"water":
			setup_water_resource()
		"rare_minerals":
			setup_rare_mineral_resource()
		_:
			setup_default_resource()

## Setup food resource (berries, seeds, etc.)
func setup_food_resource():
	is_renewable = true
	regeneration_rate = 2.0
	regeneration_delay = 3.0
	accessibility = 0.8
	harvest_difficulty = 1.0
	max_harvesters = 3
	resource_color = Color.GREEN
	territory_value = 15

## Setup material resource (wood, stone, etc.)
func setup_material_resource():
	is_renewable = false
	regeneration_rate = 0.0
	accessibility = 0.6
	harvest_difficulty = 1.5
	requires_tools = true
	max_harvesters = 2
	resource_color = Color.BROWN
	territory_value = 20

## Setup water resource
func setup_water_resource():
	is_renewable = true
	regeneration_rate = 3.0
	regeneration_delay = 1.0
	accessibility = 1.0
	harvest_difficulty = 0.8
	max_harvesters = 4
	resource_color = Color.BLUE
	territory_value = 25
	
	# Water is essential and never fully depletes
	minimum_quantity = 10

## Setup rare mineral resource
func setup_rare_mineral_resource():
	is_renewable = false
	regeneration_rate = 0.0
	accessibility = 0.3
	harvest_difficulty = 3.0
	requires_tools = true
	required_ant_type = "Worker"  # Only workers can mine
	max_harvesters = 1
	resource_color = Color.GOLD
	territory_value = 50

## Setup default resource properties
func setup_default_resource():
	is_renewable = true
	regeneration_rate = 1.0
	accessibility = 0.7
	harvest_difficulty = 1.0
	resource_color = Color.WHITE
	territory_value = 10

## Setup visual representation
func setup_visuals():
	# Create simple visual representation
	var sprite = ColorRect.new()
	sprite.size = Vector2(20, 20)
	sprite.position = Vector2(-10, -10)
	sprite.color = resource_color
	add_child(sprite)
	visual_effects = sprite
	
	# Add harvest radius indicator (for debugging)
	if Engine.is_editor_hint():
		var circle = create_radius_indicator()
		add_child(circle)

## Create radius indicator for editor
func create_radius_indicator() -> Node2D:
	var indicator = Node2D.new()
	# TODO: Add circle drawing logic for harvest radius
	return indicator

## Setup regeneration timing system
func setup_regeneration_system():
	regeneration_timer = regeneration_delay

# ==============================================================================
# HARVESTING SYSTEM
# ==============================================================================

## Attempt to harvest resources with an ant
func harvest(harvester: Ant, harvest_amount: int = -1) -> int:
	if harvester == null:
		push_warning("Attempted to harvest with null ant")
		return 0
	
	# Check if harvesting is possible
	if not can_be_harvested_by(harvester):
		return 0
	
	# Check if ant is close enough
	if global_position.distance_to(harvester.global_position) > harvest_radius:
		print("🚫 Ant too far from resource for harvesting")
		return 0
	
	# Calculate harvest amount
	if harvest_amount == -1:
		harvest_amount = calculate_harvest_amount(harvester)
	
	# Limit to available quantity
	harvest_amount = min(harvest_amount, quantity - minimum_quantity)
	
	if harvest_amount <= 0:
		return 0
	
	# Perform harvest
	quantity -= harvest_amount
	last_harvest_time = Time.get_time_dict_from_system().get("unix", 0.0)
	regeneration_timer = regeneration_delay
	
	# Add harvester to active list
	if harvester not in harvesters:
		harvesters.append(harvester)
	
	# Update accessibility (resources become harder to get as they're depleted)
	update_accessibility()
	
	# Emit signals
	resource_harvested.emit(self, harvest_amount, harvester)
	
	# Check for depletion
	if quantity <= minimum_quantity:
		handle_depletion()
	
	print("⛏️ Harvested ", harvest_amount, " ", resource_type, " (", quantity, " remaining)")
	return harvest_amount

## Check if this resource can be harvested by the ant
func can_be_harvested_by(harvester: Ant) -> bool:
	# Check if resource is depleted
	if quantity <= minimum_quantity:
		return false
	
	# Check ant type requirement
	if not required_ant_type.is_empty() and harvester.ant_type != required_ant_type:
		return false
	
	# Check if harvester limit reached
	if harvesters.size() >= max_harvesters and harvester not in harvesters:
		return false
	
	# Check tool requirements
	if requires_tools:
		# TODO: Check if ant has required tools
		pass
	
	return true

## Calculate how much an ant can harvest
func calculate_harvest_amount(harvester: Ant) -> int:
	var base_amount = 5  # Base harvest amount
	
	# Apply accessibility modifier
	base_amount = int(base_amount * accessibility)
	
	# Apply ant-specific bonuses
	match harvester.ant_type:
		"Worker":
			base_amount = int(base_amount * 1.2)  # Workers are efficient
		"Soldier":
			base_amount = int(base_amount * 0.8)  # Soldiers less efficient
	
	# Apply harvest efficiency from controlling colony
	if controlling_colony:
		base_amount = int(base_amount * controlling_colony.resource_efficiency)
	
	# Apply difficulty modifier
	base_amount = int(base_amount / harvest_difficulty)
	
	return max(1, base_amount)

## Remove harvester from active list
func remove_harvester(harvester: Ant):
	if harvester in harvesters:
		harvesters.erase(harvester)

# ==============================================================================
# REGENERATION AND DEPLETION
# ==============================================================================

## Update resource regeneration
func update_regeneration(delta: float):
	if not is_renewable or quantity >= max_quantity:
		return
	
	# Check if regeneration delay has passed
	regeneration_timer -= delta
	if regeneration_timer > 0:
		return
	
	# Regenerate resources
	var regen_amount = regeneration_rate * delta
	var old_quantity = quantity
	quantity = min(max_quantity, quantity + regen_amount)
	
	if quantity > old_quantity + 0.1:  # Significant regeneration
		resource_regenerated.emit(self, int(quantity - old_quantity))
		update_accessibility()

## Update natural depletion
func update_depletion(delta: float):
	if depletion_rate <= 0:
		return
	
	var depletion_amount = depletion_rate * delta
	quantity = max(minimum_quantity, quantity - depletion_amount)
	
	if quantity <= minimum_quantity:
		handle_depletion()

## Handle resource depletion
func handle_depletion():
	if quantity > minimum_quantity:
		return
	
	# Remove all harvesters
	for harvester in harvesters.duplicate():
		remove_harvester(harvester)
	
	# Update visual state
	update_visuals()
	
	# Emit depletion signal
	resource_depleted.emit(self)
	
	print("💀 Resource depleted: ", resource_name)
	
	# For non-renewable resources, consider removal
	if not is_renewable:
		queue_removal()

## Queue resource for removal when depleted
func queue_removal():
	# Wait a bit before removing to allow for visual effects
	await get_tree().create_timer(2.0).timeout
	
	print("🗑️ Removing depleted resource: ", resource_name)
	queue_free()

## Update accessibility based on current state
func update_accessibility():
	var quantity_ratio = float(quantity) / float(max_quantity)
	
	# Accessibility decreases as resource is depleted
	accessibility = base_accessibility * quantity_ratio
	
	# But never go below 0.1 for balance
	accessibility = max(0.1, accessibility)
	
	accessibility_changed.emit(self, accessibility)

# ==============================================================================
# ENVIRONMENTAL EFFECTS
# ==============================================================================

## Update environmental effects on the resource
func update_environmental_effects(delta: float):
	# Apply weather effects
	apply_weather_effects()
	
	# Apply seasonal effects
	apply_seasonal_effects()
	
	# Apply territory control effects
	apply_territory_effects()

## Apply weather effects to resource
func apply_weather_effects():
	var weather = environmental_factors.get("weather", "clear")
	
	match weather:
		"rain":
			if resource_type == "water":
				regeneration_rate *= 1.5
			elif resource_type == "food":
				regeneration_rate *= 1.2
		"drought":
			if resource_type == "water":
				depletion_rate += 0.5
			accessibility *= 0.8
		"storm":
			accessibility *= 0.6
			harvest_difficulty *= 1.3

## Apply seasonal effects
func apply_seasonal_effects():
	var season = environmental_factors.get("season", "spring")
	
	match season:
		"spring":
			if resource_type == "food":
				regeneration_rate *= 1.3
		"summer":
			if resource_type == "water":
				depletion_rate += 0.2
		"autumn":
			if resource_type == "food":
				max_quantity *= 1.2  # Harvest season
		"winter":
			regeneration_rate *= 0.5
			accessibility *= 0.7

## Apply territory control effects
func apply_territory_effects():
	if controlling_colony:
		# Controlled resources are more accessible and efficient
		harvest_efficiency = 1.2
		accessibility = min(1.0, accessibility * 1.1)
	else:
		harvest_efficiency = 1.0

# ==============================================================================
# TERRITORY CONTROL
# ==============================================================================

## Set controlling colony for this resource
func set_controlling_colony(colony: Colony):
	if controlling_colony == colony:
		return
	
	var old_colony = controlling_colony
	controlling_colony = colony
	
	# Update territory effects
	apply_territory_effects()
	
	print("🏴 Resource ", resource_name, " now controlled by ", colony.colony_name if colony else "nobody")

## Check if resource is being contested
func check_contested_status():
	# Count colonies with ants near this resource
	var nearby_colonies = get_nearby_colonies()
	
	is_contested = nearby_colonies.size() > 1
	
	if is_contested:
		accessibility *= 0.7  # Contested resources are harder to harvest
		print("⚔️ Resource contested: ", resource_name)

## Get colonies with ants near this resource
func get_nearby_colonies() -> Array[Colony]:
	var colonies: Array[Colony] = []
	
	for harvester in harvesters:
		if harvester.home_colony and harvester.home_colony not in colonies:
			colonies.append(harvester.home_colony)
	
	return colonies

# ==============================================================================
# VISUAL UPDATES
# ==============================================================================

## Update visual representation based on current state
func update_visuals():
	if visual_effects == null:
		return
	
	var quantity_ratio = float(quantity) / float(max_quantity)
	
	# Update color intensity based on quantity
	var current_color = resource_color
	current_color.a = 0.3 + (quantity_ratio * 0.7)  # Fade as depleted
	
	# Update visual effects based on node type
	if visual_effects.has_method("set_modulate"):
		visual_effects.modulate = current_color
	elif visual_effects.has_method("set_color"):
		visual_effects.color = current_color
	
	# Update size based on quantity
	var scale_factor = 0.5 + (quantity_ratio * 0.5)
	visual_effects.scale = Vector2(scale_factor, scale_factor)
	
	# Add depletion effects
	if quantity_ratio < depletion_visual_threshold:
		add_depletion_effects()

## Add visual effects for depleted resources
func add_depletion_effects():
	# TODO: Add particle effects, different sprites, etc.
	pass

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

## Generate unique resource ID
func generate_resource_id() -> int:
	return Time.get_time_dict_from_system().get("unix", 0) + randi() % 10000

## Get resource value for AI decision making
func get_strategic_value() -> int:
	var base_value = territory_value
	
	# Factor in quantity and accessibility
	var quantity_ratio = float(quantity) / float(max_quantity)
	var value_modifier = quantity_ratio * accessibility
	
	return int(base_value * value_modifier)

## Check if resource is worth fighting for
func is_worth_fighting_for() -> bool:
	return get_strategic_value() > 20 and quantity > minimum_quantity * 2

## Get resource data for saving
func get_resource_data() -> Dictionary:
	return {
		"resource_id": resource_id,
		"resource_type": resource_type,
		"resource_name": resource_name,
		"position": global_position,
		"quantity": quantity,
		"max_quantity": max_quantity,
		"base_quantity": base_quantity,
		"minimum_quantity": minimum_quantity,
		"is_renewable": is_renewable,
		"regeneration_rate": regeneration_rate,
		"regeneration_delay": regeneration_delay,
		"depletion_rate": depletion_rate,
		"accessibility": accessibility,
		"base_accessibility": base_accessibility,
		"harvest_difficulty": harvest_difficulty,
		"requires_tools": requires_tools,
		"required_ant_type": required_ant_type,
		"harvest_radius": harvest_radius,
		"territory_value": territory_value,
		"is_contested": is_contested,
		"controlling_colony_id": controlling_colony.colony_id if controlling_colony else -1,
		"environmental_factors": environmental_factors
	}

## Load resource from saved data
func load_resource_data(data: Dictionary):
	resource_id = data.get("resource_id", -1)
	resource_type = data.get("resource_type", "food")
	resource_name = data.get("resource_name", "")
	global_position = data.get("position", Vector2.ZERO)
	quantity = data.get("quantity", 100)
	max_quantity = data.get("max_quantity", 100)
	base_quantity = data.get("base_quantity", 100)
	minimum_quantity = data.get("minimum_quantity", 0)
	is_renewable = data.get("is_renewable", true)
	regeneration_rate = data.get("regeneration_rate", 1.0)
	regeneration_delay = data.get("regeneration_delay", 5.0)
	depletion_rate = data.get("depletion_rate", 0.0)
	accessibility = data.get("accessibility", 1.0)
	base_accessibility = data.get("base_accessibility", 1.0)
	harvest_difficulty = data.get("harvest_difficulty", 1.0)
	requires_tools = data.get("requires_tools", false)
	required_ant_type = data.get("required_ant_type", "")
	harvest_radius = data.get("harvest_radius", 30.0)
	territory_value = data.get("territory_value", 10)
	is_contested = data.get("is_contested", false)
	environmental_factors = data.get("environmental_factors", {})

## Get debug info string
func get_debug_info() -> String:
	return "Resource: %s | Type: %s | Qty: %d/%d | Access: %.2f | Harvesters: %d/%d" % [
		resource_name, resource_type, quantity, max_quantity, 
		accessibility, harvesters.size(), max_harvesters
	]
