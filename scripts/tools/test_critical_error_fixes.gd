# ==============================================================================
# CRITICAL ERROR FIX VERIFICATION
# ==============================================================================
# Purpose: Verify that all critical script compilation errors have been resolved
# 
# This test specifically checks for:
# 1. SpeciesManager parse errors and autoload functionality
# 2. Resource.gd type mismatch errors  
# 3. SpeciesDataSimple resource loading
# 4. Complete system integration
# ==============================================================================

@tool
extends EditorScript

func _run():
	print("🚨 CRITICAL ERROR FIX VERIFICATION")
	print("===================================")
	
	# Test 1: SpeciesManager autoload functionality
	test_species_manager_autoload()
	
	# Test 2: GameResource class functionality  
	test_game_resource_class()
	
	# Test 3: SpeciesDataSimple loading
	test_species_data_simple_loading()
	
	# Test 4: Strategic Map compilation
	test_strategic_map_compilation()
	
	# Test 5: Complete scene loading
	test_complete_scene_loading()
	
	print("\n🎯 CRITICAL ERROR VERIFICATION COMPLETE")
	print("If all tests pass, the critical script errors should be resolved!")

func test_species_manager_autoload():
	print("\n--- Testing SpeciesManager Autoload ---")
	
	# Test 1: Script compilation
	var species_manager_script_path = "res://scripts/core/systems/species_manager.gd"
	if FileAccess.file_exists(species_manager_script_path):
		var script = load(species_manager_script_path)
		if script:
			print("✅ SpeciesManager script compiles successfully")
			
			# Test 2: Can instantiate as Node
			var instance = script.new()
			if instance and instance is Node:
				print("✅ SpeciesManager instantiates as Node")
				
				# Test 3: Has required methods
				if instance.has_method("get_species_data"):
					print("✅ SpeciesManager has get_species_data method")
				else:
					print("❌ SpeciesManager missing get_species_data method")
				
				instance.queue_free()
			else:
				print("❌ SpeciesManager failed to instantiate as Node")
		else:
			print("❌ SpeciesManager script failed to load")
	else:
		print("❌ SpeciesManager script file not found")

func test_game_resource_class():
	print("\n--- Testing GameResource Class ---")
	
	# Test 1: Script compilation
	var resource_script_path = "res://scripts/core/entities/resource.gd"
	if FileAccess.file_exists(resource_script_path):
		var script = load(resource_script_path)
		if script:
			print("✅ GameResource script compiles successfully")
			
			# Test 2: Can instantiate
			var resource = script.new()
			if resource:
				print("✅ GameResource instantiates successfully")
				print("   Type: ", resource.get_class())
				
				# Test 3: Has expected properties
				if resource.has_method("set_resource_type"):
					print("✅ GameResource has expected methods")
				else:
					print("⚠️ GameResource methods may have changed")
				
				resource.queue_free()
			else:
				print("❌ GameResource failed to instantiate")
		else:
			print("❌ GameResource script failed to load")
	else:
		print("❌ GameResource script file not found")

func test_species_data_simple_loading():
	print("\n--- Testing SpeciesDataSimple Loading ---")
	
	# Test 1: Class instantiation
	var species_data = SpeciesDataSimple.new()
	if species_data:
		print("✅ SpeciesDataSimple class instantiates")
		
		# Test 2: Set properties
		species_data.species_name = "Test Species"
		species_data.attack_strength = 15
		species_data.defense_value = 12
		
		if species_data.species_name == "Test Species":
			print("✅ SpeciesDataSimple properties work correctly")
		else:
			print("❌ SpeciesDataSimple property assignment failed")
	else:
		print("❌ SpeciesDataSimple failed to instantiate")
	
	# Test 3: Resource file loading
	var fire_ant_path = "res://data/species/fire_ant_simple.tres"
	if FileAccess.file_exists(fire_ant_path):
		var fire_ant = load(fire_ant_path) as SpeciesDataSimple
		if fire_ant:
			print("✅ Fire ant resource loads successfully")
			print("   Species: ", fire_ant.species_name)
			print("   Attack: ", fire_ant.attack_strength)
		else:
			print("❌ Fire ant resource failed to load as SpeciesDataSimple")
	else:
		print("⚠️ Fire ant resource file not found (may need creation)")

func test_strategic_map_compilation():
	print("\n--- Testing Strategic Map Compilation ---")
	
	# Test 1: Script compilation
	var strategic_map_script_path = "res://scripts/game/strategic_map.gd"
	if FileAccess.file_exists(strategic_map_script_path):
		var script = load(strategic_map_script_path)
		if script:
			print("✅ Strategic Map script compiles successfully")
		else:
			print("❌ Strategic Map script failed to load")
	else:
		print("❌ Strategic Map script file not found")
	
	# Test 2: Scene compilation
	var strategic_map_scene_path = "res://scenes/game/StrategicMap.tscn"
	if FileAccess.file_exists(strategic_map_scene_path):
		var scene = load(strategic_map_scene_path)
		if scene:
			print("✅ Strategic Map scene loads successfully")
		else:
			print("❌ Strategic Map scene failed to load")
	else:
		print("❌ Strategic Map scene file not found")

func test_complete_scene_loading():
	print("\n--- Testing Complete Scene Loading ---")
	
	# Test the complete loading chain that was failing
	var strategic_map_path = "res://scenes/game/StrategicMap.tscn"
	if FileAccess.file_exists(strategic_map_path):
		print("📋 Attempting complete scene instantiation...")
		
		var scene = load(strategic_map_path)
		if scene:
			print("✅ Scene loaded successfully")
			
			var instance = scene.instantiate()
			if instance:
				print("✅ Scene instantiated without errors")
				
				# Check for key components
				var species_bar = instance.get_node_or_null("SpeciesStatsBar")
				if species_bar:
					print("✅ SpeciesStatsBar found in scene")
				else:
					print("⚠️ SpeciesStatsBar not found in scene")
				
				instance.queue_free()
				print("✅ Complete scene loading test PASSED")
			else:
				print("❌ Scene failed to instantiate")
		else:
			print("❌ Scene failed to load")
	else:
		print("❌ Strategic Map scene file not found")
	
	print("\n🎯 If you see ✅ for all critical tests, the errors should be fixed!")
	print("🔄 Restart Godot to ensure all autoloads are properly registered.")
