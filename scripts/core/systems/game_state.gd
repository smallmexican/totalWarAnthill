# ==============================================================================
# GAME_STATE - Global Game Management System
# ==============================================================================
# Purpose: Central coordination for match state, save/load, victory conditions,
#          and integration with the skirmish setup configuration
# 
# GameState is the brain of your game that handles:
# - Match configuration from SkirmishSetupMenu
# - Colony management for player and AI
# - Turn/time progression and game flow
# - Save/load system and persistence
# - Victory condition checking
#
# Usage:
# - Singleton (autoload) accessible from anywhere
# - Receives config from SkirmishSetupMenu
# - Coordinates all gameplay systems
# - Provides save/load functionality
# ==============================================================================

class_name GameState
extends Node

# ==============================================================================
# SIGNALS
# ==============================================================================

signal game_started(config: Dictionary)
signal game_paused(is_paused: bool)
signal game_ended(winner: Colony, condition: String)
signal colony_created(colony: Colony)
signal colony_destroyed(colony: Colony)
signal research_completed(colony: Colony, tech: String)
signal resource_node_discovered(resource: GameResource)
signal turn_completed(turn_number: int)

# ==============================================================================
# GAME CONFIGURATION
# ==============================================================================

## Match configuration from SkirmishSetupMenu
var match_config: Dictionary = {}
var game_mode: String = "skirmish"  # skirmish, campaign, tutorial
var difficulty: String = "normal"

## Player and AI setup
var player_species: String = "Fire Ant"
var opponent_species: String = "Carpenter Ant"
var opponent_difficulty: String = "Normal"
var selected_map: String = "Garden Valley"

# ==============================================================================
# GAME TIME AND PROGRESSION
# ==============================================================================

## Time management
var game_time: float = 0.0
var real_time_elapsed: float = 0.0
var time_scale: float = 1.0
var is_paused: bool = false

## Turn-based elements (for some game mechanics)
var turn_number: int = 0
var turn_duration: float = 60.0  # Seconds per "turn"
var turn_timer: float = 0.0

## Game phases
var current_phase: String = "early_game"  # early_game, mid_game, late_game, end_game
var phase_duration: Dictionary = {
	"early_game": 300.0,  # 5 minutes
	"mid_game": 600.0,    # 10 minutes
	"late_game": 900.0    # 15 minutes
}

# ==============================================================================
# COLONIES AND FACTIONS
# ==============================================================================

## Colony management
var player_colonies: Array[Colony] = []
var ai_colonies: Array[Colony] = []
var all_colonies: Array[Colony] = []
var active_colony_count: int = 0

## AI controllers
var ai_controllers: Array[AIController] = []

# ==============================================================================
# WORLD STATE
# ==============================================================================

## Map and resources
var world_resources: Array[Resource] = []
var discovered_resources: Array[Resource] = []
var contested_territories: Array[Vector2] = []

## Global modifiers
var global_weather: String = "clear"
var global_season: String = "spring"
var global_events: Array[Dictionary] = []

# ==============================================================================
# VICTORY CONDITIONS
# ==============================================================================

## Victory condition types
var victory_conditions: Dictionary = {
	"conquest": {"enabled": true, "target": "eliminate_all_enemies"},
	"economic": {"enabled": true, "target": "resource_threshold", "amount": 5000},
	"population": {"enabled": true, "target": "population_threshold", "amount": 500},
	"time": {"enabled": false, "target": "time_limit", "duration": 1800.0}
}

var victory_progress: Dictionary = {}
var game_ended: bool = false
var winner: Colony = null
var victory_condition_met: String = ""

# ==============================================================================
# SAVE/LOAD SYSTEM
# ==============================================================================

## Save game data
var save_file_path: String = "user://savegame.save"
var autosave_enabled: bool = true
var autosave_interval: float = 300.0  # 5 minutes
var last_autosave_time: float = 0.0

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func _ready():
	# Initialize game state manager
	setup_autoload_connections()
	reset_game_state()
	
	print("🎮 GameState manager initialized")

