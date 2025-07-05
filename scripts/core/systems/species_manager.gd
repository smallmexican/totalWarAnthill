# ==============================================================================
# SPECIES_MANAGER - Central Species Data Management
# ==============================================================================
# Purpose: Load, cache, and provide access to all species data
# 
# This singleton manages all species information including:
# - Loading species data from resource files
# - Caching for performance
# - Providing species data to colonies and ants
# - Runtime species modification and balancing
#
# Usage:
# - Add as autoload singleton
# - Call SpeciesManager.get_species_data("fire_ant")
# - Access species bonuses and abilities
# - Hot-reload species data for balancing
# ==============================================================================

extends Node

# ==============================================================================
# SIGNALS
# ==============================================================================

signal species_loaded(species_id: String, species_data: SpeciesData)
signal species_data_changed(species_id: String)
signal all_species_loaded()

# ==============================================================================
# CACHED SPECIES DATA
# ==============================================================================

## Species data cache
var species_cache: Dictionary = {}
var species_list: Array[String] = []
var is_initialized: bool = false

## Updated species paths to include simple versions
var species_paths: Dictionary = {
	"fire_ant": "res://data/species/fire_ant_simple.tres",
	"carpenter_ant": "res://data/species/carpenter_ant_simple.tres", 
	"leaf_cutter_ant": "res://data/species/leaf_cutter_ant.tres",
	"army_ant": "res://data/species/army_ant.tres",
	"harvester_ant": "res://data/species/harvester_ant.tres"
}

## Fallback data for missing species
var fallback_species_data: Resource

# ==============================================================================
# INITIALIZATION
# ==============================================================================

func _ready():
	print("🧬 SpeciesManager initializing...")
	setup_fallback_data()
	load_all_species()

## Setup fallback species data
func setup_fallback_data():
	create_fallback_species()

## Load all species data from files
func load_all_species():
	print("📂 Loading species data...")
	
	# Create species data files if they don't exist
	create_default_species_files()
	
	# Load each species
	for species_id in species_paths:
		load_species(species_id)
	
	is_initialized = true
	all_species_loaded.emit()
	
	print("✅ Loaded ", species_cache.size(), " species:")
	for species_id in species_cache:
		var species = species_cache[species_id]
		print("   - ", species.species_name, " (", species_id, ")")

# ==============================================================================
# SPECIES LOADING
# ==============================================================================

## Load a specific species from file
func load_species(species_id: String) -> Resource:
	var file_path = species_paths.get(species_id, "")
	
	if file_path.is_empty():
		print("⚠️ No path defined for species: ", species_id)
		return get_fallback_species()
	
	# Try to load the resource file
	var species_resource = load(file_path)
	
	# Try SpeciesDataSimple first, then SpeciesData
	var species_data = species_resource as SpeciesDataSimple
	if not species_data:
		species_data = species_resource as SpeciesData
	
	if species_data == null:
		print("⚠️ Failed to load species data: ", file_path)
		return get_fallback_species()
	
	# Cache the loaded species
	species_cache[species_id] = species_data
	species_list.append(species_id)
	
	print("✅ Loaded species: ", species_data.species_name, " (", species_id, ")")
	species_loaded.emit(species_id, species_data)
	
	return species_data

## Get fallback species data
func get_fallback_species() -> Resource:
	if not fallback_species_data:
		create_fallback_species()
	return fallback_species_data

## Create fallback species data
func create_fallback_species():
	fallback_species_data = SpeciesDataSimple.new()
	fallback_species_data.species_name = "Unknown Species"
	fallback_species_data.species_id = "unknown"
	fallback_species_data.description = "Fallback species data"
		species_data = create_default_species_data(species_id)
		save_species_data(species_id, species_data)
	
	# Cache the data
	species_cache[species_id] = species_data
	species_list.append(species_id)
	
	species_loaded.emit(species_id, species_data)
	print("🐜 Loaded species: ", species_data.species_name)
	
	return species_data

## Get species data by ID
func get_species_data(species_id: String) -> Resource:
	if species_id in species_cache:
		return species_cache[species_id]
	
	# Try to load if not cached
	if species_id in species_paths:
		return load_species(species_id)
	
	print("⚠️ Species not found: ", species_id, " - using fallback")
	return get_fallback_species()

## Check if species exists
func has_species(species_id: String) -> bool:
	return species_id in species_cache or species_id in species_paths

## Get list of all available species
func get_all_species_ids() -> Array[String]:
	return species_list.duplicate()

