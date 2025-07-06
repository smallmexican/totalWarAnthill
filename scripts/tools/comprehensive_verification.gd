# ==============================================================================
# COMPREHENSIVE FIX VERIFICATION - Test all fixed components
# ==============================================================================

extends Node

func _ready():
	print("🔧 COMPREHENSIVE FIX VERIFICATION...")
	
	# Test 1: SpeciesDataSimple
	print("\n1. Testing SpeciesDataSimple...")
	test_species_data_simple()
	
	# Test 2: Resource files
	print("\n2. Testing resource files...")
	test_resource_files()
	
	# Test 3: Colony script compilation
	print("\n3. Testing Colony script...")
	test_colony_script()
	
	# Test 4: Ant script compilation
	print("\n4. Testing Ant script...")
	test_ant_script()
	
	# Test 5: SpeciesManager
	print("\n5. Testing SpeciesManager...")
	test_species_manager()
	
	print("\n🔧 VERIFICATION COMPLETE!")
	print("If all tests pass, script errors should be resolved!")
	
	# Auto-quit after 3 seconds
	await get_tree().create_timer(3.0).timeout
	get_tree().quit()

func test_species_data_simple():
	var species = SpeciesDataSimple.new()
	species.species_name = "Test Species"
	species.attack_modifier = 1.5
	species.defense_modifier = 1.2
	species.special_abilities = ["test_ability"]
	print("   ✅ SpeciesDataSimple creation successful")
	print("      Name: ", species.species_name)
	print("      Attack: ", species.attack_modifier)

func test_resource_files():
	# Test fire ant
	var fire_ant_path = "res://data/species/fire_ant_simple.tres"
	var fire_ant = load(fire_ant_path)
	if fire_ant:
		print("   ✅ fire_ant_simple.tres loaded successfully")
		print("      Name: ", fire_ant.species_name)
		print("      Abilities: ", fire_ant.special_abilities if fire_ant.has_method("get") else "N/A")
	else:
		print("   ❌ Failed to load fire_ant_simple.tres")
	
	# Test carpenter ant
	var carpenter_ant_path = "res://data/species/carpenter_ant_simple.tres"
	var carpenter_ant = load(carpenter_ant_path)
	if carpenter_ant:
		print("   ✅ carpenter_ant_simple.tres loaded successfully")
		print("      Name: ", carpenter_ant.species_name)
	else:
		print("   ❌ Failed to load carpenter_ant_simple.tres")

func test_colony_script():
	var colony_script = load("res://scripts/core/entities/colony.gd")
	if colony_script:
		print("   ✅ Colony script compiles without errors")
		
		# Test creating a colony instance
		var colony = colony_script.new()
		colony.colony_name = "Test Colony"
		colony.current_population = 10
		print("      ✅ Colony instance created successfully")
		print("         Name: ", colony.colony_name)
		print("         Population: ", colony.current_population)
	else:
		print("   ❌ Colony script has compilation errors")

func test_ant_script():
	var ant_script = load("res://scripts/core/entities/ant.gd")
	if ant_script:
		print("   ✅ Ant script compiles without errors")
		
		# Test creating an ant instance
		var ant = ant_script.new()
		ant.ant_type = "Worker"
		ant.species = "Fire Ant"
		print("      ✅ Ant instance created successfully")
		print("         Type: ", ant.ant_type)
		print("         Species: ", ant.species)
	else:
		print("   ❌ Ant script has compilation errors")

func test_species_manager():
	if SpeciesManager:
		print("   ✅ SpeciesManager singleton accessible")
		var species_list = SpeciesManager.get_available_species()
		print("      Available species: ", species_list.size())
		
		for species_id in species_list:
			var species_data = SpeciesManager.get_species_data(species_id)
			if species_data:
				print("         - ", species_data.species_name, " (", species_id, ")")
		
		# Test getting a specific species
		var fire_ant = SpeciesManager.get_species_data("fire_ant")
		if fire_ant:
			print("      ✅ Fire ant data accessible via SpeciesManager")
		else:
			print("      ⚠️ Fire ant data not accessible (may still be loading)")
	else:
		print("   ❌ SpeciesManager not accessible")