func _process(delta):
	# Update game state
	update_game_time(delta)
	update_turn_system(delta)
	update_victory_conditions()
	update_autosave(delta)
	update_global_events(delta)

# ==============================================================================
# GAME INITIALIZATION
# ==============================================================================

## Initialize new game with configuration from SkirmishSetupMenu
func initialize_match(config: Dictionary):
	print("🚀 Initializing new match with config: ", config)
	
	# Store configuration
	match_config = config
	extract_config_values(config)
	
	# Reset game state
	reset_game_state()
	
	# Setup world
	setup_world()
	
	# Create colonies
	create_player_colony()
	create_ai_colonies()
	
	# Setup victory conditions
	setup_victory_conditions()
	
	# Start game systems
	start_game_systems()
	
	# Emit signal
	game_started.emit(config)
	
	print("✅ Match initialized successfully")

## Extract values from match configuration
func extract_config_values(config: Dictionary):
	player_species = config.get("player_species", "Fire Ant")
	opponent_species = config.get("opponent_species", "Carpenter Ant")
	opponent_difficulty = config.get("opponent_difficulty", "Normal")
	selected_map = config.get("map", "Garden Valley")
	game_mode = config.get("game_mode", "skirmish")

## Reset game state to initial values
func reset_game_state():
	# Clear existing data
	player_colonies.clear()
	ai_colonies.clear()
	all_colonies.clear()
	world_resources.clear()
	discovered_resources.clear()
	ai_controllers.clear()
	global_events.clear()
	
	# Reset time and progression
	game_time = 0.0
	real_time_elapsed = 0.0
	turn_number = 0
	turn_timer = 0.0
	current_phase = "early_game"
	
	# Reset victory state
	game_ended = false
	winner = null
	victory_condition_met = ""
	victory_progress.clear()
	
	# Reset pause state
	is_paused = false
	time_scale = 1.0

## Setup world based on selected map
func setup_world():
	print("🌍 Setting up world: ", selected_map)
	
	match selected_map:
		"Garden Valley":
			setup_garden_valley_map()
		"Forest Floor":
			setup_forest_floor_map()
		"Desert Oasis":
			setup_desert_oasis_map()
		_:
			setup_default_map()

## Setup Garden Valley map
func setup_garden_valley_map():
	# Create resource nodes around the map
	create_resource_node("food", Vector2(200, 100), 150)
	create_resource_node("food", Vector2(-150, 200), 120)
	create_resource_node("materials", Vector2(100, -180), 100)
	create_resource_node("water", Vector2(-200, -100), 200)
	create_resource_node("rare_minerals", Vector2(300, 300), 50)
	
	# Set environmental conditions
	global_weather = "clear"
	global_season = "spring"

## Setup Forest Floor map
func setup_forest_floor_map():
	# More materials, less food
	create_resource_node("materials", Vector2(150, 150), 200)
	create_resource_node("materials", Vector2(-200, 100), 180)
	create_resource_node("food", Vector2(100, -100), 80)
	create_resource_node("water", Vector2(-100, -200), 150)
	
	global_weather = "overcast"
	global_season = "autumn"

## Setup Desert Oasis map
func setup_desert_oasis_map():
	# Scarce water, concentrated around oasis
	create_resource_node("water", Vector2(0, 0), 300)  # Central oasis
	create_resource_node("food", Vector2(50, 50), 60)
	create_resource_node("materials", Vector2(200, 200), 150)
	create_resource_node("rare_minerals", Vector2(-150, 150), 80)
	
	global_weather = "hot"
	global_season = "summer"

## Setup default map
func setup_default_map():
	# Balanced resource distribution
	create_resource_node("food", Vector2(150, 0), 100)
	create_resource_node("materials", Vector2(-150, 0), 100)
	create_resource_node("water", Vector2(0, 150), 100)

