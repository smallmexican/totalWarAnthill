# ==============================================================================
# SPECIES_DATA - Ant Species Configuration Resource
# ==============================================================================
# Purpose: Define characteristics, abilities, and bonuses for different ant species
# 
# This resource class stores all species-specific data including:
# - Base stats and modifiers
# - Special abilities and traits
# - Building bonuses and restrictions
# - Research trees and unlocks
# - Visual and audio preferences
#
# Usage:
# - Create .tres resource files for each species
# - Load dynamically in GameState or Colony
# - Easy to balance and modify without code changes
# - Supports modding and custom species
# ==============================================================================

class_name SpeciesData
extends Resource

# ==============================================================================
# BASIC INFORMATION
# ==============================================================================

## Species identification
@export var species_name: String = "Fire Ant"
@export var species_id: String = "fire_ant"
@export var description: String = "Aggressive ants known for their fierce combat abilities and territorial nature."
@export var difficulty_rating: int = 2  # 1=Easy, 3=Hard

## Lore and background
@export_multiline var lore_text: String = "Fire ants are renowned throughout the garden for their military prowess..."
@export var origin_biome: String = "desert"  # desert, forest, garden, mountain
@export var natural_enemies: Array[String] = ["carpenter_ant"]
@export var natural_allies: Array[String] = ["army_ant"]

# ==============================================================================
# BASE STATISTICS
# ==============================================================================

## Core stat modifiers (1.0 = normal, 1.2 = +20%, 0.8 = -20%)
@export_group("Base Stats")
@export var attack_modifier: float = 1.2
@export var defense_modifier: float = 1.0
@export var speed_modifier: float = 1.0
@export var health_modifier: float = 1.1
@export var energy_modifier: float = 0.9

## Resource efficiency
@export_group("Resource Management")
@export var food_efficiency: float = 1.0
@export var material_efficiency: float = 0.9
@export var water_efficiency: float = 0.8
@export var research_efficiency: float = 1.0

## Population and growth
@export_group("Population")
@export var reproduction_rate: float = 1.0
@export var max_population_bonus: int = 0  # Added to base max population
@export var worker_ratio: float = 0.6  # Preferred ratio of workers
@export var soldier_ratio: float = 0.3  # Preferred ratio of soldiers

# ==============================================================================
# SPECIAL ABILITIES
# ==============================================================================

## Unique species abilities
@export_group("Special Abilities")
@export var special_abilities: Array[String] = ["fire_attack", "heat_resistance"]
@export var passive_traits: Array[String] = ["aggressive", "territorial"]

## Ability descriptions and effects
@export var ability_descriptions: Dictionary = {
	"fire_attack": "Attacks deal fire damage over time",
	"heat_resistance": "Reduced damage from environmental heat",
	"aggressive": "Higher attack power but higher food consumption",
	"territorial": "Defensive bonus in own territory"
}

## Ability parameters
@export var ability_values: Dictionary = {
	"fire_attack_damage": 5,
	"fire_attack_duration": 3.0,
	"heat_resistance_reduction": 0.5,
	"aggressive_attack_bonus": 0.2,
	"aggressive_food_cost": 1.3,
	"territorial_defense_bonus": 0.15
}

# ==============================================================================
# BUILDING BONUSES AND RESTRICTIONS
# ==============================================================================

## Building efficiency modifiers
@export_group("Building Bonuses")
@export var building_bonuses: Dictionary = {
	"Barracks": 1.3,        # Fire ants are good at military buildings
	"Storage": 0.9,         # But poor at storage efficiency
	"Workshop": 1.0,
	"Nursery": 1.1,
	"Food_Storage": 0.8
}

## Construction speed modifiers
@export var construction_bonuses: Dictionary = {
	"Barracks": 1.2,        # Build military structures faster
	"Tunnel": 1.1,          # Good at digging
	"Workshop": 0.9
}

## Unique buildings (can only be built by this species)
@export var unique_buildings: Array[String] = ["Fire_Forge", "Combat_Arena"]

## Restricted buildings (cannot build)
@export var restricted_buildings: Array[String] = ["Ice_Storage"]

# ==============================================================================
# RESEARCH AND TECHNOLOGY
# ==============================================================================

## Research tree modifiers
@export_group("Research")
@export var research_bonuses: Dictionary = {
	"Combat_Tech": 1.4,     # Research combat technologies faster
	"Agriculture": 0.7,     # Slower at agricultural research
	"Engineering": 1.0,
	"Medicine": 0.8
}

## Starting technologies (already unlocked)
@export var starting_technologies: Array[String] = ["Basic_Combat", "Fire_Resistance"]

## Unique research options (only this species can research)
@export var unique_research: Array[String] = ["Advanced_Fire_Weapons", "Heat_Adaptation"]