## Get species data as array
func get_all_species_data() -> Array[SpeciesData]:
	var species_array: Array[SpeciesData] = []
	for species_id in species_list:
		species_array.append(species_cache[species_id])
	return species_array

# ==============================================================================
# SPECIES CREATION AND MODIFICATION
# ==============================================================================

## Create default species data files
func create_default_species_files():
	# Ensure data directory exists
	if not DirAccess.dir_exists_absolute("res://data"):
		DirAccess.open("res://").make_dir("data")
	
	if not DirAccess.dir_exists_absolute("res://data/species"):
		DirAccess.open("res://data").make_dir("species")
	
	# Create default species if they don't exist
	for species_id in species_paths:
		var file_path = species_paths[species_id]
		if not FileAccess.file_exists(file_path):
			print("📝 Creating default species file: ", file_path)
			var species_data = create_default_species_data(species_id)
			save_species_data_to_file(species_data, file_path)

## Create default species data based on ID
func create_default_species_data(species_id: String) -> SpeciesData:
	var species = SpeciesData.new()
	
	match species_id:
		"fire_ant":
			create_fire_ant_data(species)
		"carpenter_ant":
			create_carpenter_ant_data(species)
		"leaf_cutter_ant":
			create_leaf_cutter_ant_data(species)
		"army_ant":
			create_army_ant_data(species)
		"harvester_ant":
			create_harvester_ant_data(species)
		_:
			species = SpeciesData.create_balanced_template()
			species.species_id = species_id
	
	return species

## Create Fire Ant species data
func create_fire_ant_data(species: SpeciesData):
	species.species_name = "Fire Ant"
	species.species_id = "fire_ant"
	species.description = "Aggressive ants known for their fierce combat abilities and territorial nature."
	species.difficulty_rating = 2
	
	# Combat focused
	species.attack_modifier = 1.3
	species.defense_modifier = 1.1
	species.speed_modifier = 1.0
	species.health_modifier = 1.1
	species.energy_modifier = 0.9
	
	# Resource management
	species.food_efficiency = 0.9  # High metabolism
	species.material_efficiency = 1.0
	species.water_efficiency = 0.8  # Desert species, needs less water
	species.research_efficiency = 1.0
	
	# Special abilities
	species.special_abilities = ["fire_attack", "heat_resistance"]
	species.passive_traits = ["aggressive", "territorial"]
	
	species.ability_values = {
		"fire_attack_damage": 5,
		"fire_attack_duration": 3.0,
		"heat_resistance_reduction": 0.5,
		"aggressive_attack_bonus": 0.2,
		"aggressive_food_cost": 1.3,
		"territorial_defense_bonus": 0.15
	}
	
	# Building bonuses
	species.building_bonuses = {
		"Barracks": 1.4,
		"Storage": 0.9,
		"Workshop": 1.0,
		"Nursery": 1.1,
		"Food_Storage": 0.8
	}
	
	# Research bonuses
	species.research_bonuses = {
		"Combat_Tech": 1.5,
		"Agriculture": 0.7,
		"Engineering": 1.0,
		"Medicine": 0.8
	}
	
	# Environmental preferences
	species.terrain_bonuses = {
		"desert": 1.3,
		"rock": 1.1,
		"grass": 1.0,
		"forest": 0.8,
		"water": 0.6
	}
	
	species.weather_bonuses = {
		"hot": 1.4,
		"dry": 1.2,
		"sunny": 1.1,
		"clear": 1.0,
		"rain": 0.7,
		"cold": 0.5
	}
	
	# Appearance
	species.primary_color = Color.RED
	species.secondary_color = Color.ORANGE