## Create a resource node at specified location
func create_resource_node(type: String, position: Vector2, quantity: int) -> Resource:
	var resource = preload("res://scripts/core/entities/resource.gd").new()
	resource.resource_type = type
	resource.global_position = position
	resource.quantity = quantity
	resource.max_quantity = quantity
	
	# Add to scene
	get_tree().current_scene.add_child(resource)
	
	# Track resource
	world_resources.append(resource)
	
	# Connect signals
	resource.resource_depleted.connect(_on_resource_depleted)
	resource.resource_harvested.connect(_on_resource_harvested)
	
	print("🌿 Created resource node: ", type, " at ", position, " (", quantity, " units)")
	return resource

# ==============================================================================
# COLONY MANAGEMENT
# ==============================================================================

## Create player colony
func create_player_colony():
	var colony = preload("res://scripts/core/entities/colony.gd").new()
	colony.colony_name = "Player Colony"
	colony.species = player_species
	colony.player_controlled = true
	colony.global_position = Vector2(-300, 0)  # Player starts on left
	
	# Add to scene
	get_tree().current_scene.add_child(colony)
	
	# Setup colony
	setup_colony_for_species(colony, player_species)
	
	# Track colony
	player_colonies.append(colony)
	all_colonies.append(colony)
	active_colony_count += 1
	
	# Connect signals
	connect_colony_signals(colony)
	
	colony_created.emit(colony)
	print("🏛️ Player colony created: ", colony.colony_name, " (", player_species, ")")

## Create AI colonies
func create_ai_colonies():
	# Create main AI opponent
	var ai_colony = create_ai_colony(opponent_species, opponent_difficulty)
	ai_colony.global_position = Vector2(300, 0)  # AI starts on right
	
	# Could add additional AI colonies for more complex scenarios
	print("🤖 AI colonies created")

## Create a single AI colony
func create_ai_colony(species: String, difficulty: String) -> Colony:
	var colony = preload("res://scripts/core/entities/colony.gd").new()
	colony.colony_name = species + " AI Colony"
	colony.species = species
	colony.player_controlled = false
	
	# Add to scene
	get_tree().current_scene.add_child(colony)
	
	# Setup colony for species
	setup_colony_for_species(colony, species)
	
	# Create and assign AI controller
	var ai_controller = create_ai_controller(difficulty)
	colony.set_ai_controller(ai_controller)
	ai_controllers.append(ai_controller)
	
	# Track colony
	ai_colonies.append(colony)
	all_colonies.append(colony)
	active_colony_count += 1
	
	# Connect signals
	connect_colony_signals(colony)
	
	colony_created.emit(colony)
	return colony

## Setup colony based on species characteristics
func setup_colony_for_species(colony: Colony, species: String):
	match species:
		"Fire Ant":
			colony.attack_bonus = 1.2
			colony.resource_efficiency = 1.0
			colony.construction_speed = 1.0
		"Carpenter Ant":
			colony.attack_bonus = 1.0
			colony.resource_efficiency = 1.1
			colony.construction_speed = 1.3
		"Leaf Cutter Ant":
			colony.attack_bonus = 0.9
			colony.resource_efficiency = 1.4
			colony.construction_speed = 1.1

## Create AI controller with specified difficulty
func create_ai_controller(difficulty: String) -> AIController:
	var ai = AIController.new()
	ai.difficulty = difficulty
	
	match difficulty:
		"Easy":
			ai.decision_frequency = 3.0
			ai.resource_management_skill = 0.7
			ai.military_aggression = 0.5
		"Normal":
			ai.decision_frequency = 2.0
			ai.resource_management_skill = 1.0
			ai.military_aggression = 0.8
		"Hard":
			ai.decision_frequency = 1.0
			ai.resource_management_skill = 1.3
			ai.military_aggression = 1.2
	
	return ai