## Blocked research (cannot research)
@export var blocked_research: Array[String] = ["Ice_Technology", "Cold_Adaptation"]

# ==============================================================================
# UNIT VARIATIONS
# ==============================================================================

## Ant type stat modifiers
@export_group("Unit Types")
@export var worker_modifiers: Dictionary = {
	"attack": 0.8,
	"defense": 0.9,
	"speed": 1.1,
	"gather_rate": 1.0
}

@export var soldier_modifiers: Dictionary = {
	"attack": 1.3,          # Fire ant soldiers are extra strong
	"defense": 1.2,
	"speed": 0.9,
	"stamina": 1.1
}

@export var scout_modifiers: Dictionary = {
	"attack": 0.7,
	"defense": 0.8,
	"speed": 1.4,
	"vision_range": 1.3
}

@export var queen_modifiers: Dictionary = {
	"health": 2.0,
	"defense": 1.5,
	"reproduction": 1.2,
	"command_range": 1.1
}

# ==============================================================================
# ENVIRONMENTAL PREFERENCES
# ==============================================================================

## Terrain bonuses and penalties
@export_group("Environment")
@export var terrain_bonuses: Dictionary = {
	"desert": 1.2,          # Fire ants love hot, dry areas
	"rock": 1.1,
	"grass": 1.0,
	"forest": 0.8,
	"water": 0.6            # Hate wet areas
}

## Weather preferences
@export var weather_bonuses: Dictionary = {
	"hot": 1.3,
	"dry": 1.2,
	"sunny": 1.1,
	"clear": 1.0,
	"rain": 0.7,
	"cold": 0.5
}

## Seasonal effects
@export var seasonal_bonuses: Dictionary = {
	"summer": 1.2,
	"spring": 1.0,
	"autumn": 0.9,
	"winter": 0.6
}

# ==============================================================================
# VISUAL AND AUDIO
# ==============================================================================

## Visual appearance
@export_group("Appearance")
@export var primary_color: Color = Color.RED
@export var secondary_color: Color = Color.ORANGE
@export var ant_sprite_path: String = "res://assets/sprites/ants/fire_ant.png"
@export var colony_sprite_path: String = "res://assets/sprites/colonies/fire_colony.png"

## Audio preferences
@export_group("Audio")
@export var attack_sound: String = "res://assets/audio/fire_attack.ogg"
@export var work_sound: String = "res://assets/audio/fire_work.ogg"
@export var death_sound: String = "res://assets/audio/fire_death.ogg"

## UI elements
@export var icon_path: String = "res://assets/icons/fire_ant_icon.png"
@export var flag_texture: String = "res://assets/flags/fire_ant_flag.png"

# ==============================================================================
# BALANCING DATA
# ==============================================================================

## Resource costs and requirements
@export_group("Economy")
@export var ant_spawn_cost_modifier: Dictionary = {
	"food": 1.1,            # Fire ants cost more food to spawn
	"materials": 1.0,
	"larvae": 1.0
}

@export var building_cost_modifier: Dictionary = {
	"materials": 0.9,       # Cheaper building costs
	"food": 1.2            # But higher food requirements
}

