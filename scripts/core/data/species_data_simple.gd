# ==============================================================================
# SPECIES_DATA_SIMPLE - Simplified Ant Species Configuration Resource
# ==============================================================================
# Purpose: Define essential characteristics for different ant species
# 
# This simplified version includes only the core properties needed for gameplay
# and avoids complex default values that can cause serialization issues.
# ==============================================================================

class_name SpeciesDataSimple
extends Resource

# ==============================================================================
# BASIC INFORMATION
# ==============================================================================

@export var species_name: String = ""
@export var species_id: String = ""
@export var description: String = ""
@export var difficulty_rating: int = 1
@export_multiline var lore_text: String = ""
@export var origin_biome: String = "forest"

# ==============================================================================
# RELATIONS
# ==============================================================================

@export var natural_enemies: Array[String] = []
@export var natural_allies: Array[String] = []

# ==============================================================================
# BASE STATISTICS
# ==============================================================================

@export_group("Base Stats")
@export var attack_modifier: float = 1.0
@export var defense_modifier: float = 1.0
@export var speed_modifier: float = 1.0
@export var health_modifier: float = 1.0
@export var energy_modifier: float = 1.0

# ==============================================================================
# RESOURCE EFFICIENCY
# ==============================================================================

@export_group("Resource Management")
@export var food_efficiency: float = 1.0
@export var material_efficiency: float = 1.0
@export var water_efficiency: float = 1.0
@export var research_efficiency: float = 1.0

# ==============================================================================
# POPULATION
# ==============================================================================

@export_group("Population")
@export var reproduction_rate: float = 1.0
@export var max_population_bonus: int = 0
@export var worker_ratio: float = 0.6
@export var soldier_ratio: float = 0.3

# ==============================================================================
# ABILITIES (SIMPLIFIED)
# ==============================================================================

@export_group("Abilities")
@export var special_abilities: Array[String] = []
@export var passive_traits: Array[String] = []

# ==============================================================================
# APPEARANCE
# ==============================================================================

@export_group("Appearance")
@export var primary_color: Color = Color.BROWN
@export var secondary_color: Color = Color.TAN

# ==============================================================================
# UTILITY METHODS
# ==============================================================================

## Check if species has a specific ability
func has_ability(ability_name: String) -> bool:
	return special_abilities.has(ability_name) or passive_traits.has(ability_name)

## Get total stat modifier sum for balance checking
func get_total_stat_modifiers() -> float:
	return attack_modifier + defense_modifier + speed_modifier + health_modifier + energy_modifier

## Get display name with difficulty indicator
func get_display_name() -> String:
	var difficulty_stars = "★".repeat(difficulty_rating)
	return "%s %s" % [species_name, difficulty_stars]

## Create a summary string for debugging
func get_summary() -> String:
	var summary = "Species: %s (%s)\n" % [species_name, species_id]
	summary += "Difficulty: %d/3\n" % difficulty_rating
	summary += "Attack: %.2f, Defense: %.2f, Speed: %.2f\n" % [attack_modifier, defense_modifier, speed_modifier]
	summary += "Abilities: %s\n" % ", ".join(special_abilities)
	return summary