## Connect colony signals for tracking
func connect_colony_signals(colony: Colony):
	colony.ant_died.connect(_on_ant_died)
	colony.research_completed.connect(_on_research_completed)
	colony.population_changed.connect(_on_population_changed)

# ==============================================================================
# TIME AND TURN MANAGEMENT
# ==============================================================================

## Update game time
func update_game_time(delta: float):
	if is_paused:
		return
	
	real_time_elapsed += delta
	game_time += delta * time_scale
	turn_timer += delta

## Update turn system
func update_turn_system(delta: float):
	if turn_timer >= turn_duration:
		advance_turn()
		turn_timer = 0.0

## Advance to next turn
func advance_turn():
	turn_number += 1
	
	# Update game phase based on time
	update_game_phase()
	
	# Process turn-based events
	process_turn_events()
	
	turn_completed.emit(turn_number)
	print("⏰ Turn ", turn_number, " completed (Phase: ", current_phase, ")")

## Update current game phase
func update_game_phase():
	var old_phase = current_phase
	
	if game_time < phase_duration.early_game:
		current_phase = "early_game"
	elif game_time < phase_duration.early_game + phase_duration.mid_game:
		current_phase = "mid_game"
	elif game_time < phase_duration.early_game + phase_duration.mid_game + phase_duration.late_game:
		current_phase = "late_game"
	else:
		current_phase = "end_game"
	
	if current_phase != old_phase:
		print("📈 Game phase changed: ", old_phase, " -> ", current_phase)

## Process events that happen each turn
func process_turn_events():
	# Random events
	if randf() < 0.1:  # 10% chance per turn
		trigger_random_event()
	
	# Environmental changes
	if turn_number % 10 == 0:  # Every 10 turns
		update_environmental_conditions()

# ==============================================================================
# VICTORY CONDITIONS
# ==============================================================================

## Setup victory conditions based on game mode
func setup_victory_conditions():
	match game_mode:
		"skirmish":
			victory_conditions.conquest.enabled = true
			victory_conditions.economic.enabled = true
			victory_conditions.population.enabled = false
		"campaign":
			# Campaign might have specific objectives
			pass

## Update and check victory conditions
func update_victory_conditions():
	if game_ended:
		return
	
	# Check conquest victory
	if victory_conditions.conquest.enabled:
		check_conquest_victory()
	
	# Check economic victory
	if victory_conditions.economic.enabled:
		check_economic_victory()
	
	# Check population victory
	if victory_conditions.population.enabled:
		check_population_victory()
	
	# Check time limit
	if victory_conditions.time.enabled:
		check_time_victory()

## Check conquest victory (eliminate all enemies)
func check_conquest_victory():
	var player_alive = not player_colonies.is_empty()
	var ai_alive = not ai_colonies.is_empty()
	
	if player_alive and not ai_alive:
		trigger_victory(player_colonies[0], "conquest")
	elif ai_alive and not player_alive:
		trigger_victory(ai_colonies[0], "conquest")

## Check economic victory (resource threshold)
func check_economic_victory():
	var threshold = victory_conditions.economic.amount
	
	for colony in all_colonies:
		var total_resources = colony.resources.get("food", 0) + colony.resources.get("materials", 0)
		if total_resources >= threshold:
			trigger_victory(colony, "economic")
			return

## Check population victory
func check_population_victory():
	var threshold = victory_conditions.population.amount
	
	for colony in all_colonies:
		if colony.population >= threshold:
			trigger_victory(colony, "population")
			return

## Check time limit victory
func check_time_victory():
	if game_time >= victory_conditions.time.duration:
		# Determine winner by score/resources
		var best_colony = determine_leading_colony()
		trigger_victory(best_colony, "time_limit")

## Determine which colony is leading
func determine_leading_colony() -> Colony:
	var best_colony: Colony = null
	var best_score = -1
	
	for colony in all_colonies:
		var score = calculate_colony_score(colony)
		if score > best_score:
			best_score = score
			best_colony = colony
	
	return best_colony