## Victory condition modifiers
@export var victory_bonuses: Dictionary = {
	"conquest": 1.2,        # Bonus for military victory
	"economic": 0.8,        # Penalty for economic victory
	"population": 1.0
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

## Get stat modifier for specific category
func get_stat_modifier(category: String, stat_name: String) -> float:
	match category:
		"base":
			return get_base_stat_modifier(stat_name)
		"building":
			return building_bonuses.get(stat_name, 1.0)
		"research":
			return research_bonuses.get(stat_name, 1.0)
		"terrain":
			return terrain_bonuses.get(stat_name, 1.0)
		"weather":
			return weather_bonuses.get(stat_name, 1.0)
		_:
			return 1.0

## Get base stat modifier
func get_base_stat_modifier(stat_name: String) -> float:
	match stat_name:
		"attack":
			return attack_modifier
		"defense":
			return defense_modifier
		"speed":
			return speed_modifier
		"health":
			return health_modifier
		"energy":
			return energy_modifier
		"food_efficiency":
			return food_efficiency
		"material_efficiency":
			return material_efficiency
		"water_efficiency":
			return water_efficiency
		"research_efficiency":
			return research_efficiency
		_:
			return 1.0

## Check if species has specific ability
func has_ability(ability_name: String) -> bool:
	return ability_name in special_abilities or ability_name in passive_traits

## Get ability value
func get_ability_value(ability_name: String) -> float:
	return ability_values.get(ability_name, 0.0)

## Check if building is allowed
func can_build(building_type: String) -> bool:
	return building_type not in restricted_buildings

## Check if research is allowed
func can_research(tech_name: String) -> bool:
	return tech_name not in blocked_research

## Get building efficiency
func get_building_efficiency(building_type: String) -> float:
	return building_bonuses.get(building_type, 1.0)

## Get construction speed for building type
func get_construction_speed(building_type: String) -> float:
	return construction_bonuses.get(building_type, 1.0)

## Get unit type modifiers
func get_unit_modifiers(unit_type: String) -> Dictionary:
	match unit_type:
		"Worker":
			return worker_modifiers
		"Soldier":
			return soldier_modifiers
		"Scout":
			return scout_modifiers
		"Queen":
			return queen_modifiers
		_:
			return {}

## Calculate effective stat for unit type
func calculate_unit_stat(unit_type: String, base_stat: String, base_value: float) -> float:
	var modifiers = get_unit_modifiers(unit_type)
	var unit_modifier = modifiers.get(base_stat, 1.0)
	var species_modifier = get_base_stat_modifier(base_stat)
	
	return base_value * species_modifier * unit_modifier

## Get environmental efficiency for current conditions
func get_environmental_efficiency(terrain: String, weather: String, season: String) -> float:
	var terrain_bonus = terrain_bonuses.get(terrain, 1.0)
	var weather_bonus = weather_bonuses.get(weather, 1.0)
	var seasonal_bonus = seasonal_bonuses.get(season, 1.0)
	
	return terrain_bonus * weather_bonus * seasonal_bonus

## Export data as dictionary for runtime use
func to_dictionary() -> Dictionary:
	return {
		"species_name": species_name,
		"species_id": species_id,
		"description": description,
		"difficulty_rating": difficulty_rating,
		"base_stats": {
			"attack": attack_modifier,
			"defense": defense_modifier,
			"speed": speed_modifier,
			"health": health_modifier,
			"energy": energy_modifier
		},
		"resource_efficiency": {
			"food": food_efficiency,
			"materials": material_efficiency,
			"water": water_efficiency,
			"research": research_efficiency
		},
		"special_abilities": special_abilities,
		"passive_traits": passive_traits,
		"ability_values": ability_values,
		"building_bonuses": building_bonuses,
		"construction_bonuses": construction_bonuses,
		"unique_buildings": unique_buildings,
		"restricted_buildings": restricted_buildings,
		"research_bonuses": research_bonuses,
		"starting_technologies": starting_technologies,
		"unique_research": unique_research,
		"blocked_research": blocked_research,
		"unit_modifiers": {
			"Worker": worker_modifiers,
			"Soldier": soldier_modifiers,
			"Scout": scout_modifiers,
			"Queen": queen_modifiers
		},
		"environmental_bonuses": {
			"terrain": terrain_bonuses,
			"weather": weather_bonuses,
			"seasonal": seasonal_bonuses
		},
		"visual_data": {
			"primary_color": primary_color,
			"secondary_color": secondary_color,
			"ant_sprite": ant_sprite_path,
			"colony_sprite": colony_sprite_path,
			"icon": icon_path
		},
		"economy": {
			"spawn_cost_modifier": ant_spawn_cost_modifier,
			"building_cost_modifier": building_cost_modifier
		}
	}

## Load from dictionary (for JSON saves/configs)
func from_dictionary(data: Dictionary):
	species_name = data.get("species_name", "Unknown Species")
	species_id = data.get("species_id", "unknown")
	description = data.get("description", "")
	difficulty_rating = data.get("difficulty_rating", 1)
	
	var base_stats = data.get("base_stats", {})
	attack_modifier = base_stats.get("attack", 1.0)
	defense_modifier = base_stats.get("defense", 1.0)
	speed_modifier = base_stats.get("speed", 1.0)
	health_modifier = base_stats.get("health", 1.0)
	energy_modifier = base_stats.get("energy", 1.0)
	
	var resource_eff = data.get("resource_efficiency", {})
	food_efficiency = resource_eff.get("food", 1.0)
	material_efficiency = resource_eff.get("materials", 1.0)
	water_efficiency = resource_eff.get("water", 1.0)
	research_efficiency = resource_eff.get("research", 1.0)
	
	special_abilities = data.get("special_abilities", [])
	passive_traits = data.get("passive_traits", [])
	ability_values = data.get("ability_values", {})
	building_bonuses = data.get("building_bonuses", {})
	construction_bonuses = data.get("construction_bonuses", {})

## Create a balanced species template
static func create_balanced_template() -> SpeciesData:
	var species = SpeciesData.new()
	species.species_name = "Balanced Ant"
	species.species_id = "balanced_ant"
	species.description = "A well-rounded ant species with no particular strengths or weaknesses."
	
	# All stats at 1.0 (balanced)
	species.attack_modifier = 1.0
	species.defense_modifier = 1.0
	species.speed_modifier = 1.0
	species.health_modifier = 1.0
	species.energy_modifier = 1.0
	
	return species
