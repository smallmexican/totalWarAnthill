# ==============================================================================
# SPECIES_CREATOR - Development Tool for Creating Species Data
# ==============================================================================
# Purpose: Helper tool for developers to easily create and edit species data
# 
# This tool provides:
# - Template generation for new species
# - Validation of species data
# - Export/import from JSON for easier editing
# - Batch operations for balancing
#
# Usage:
# - Attach to a tool scene in editor
# - Use for rapid prototyping of species
# - Validate all species data at once
# ==============================================================================

@tool
extends RefCounted
class_name SpeciesCreator

# ==============================================================================
# TEMPLATE GENERATION
# ==============================================================================

## Create a new species with default values
static func create_species_template(species_id: String, species_name: String) -> SpeciesData:
	var species_data = SpeciesData.new()
	
	# Basic info
	species_data.species_id = species_id
	species_data.species_name = species_name
	species_data.description = "A unique ant species with special characteristics."
	species_data.difficulty_rating = 2
	species_data.lore_text = "Add lore text here..."
	species_data.origin_biome = "forest"
	
	# Balanced base stats
	species_data.attack_modifier = 1.0
	species_data.defense_modifier = 1.0
	species_data.speed_modifier = 1.0
	species_data.health_modifier = 1.0
	species_data.energy_modifier = 1.0
	
	# Resource efficiency
	species_data.food_efficiency = 1.0
	species_data.material_efficiency = 1.0
	species_data.water_efficiency = 1.0
	species_data.research_efficiency = 1.0
	
	# Population defaults
	species_data.reproduction_rate = 1.0
	species_data.max_population_bonus = 0
	species_data.worker_ratio = 0.6
	species_data.soldier_ratio = 0.3
	
	# Empty arrays for abilities
	species_data.special_abilities = []
	species_data.passive_traits = []
	species_data.ability_descriptions = {}
	
	# Empty bonuses and restrictions
	species_data.building_bonuses = {}
	species_data.building_restrictions = []
	species_data.research_bonuses = {}
	species_data.research_restrictions = []
	
	# Default AI personality
	species_data.ai_personality = {
		"aggression": 0.5,
		"diplomacy": 0.5,
		"expansion": 0.5,
		"research": 0.5
	}
	
	return species_data

# ==============================================================================
# VALIDATION
# ==============================================================================

## Validate species data for common issues
static func validate_species_data(species_data: SpeciesData) -> Array[String]:
	var errors: Array[String] = []
	
	# Check required fields
	if species_data.species_id.is_empty():
		errors.append("species_id cannot be empty")
	
	if species_data.species_name.is_empty():
		errors.append("species_name cannot be empty")
	
	# Check stat balance
	var total_modifiers = species_data.attack_modifier + species_data.defense_modifier + \
						  species_data.speed_modifier + species_data.health_modifier + \
						  species_data.energy_modifier
	
	if total_modifiers > 6.0:  # Average should be around 1.0 each = 5.0 total
		errors.append("Total stat modifiers may be too high: %.2f (consider average ~5.0)" % total_modifiers)
	
	if total_modifiers < 4.0:
		errors.append("Total stat modifiers may be too low: %.2f (consider average ~5.0)" % total_modifiers)
	
	# Check ratios
	var total_ratio = species_data.worker_ratio + species_data.soldier_ratio
	if total_ratio > 1.0:
		errors.append("Worker + Soldier ratio exceeds 1.0: %.2f" % total_ratio)
	
	# Check difficulty rating
	if species_data.difficulty_rating < 1 or species_data.difficulty_rating > 3:
		errors.append("Difficulty rating should be 1-3, got: %d" % species_data.difficulty_rating)
	
	# Check for undefined abilities
	for ability in species_data.special_abilities:
		if not species_data.ability_descriptions.has(ability):
			errors.append("Missing description for ability: %s" % ability)
	
	for trait in species_data.passive_traits:
		if not species_data.ability_descriptions.has(trait):
			errors.append("Missing description for trait: %s" % trait)
	
	return errors

# ==============================================================================
# FILE OPERATIONS
# ==============================================================================

## Save species data to .tres file
static func save_species_to_file(species_data: SpeciesData, file_path: String) -> bool:
	var result = ResourceSaver.save(species_data, file_path)
	return result == OK

## Load species data from .tres file
static func load_species_from_file(file_path: String) -> SpeciesData:
	if not FileAccess.file_exists(file_path):
		push_error("Species file not found: " + file_path)
		return null
	
	var resource = load(file_path)
	if resource is SpeciesData:
		return resource as SpeciesData
	else:
		push_error("File is not a valid SpeciesData resource: " + file_path)
		return null

# ==============================================================================
# JSON EXPORT/IMPORT
# ==============================================================================