## Calculate colony score for comparison
func calculate_colony_score(colony: Colony) -> int:
	var score = 0
	score += colony.population * 10
	score += colony.resources.get("food", 0)
	score += colony.resources.get("materials", 0) * 2
	score += colony.buildings.size() * 50
	score += colony.territory_size * 25
	return score

## Trigger victory condition
func trigger_victory(winning_colony: Colony, condition: String):
	if game_ended:
		return
	
	game_ended = true
	winner = winning_colony
	victory_condition_met = condition
	
	# Pause the game
	pause_game(true)
	
	game_ended.emit(winning_colony, condition)
	print("🏆 Victory! ", winning_colony.colony_name, " wins by ", condition)

# ==============================================================================
# PAUSE AND TIME CONTROL
# ==============================================================================

## Pause or unpause the game
func pause_game(paused: bool):
	is_paused = paused
	
	if paused:
		get_tree().paused = true
	else:
		get_tree().paused = false
	
	game_paused.emit(is_paused)
	print("⏸️ Game paused: ", is_paused)

## Set game time scale (for fast forward, slow motion)
func set_time_scale(scale: float):
	time_scale = clamp(scale, 0.1, 5.0)
	print("⏱️ Time scale set to: ", time_scale)

# ==============================================================================
# SAVE/LOAD SYSTEM
# ==============================================================================

## Save current game state
func save_game(file_path: String = "") -> bool:
	if file_path.is_empty():
		file_path = save_file_path
	
	var save_data = {
		"version": "1.0",
		"timestamp": Time.get_time_dict_from_system(),
		"match_config": match_config,
		"game_time": game_time,
		"turn_number": turn_number,
		"current_phase": current_phase,
		"victory_conditions": victory_conditions,
		"global_weather": global_weather,
		"global_season": global_season,
		"colonies": [],
		"resources": []
	}
	
	# Save colony data
	for colony in all_colonies:
		save_data.colonies.append(colony.get_colony_data())
	
	# Save resource data
	for resource in world_resources:
		save_data.resources.append(resource.get_resource_data())
	
	# Write to file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		print("❌ Failed to save game: could not open file")
		return false
	
	file.store_string(JSON.stringify(save_data))
	file.close()
	
	print("💾 Game saved to: ", file_path)
	return true

## Load game state from file
func load_game(file_path: String = "") -> bool:
	if file_path.is_empty():
		file_path = save_file_path
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("❌ Failed to load game: file not found")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("❌ Failed to load game: invalid JSON")
		return false
	
	var save_data = json.data
	
	# Load basic game state
	match_config = save_data.get("match_config", {})
	game_time = save_data.get("game_time", 0.0)
	turn_number = save_data.get("turn_number", 0)
	current_phase = save_data.get("current_phase", "early_game")
	victory_conditions = save_data.get("victory_conditions", {})
	global_weather = save_data.get("global_weather", "clear")
	global_season = save_data.get("global_season", "spring")
	
	# TODO: Load colonies and resources
	# This would require more complex reconstruction of game objects
	
	print("📁 Game loaded from: ", file_path)
	return true

## Update autosave system
func update_autosave(delta: float):
	if not autosave_enabled:
		return
	
	last_autosave_time += delta
	if last_autosave_time >= autosave_interval:
		autosave_game()
		last_autosave_time = 0.0

## Perform autosave
func autosave_game():
	var autosave_path = "user://autosave.save"
	if save_game(autosave_path):
		print("💾 Autosave completed")

# ==============================================================================
# EVENT SYSTEM
# ==============================================================================

## Update global events
func update_global_events(delta: float):
	# Process active events
	for event in global_events.duplicate():
		event.duration -= delta
		if event.duration <= 0:
			end_global_event(event)

