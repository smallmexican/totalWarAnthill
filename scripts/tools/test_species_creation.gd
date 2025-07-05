# Test script to create a simple species resource
@tool
extends EditorScript

func _run():
	# Create a new SpeciesData instance
	var species_data = SpeciesData.new()
	
	# Set basic properties
	species_data.species_name = "Test Ant"
	species_data.species_id = "test_ant"
	species_data.description = "A test ant species"
	species_data.difficulty_rating = 1
	
	# Set basic stats
	species_data.attack_modifier = 1.0
	species_data.defense_modifier = 1.0
	species_data.speed_modifier = 1.0
	species_data.health_modifier = 1.0
	species_data.energy_modifier = 1.0
	
	# Save the resource
	var save_path = "res://data/species/test_ant.tres"
	var result = ResourceSaver.save(species_data, save_path)
	
	if result == OK:
		print("✅ Successfully created test species at: ", save_path)
	else:
		print("❌ Failed to create test species. Error: ", result)