## Create Carpenter Ant species data
func create_carpenter_ant_data(species: SpeciesData):
	species.species_name = "Carpenter Ant"
	species.species_id = "carpenter_ant"
	species.description = "Master builders and engineers, excellent at construction and resource gathering."
	species.difficulty_rating = 1
	
	# Construction focused
	species.attack_modifier = 0.9
	species.defense_modifier = 1.0
	species.speed_modifier = 0.9
	species.health_modifier = 1.2
	species.energy_modifier = 1.1
	
	# Resource management
	species.food_efficiency = 1.1
	species.material_efficiency = 1.4  # Excellent with materials
	species.water_efficiency = 1.0
	species.research_efficiency = 1.2
	
	# Special abilities
	species.special_abilities = ["efficient_construction", "wood_processing"]
	species.passive_traits = ["industrious", "organized"]
	
	# Building bonuses
	species.building_bonuses = {
		"Barracks": 0.9,
		"Storage": 1.3,
		"Workshop": 1.5,
		"Nursery": 1.0,
		"Food_Storage": 1.2
	}
	
	species.construction_bonuses = {
		"Storage": 1.4,
		"Workshop": 1.5,
		"Tunnel": 1.6,
		"Barracks": 0.8
	}
	
	# Research bonuses
	species.research_bonuses = {
		"Combat_Tech": 0.8,
		"Agriculture": 1.2,
		"Engineering": 1.6,
		"Medicine": 1.0
	}
	
	# Environmental preferences (forest dwellers)
	species.terrain_bonuses = {
		"forest": 1.3,
		"grass": 1.1,
		"rock": 1.0,
		"desert": 0.7,
		"water": 0.9
	}
	
	# Appearance
	species.primary_color = Color(0.4, 0.2, 0.0)  # Brown
	species.secondary_color = Color(0.6, 0.4, 0.2)  # Light brown

## Create Leaf Cutter Ant species data
func create_leaf_cutter_ant_data(species: SpeciesData):
	species.species_name = "Leaf Cutter Ant"
	species.species_id = "leaf_cutter_ant"
	species.description = "Agricultural specialists who cultivate fungus gardens for sustainable food production."
	species.difficulty_rating = 3
	
	# Agriculture focused
	species.attack_modifier = 0.7
	species.defense_modifier = 0.9
	species.speed_modifier = 1.1
	species.health_modifier = 1.0
	species.energy_modifier = 1.2
	
	# Resource management
	species.food_efficiency = 1.5  # Excellent food production
	species.material_efficiency = 0.8
	species.water_efficiency = 1.2
	species.research_efficiency = 1.3
	
	# Special abilities
	species.special_abilities = ["fungus_cultivation", "leaf_processing"]
	species.passive_traits = ["agricultural", "sustainable"]
	
	# Building bonuses
	species.building_bonuses = {
		"Food_Storage": 1.6,
		"Nursery": 1.3,
		"Storage": 1.2,
		"Workshop": 1.1,
		"Barracks": 0.7
	}
	
	# Unique buildings
	species.unique_buildings = ["Fungus_Garden", "Compost_Chamber"]
	
	# Appearance
	species.primary_color = Color.GREEN
	species.secondary_color = Color(0.4, 0.8, 0.2)

## Create Army Ant species data
func create_army_ant_data(species: SpeciesData):
	species.species_name = "Army Ant"
	species.species_id = "army_ant"
	species.description = "Elite military specialists with superior coordination and combat tactics."
	species.difficulty_rating = 3
	
	# Military focused
	species.attack_modifier = 1.5
	species.defense_modifier = 1.3
	species.speed_modifier = 1.2
	species.health_modifier = 0.9
	species.energy_modifier = 0.8
	
	# Special abilities
	species.special_abilities = ["formation_fighting", "tactical_coordination"]
	species.passive_traits = ["disciplined", "coordinated"]
	
	# Building bonuses
	species.building_bonuses = {
		"Barracks": 1.6,
		"Storage": 0.8,
		"Workshop": 0.9,
		"Nursery": 0.9,
		"Food_Storage": 0.8
	}
	
	# Appearance
	species.primary_color = Color.BLACK
	species.secondary_color = Color.DARK_GRAY

## Create Harvester Ant species data
func create_harvester_ant_data(species: SpeciesData):
	species.species_name = "Harvester Ant"
	species.species_id = "harvester_ant"
	species.description = "Efficient resource gatherers with excellent food storage and preservation abilities."
	species.difficulty_rating = 1
	
	# Resource focused
	species.attack_modifier = 0.8
	species.defense_modifier = 1.0
	species.speed_modifier = 1.0
	species.health_modifier = 1.1
	species.energy_modifier = 1.1
	
	# Resource management
	species.food_efficiency = 1.3
	species.material_efficiency = 1.2
	species.water_efficiency = 1.1
	species.research_efficiency = 1.0
	
	# Special abilities
	species.special_abilities = ["efficient_gathering", "food_preservation"]
	species.passive_traits = ["efficient", "organized"]
	
	# Appearance
	species.primary_color = Color(0.8, 0.6, 0.2)  # Golden
	species.secondary_color = Color(1.0, 0.8, 0.4)  # Light golden

# ==============================================================================
# SAVE AND LOAD
# ==============================================================================