## Trigger a random event
func trigger_random_event():
	var events = [
		{"type": "weather_change", "description": "Weather changes", "duration": 120.0},
		{"type": "resource_boom", "description": "Resource discovery", "duration": 60.0},
		{"type": "predator_attack", "description": "Predator threatens colonies", "duration": 30.0}
	]
	
	var event = events[randi() % events.size()].duplicate()
	event.start_time = game_time
	
	apply_global_event(event)
	global_events.append(event)
	
	print("🎲 Random event: ", event.description)

## Apply global event effects
func apply_global_event(event: Dictionary):
	match event.type:
		"weather_change":
			global_weather = ["rain", "storm", "drought", "clear"][randi() % 4]
		"resource_boom":
			# Increase resource regeneration temporarily
			for resource in world_resources:
				resource.regeneration_rate *= 1.5
		"predator_attack":
			# Reduce ant efficiency temporarily
			for colony in all_colonies:
				colony.resource_efficiency *= 0.8

## End global event
func end_global_event(event: Dictionary):
	# Reverse event effects
	match event.type:
		"resource_boom":
			for resource in world_resources:
				resource.regeneration_rate /= 1.5
		"predator_attack":
			for colony in all_colonies:
				colony.resource_efficiency /= 0.8
	
	global_events.erase(event)
	print("🎲 Event ended: ", event.description)

## Update environmental conditions
func update_environmental_conditions():
	# Seasonal progression
	var seasons = ["spring", "summer", "autumn", "winter"]
	var current_index = seasons.find(global_season)
	if randf() < 0.3:  # 30% chance to advance season
		global_season = seasons[(current_index + 1) % seasons.size()]
		print("🌿 Season changed to: ", global_season)

# ==============================================================================
# SIGNAL HANDLERS
# ==============================================================================

## Handle ant death
func _on_ant_died(colony: Colony, ant: Ant):
	print("💀 Ant died in colony: ", colony.colony_name)

## Handle research completion
func _on_research_completed(colony: Colony, tech: String):
	research_completed.emit(colony, tech)
	print("🔬 Research completed in ", colony.colony_name, ": ", tech)

## Handle population changes
func _on_population_changed(colony: Colony, new_population: int):
	if new_population <= 0:
		handle_colony_destruction(colony)

## Handle resource depletion
func _on_resource_depleted(resource: GameResource):
	print("💀 Resource depleted: ", resource.resource_name)

## Handle resource harvesting
func _on_resource_harvested(resource: GameResource, amount: int, harvester: Ant):
	# Track discovered resources
	if resource not in discovered_resources:
		discovered_resources.append(resource)
		resource_node_discovered.emit(resource)

## Handle colony destruction
func handle_colony_destruction(colony: Colony):
	print("💥 Colony destroyed: ", colony.colony_name)
	
	# Remove from tracking
	all_colonies.erase(colony)
	player_colonies.erase(colony)
	ai_colonies.erase(colony)
	active_colony_count -= 1
	
	colony_destroyed.emit(colony)

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

## Setup autoload connections
func setup_autoload_connections():
	# Connect to scene tree signals if needed
	pass

## Start game systems
func start_game_systems():
	# Initialize any ongoing systems
	pass

## Get debug info
func get_debug_info() -> String:
	return "GameState | Time: %.1f | Turn: %d | Phase: %s | Colonies: %d | Paused: %s" % [
		game_time, turn_number, current_phase, active_colony_count, str(is_paused)
	]

# ==============================================================================
# AI CONTROLLER CLASS (Nested for simplicity)
# ==============================================================================

class AIController:
	var difficulty: String = "Normal"
	var decision_frequency: float = 2.0
	var resource_management_skill: float = 1.0
	var military_aggression: float = 0.8
	var last_decision_time: float = 0.0
	
	func make_decision():
		# Simple AI decision making
		var current_time = Time.get_time_dict_from_system().get("unix", 0.0)
		if current_time - last_decision_time < decision_frequency:
			return
		
		last_decision_time = current_time
		
		# AI makes decisions based on difficulty and personality
		# TODO: Implement actual AI decision logic
		pass
