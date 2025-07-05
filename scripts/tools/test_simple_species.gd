# Test script to verify the simplified species system works
@tool
extends EditorScript

func _run():
	print("🧪 Testing Simplified Species System...")
	
	# Test 1: Create a new species
	print("\n1️⃣ Testing species creation...")
	var species = SpeciesDataSimple.new()
	species.species_name = "Test Ant"
	species.species_id = "test_ant"
	species.description = "A test species"
	species.difficulty_rating = 1
	species.attack_modifier = 1.2
	species.special_abilities = ["test_ability"]
	
	print("✓ Created species: " + species.get_display_name())
	print("✓ Summary: " + species.get_summary())
	
	# Test 2: Save species to file
	print("\n2️⃣ Testing file save...")
	var save_path = "res://data/species/test_species.tres"
	var result = ResourceSaver.save(species, save_path)
	
	if result == OK:
		print("✓ Successfully saved to: " + save_path)
	else:
		print("✗ Failed to save. Error: " + str(result))
		return
	
	# Test 3: Load species from file
	print("\n3️⃣ Testing file load...")
	var loaded_species = load(save_path) as SpeciesDataSimple
	
	if loaded_species:
		print("✓ Successfully loaded: " + loaded_species.species_name)
		print("✓ Attack modifier: " + str(loaded_species.attack_modifier))
		print("✓ Abilities: " + str(loaded_species.special_abilities))
	else:
		print("✗ Failed to load species")
		return
	
	# Test 4: Load existing simple species
	print("\n4️⃣ Testing existing species files...")
	var fire_ant_path = "res://data/species/fire_ant_simple.tres"
	
	if FileAccess.file_exists(fire_ant_path):
		var fire_ant = load(fire_ant_path) as SpeciesDataSimple
		if fire_ant:
			print("✓ Loaded Fire Ant: " + fire_ant.get_display_name())
			print("✓ Has fire_attack ability: " + str(fire_ant.has_ability("fire_attack")))
		else:
			print("✗ Failed to load fire ant as SpeciesDataSimple")
	else:
		print("⚠ Fire ant simple file not found")
	
	print("\n🎉 Species system test completed!")