## Save species data to cache and file
func save_species_data(species_id: String, species_data: SpeciesData):
	species_cache[species_id] = species_data
	
	if species_id in species_paths:
		save_species_data_to_file(species_data, species_paths[species_id])
	
	species_data_changed.emit(species_id)

## Save species data to file
func save_species_data_to_file(species_data: SpeciesData, file_path: String):
	var result = ResourceSaver.save(species_data, file_path)
	if result != OK:
		print("❌ Failed to save species data to: ", file_path)
	else:
		print("💾 Saved species data to: ", file_path)

## Reload species data from file
func reload_species(species_id: String):
	if species_id in species_cache:
		species_cache.erase(species_id)
	
	load_species(species_id)
	print("🔄 Reloaded species: ", species_id)

## Hot-reload all species (for balancing during development)
func reload_all_species():
	print("🔄 Hot-reloading all species data...")
	
	species_cache.clear()
	species_list.clear()
	
	load_all_species()

# ==============================================================================
# RUNTIME QUERIES
# ==============================================================================

## Get species by name (user-friendly)
func get_species_by_name(species_name: String) -> SpeciesData:
	for species_id in species_cache:
		var species = species_cache[species_id]
		if species.species_name == species_name:
			return species
	
	return fallback_species_data

## Get all species names for UI
func get_species_names() -> Array[String]:
	var names: Array[String] = []
	for species_id in species_list:
		var species = species_cache[species_id]
		names.append(species.species_name)
	return names

## Get species difficulty ratings
func get_species_by_difficulty(max_difficulty: int = 3) -> Array[SpeciesData]:
	var filtered: Array[SpeciesData] = []
	for species_id in species_list:
		var species = species_cache[species_id]
		if species.difficulty_rating <= max_difficulty:
			filtered.append(species)
	return filtered

## Apply species data to colony
func apply_species_to_colony(colony: Colony, species_id: String):
	var species_data = get_species_data(species_id)
	
	# Apply basic modifiers
	colony.attack_bonus *= species_data.attack_modifier
	colony.defense_bonus *= species_data.defense_modifier
	colony.resource_efficiency *= species_data.material_efficiency
	colony.construction_speed *= species_data.get_construction_speed("default")
	
	# Apply starting technologies
	for tech in species_data.starting_technologies:
		if tech not in colony.researched_technologies:
			colony.researched_technologies.append(tech)
	
	print("🧬 Applied species data '", species_data.species_name, "' to colony '", colony.colony_name, "'")

## Apply species data to ant
func apply_species_to_ant(ant: Ant, species_id: String):
	var species_data = get_species_data(species_id)
	
	# Apply base stat modifiers
	ant.attack_power = int(ant.attack_power * species_data.attack_modifier)
	ant.defense_rating = int(ant.defense_rating * species_data.defense_modifier)
	ant.max_health = int(ant.max_health * species_data.health_modifier)
	ant.current_health = ant.max_health
	ant.base_movement_speed *= species_data.speed_modifier
	ant.current_movement_speed = ant.base_movement_speed
	
	# Apply unit-specific modifiers
	var unit_modifiers = species_data.get_unit_modifiers(ant.ant_type)
	for stat in unit_modifiers:
		match stat:
			"attack":
				ant.attack_power = int(ant.attack_power * unit_modifiers[stat])
			"defense":
				ant.defense_rating = int(ant.defense_rating * unit_modifiers[stat])
			"speed":
				ant.base_movement_speed *= unit_modifiers[stat]
				ant.current_movement_speed = ant.base_movement_speed

# ==============================================================================
# DEBUG AND DEVELOPMENT
# ==============================================================================

## Print species data for debugging
func debug_print_species(species_id: String):
	var species = get_species_data(species_id)
	print("\n🐜 SPECIES DEBUG: ", species.species_name)
	print("   ID: ", species.species_id)
	print("   Difficulty: ", species.difficulty_rating)
	print("   Attack: ", species.attack_modifier)
	print("   Defense: ", species.defense_modifier)
	print("   Speed: ", species.speed_modifier)
	print("   Special Abilities: ", species.special_abilities)
	print("   Building Bonuses: ", species.building_bonuses)

## Create test species for balancing
func create_test_species(name: String, attack: float, defense: float, speed: float) -> SpeciesData:
	var species = SpeciesData.create_balanced_template()
	species.species_name = name
	species.species_id = name.to_lower().replace(" ", "_")
	species.attack_modifier = attack
	species.defense_modifier = defense
	species.speed_modifier = speed
	
	species_cache[species.species_id] = species
	return species
