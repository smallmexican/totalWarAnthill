# ==============================================================================
# SCRIPT ERROR FIX VERIFICATION
# ==============================================================================
# Purpose: Verify that all script compilation errors have been resolved
# 
# This test specifically checks for the errors that were occurring:
# 1. "Invalid cast" errors in strategic_map.gd
# 2. "Could not resolve class Resource" in species_data_simple.gd  
# 3. Compilation errors in species_stats_bar.gd
# 4. Class registration issues
# ==============================================================================

@tool
extends EditorScript

func _run():
	print("🔧 SCRIPT ERROR FIX VERIFICATION")
	print("=================================")
	
	# Test 1: SpeciesDataSimple resource loading (was failing with Resource conflict)
	test_species_data_simple()
	
	# Test 2: SpeciesStatsBar class registration (was failing to compile)
	test_species_stats_bar()
	
	# Test 3: Strategic Map script compilation (was failing with invalid cast)
	test_strategic_map_script()
	
	# Test 4: GameResource class (renamed from Resource to fix conflict)
	test_game_resource_class()
	
	# Test 5: Complete scene loading (end-to-end test)
	test_scene_loading()
	
	print("\n✅ VERIFICATION COMPLETE")
	print("If all tests pass, the script errors should be resolved!")

func test_species_data_simple():
	print("\n--- Testing SpeciesDataSimple Class ---")
	
	# Test class instantiation
	var species_data = SpeciesDataSimple.new()
	if species_data:
		species_data.species_name = "Test Species"
		species_data.attack_strength = 15
		species_data.defense_value = 12
		print("✅ SpeciesDataSimple instantiated successfully")
		print("   Name: ", species_data.species_name)
		print("   Attack: ", species_data.attack_strength)
		print("   Defense: ", species_data.defense_value)
		
		# Test resource loading
		var fire_ant_path = "res://data/species/fire_ant_simple.tres"
		if FileAccess.file_exists(fire_ant_path):
			var fire_ant = load(fire_ant_path) as SpeciesDataSimple
			if fire_ant:
				print("✅ Fire ant resource loads successfully")
				print("   Species: ", fire_ant.species_name)
			else:
				print("❌ Fire ant failed to load as SpeciesDataSimple")
		else:
			print("⚠️ Fire ant file not found (may need to be created)")
	else:
		print("❌ Failed to instantiate SpeciesDataSimple")

func test_species_stats_bar():
	print("\n--- Testing SpeciesStatsBar Class ---")
	
	# Test class instantiation
	var stats_bar = SpeciesStatsBar.new()
	if stats_bar:
		print("✅ SpeciesStatsBar instantiated successfully")
		print("   Type: ", stats_bar.get_class())
		
		# Test scene loading
		var scene_path = "res://scenes/ui/species_stats_bar.tscn"
		if FileAccess.file_exists(scene_path):
			var scene = load(scene_path)
			if scene:
				var instance = scene.instantiate()
				if instance:
					print("✅ SpeciesStatsBar scene loads and instantiates")
					instance.queue_free()
				else:
					print("❌ SpeciesStatsBar scene failed to instantiate")
			else:
				print("❌ SpeciesStatsBar scene failed to load")
		else:
			print("⚠️ SpeciesStatsBar scene file not found")
	else:
		print("❌ Failed to instantiate SpeciesStatsBar")

func test_strategic_map_script():
	print("\n--- Testing Strategic Map Script ---")
	
	# Test script loading
	var script_path = "res://scripts/game/strategic_map.gd"
	if FileAccess.file_exists(script_path):
		var script = load(script_path)
		if script:
			print("✅ Strategic map script loads successfully")
			
			# Test scene loading
			var scene_path = "res://scenes/game/StrategicMap.tscn"
			if FileAccess.file_exists(scene_path):
				var scene = load(scene_path)
				if scene:
					print("✅ Strategic map scene loads successfully")
				else:
					print("❌ Strategic map scene failed to load")
			else:
				print("⚠️ Strategic map scene file not found")
		else:
			print("❌ Strategic map script failed to load")
	else:
		print("❌ Strategic map script file not found")

func test_game_resource_class():
	print("\n--- Testing GameResource Class (Renamed from Resource) ---")
	
	# Test class instantiation  
	var game_resource = GameResource.new()
	if game_resource:
		print("✅ GameResource class instantiated successfully")
		print("   Type: ", game_resource.get_class())
	else:
		print("❌ Failed to instantiate GameResource")

func test_scene_loading():
	print("\n--- Testing Complete Scene Loading ---")
	
	# Test loading Strategic Map (the scene that was failing)
	var strategic_map_path = "res://scenes/game/StrategicMap.tscn"
	if FileAccess.file_exists(strategic_map_path):
		var strategic_map_scene = load(strategic_map_path)
		if strategic_map_scene:
			print("✅ Strategic map scene loads without script errors")
			
			# Try to instantiate (this would fail if scripts have errors)
			var instance = strategic_map_scene.instantiate()
			if instance:
				print("✅ Strategic map instantiates successfully")
				
				# Check for species stats bar
				var species_bar = instance.get_node_or_null("SpeciesStatsBar")
				if species_bar:
					print("✅ Species stats bar found in scene")
				else:
					print("⚠️ Species stats bar not found in scene")
				
				instance.queue_free()
			else:
				print("❌ Strategic map failed to instantiate")
		else:
			print("❌ Strategic map scene failed to load")
	else:
		print("❌ Strategic map scene file not found")
	
	print("\n🎯 End-to-End Test Complete!")
	print("If you see ✅ for all major tests, the script errors are fixed.")