## Export species data to JSON for external editing
static func export_to_json(species_data: SpeciesData) -> String:
	var data = {
		"basic_info": {
			"species_name": species_data.species_name,
			"species_id": species_data.species_id,
			"description": species_data.description,
			"difficulty_rating": species_data.difficulty_rating,
			"lore_text": species_data.lore_text,
			"origin_biome": species_data.origin_biome,
			"natural_enemies": species_data.natural_enemies,
			"natural_allies": species_data.natural_allies
		},
		"stats": {
			"attack_modifier": species_data.attack_modifier,
			"defense_modifier": species_data.defense_modifier,
			"speed_modifier": species_data.speed_modifier,
			"health_modifier": species_data.health_modifier,
			"energy_modifier": species_data.energy_modifier,
			"food_efficiency": species_data.food_efficiency,
			"material_efficiency": species_data.material_efficiency,
			"water_efficiency": species_data.water_efficiency,
			"research_efficiency": species_data.research_efficiency
		},
		"population": {
			"reproduction_rate": species_data.reproduction_rate,
			"max_population_bonus": species_data.max_population_bonus,
			"worker_ratio": species_data.worker_ratio,
			"soldier_ratio": species_data.soldier_ratio
		},
		"abilities": {
			"special_abilities": species_data.special_abilities,
			"passive_traits": species_data.passive_traits,
			"ability_descriptions": species_data.ability_descriptions
		},
		"bonuses": {
			"building_bonuses": species_data.building_bonuses,
			"building_restrictions": species_data.building_restrictions,
			"research_bonuses": species_data.research_bonuses,
			"research_restrictions": species_data.research_restrictions
		},
		"ai": {
			"preferred_strategies": species_data.preferred_strategies,
			"ai_personality": species_data.ai_personality
		}
	}
	
	return JSON.stringify(data, "\t")

## Import species data from JSON
static func import_from_json(json_string: String) -> SpeciesData:
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse JSON: " + json.get_error_message())
		return null
	
	var data = json.data
	var species_data = SpeciesData.new()
	
	# Import basic info
	if data.has("basic_info"):
		var basic = data.basic_info
		species_data.species_name = basic.get("species_name", "")
		species_data.species_id = basic.get("species_id", "")
		species_data.description = basic.get("description", "")
		species_data.difficulty_rating = basic.get("difficulty_rating", 2)
		species_data.lore_text = basic.get("lore_text", "")
		species_data.origin_biome = basic.get("origin_biome", "forest")
		species_data.natural_enemies = basic.get("natural_enemies", [])
		species_data.natural_allies = basic.get("natural_allies", [])
	
	# Import stats
	if data.has("stats"):
		var stats = data.stats
		species_data.attack_modifier = stats.get("attack_modifier", 1.0)
		species_data.defense_modifier = stats.get("defense_modifier", 1.0)
		species_data.speed_modifier = stats.get("speed_modifier", 1.0)
		species_data.health_modifier = stats.get("health_modifier", 1.0)
		species_data.energy_modifier = stats.get("energy_modifier", 1.0)
		species_data.food_efficiency = stats.get("food_efficiency", 1.0)
		species_data.material_efficiency = stats.get("material_efficiency", 1.0)
		species_data.water_efficiency = stats.get("water_efficiency", 1.0)
		species_data.research_efficiency = stats.get("research_efficiency", 1.0)
	
	# Import other sections...
	# (Continue for population, abilities, bonuses, ai)
	
	return species_data

# ==============================================================================
# BATCH OPERATIONS
# ==============================================================================

## Apply balance changes to multiple species
static func apply_balance_patch(species_list: Array[SpeciesData], balance_data: Dictionary):
	for species in species_list:
		if balance_data.has(species.species_id):
			var changes = balance_data[species.species_id]
			
			# Apply stat changes
			if changes.has("stats"):
				var stats = changes.stats
				for stat_name in stats:
					if species.has_property(stat_name):
						species.set(stat_name, stats[stat_name])
			
			# Apply ability changes
			if changes.has("abilities"):
				var abilities = changes.abilities
				if abilities.has("add"):
					for ability in abilities.add:
						if not species.special_abilities.has(ability):
							species.special_abilities.append(ability)
				
				if abilities.has("remove"):
					for ability in abilities.remove:
						species.special_abilities.erase(ability)

## Generate balance report comparing all species
static func generate_balance_report(species_list: Array[SpeciesData]) -> String:
	var report = "SPECIES BALANCE REPORT\n"
	report += "=" * 50 + "\n\n"
	
	# Average stats
	var avg_attack = 0.0
	var avg_defense = 0.0
	var avg_speed = 0.0
	
	for species in species_list:
		avg_attack += species.attack_modifier
		avg_defense += species.defense_modifier
		avg_speed += species.speed_modifier
	
	var count = species_list.size()
	avg_attack /= count
	avg_defense /= count
	avg_speed /= count
	
	report += "Average Stats:\n"
	report += "Attack: %.2f\n" % avg_attack
	report += "Defense: %.2f\n" % avg_defense
	report += "Speed: %.2f\n" % avg_speed
	report += "\n"
	
	# Individual species analysis
	for species in species_list:
		report += "%s (%s):\n" % [species.species_name, species.species_id]
		report += "  Attack: %.2f (%.1f%% of avg)\n" % [species.attack_modifier, (species.attack_modifier / avg_attack) * 100]
		report += "  Defense: %.2f (%.1f%% of avg)\n" % [species.defense_modifier, (species.defense_modifier / avg_defense) * 100]
		report += "  Speed: %.2f (%.1f%% of avg)\n" % [species.speed_modifier, (species.speed_modifier / avg_speed) * 100]
		report += "  Abilities: %d\n" % species.special_abilities.size()
		report += "\n"
	
	return report
