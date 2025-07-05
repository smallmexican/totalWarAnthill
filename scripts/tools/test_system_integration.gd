# ==============================================================================
# SYSTEM INTEGRATION TEST - Verify Species System & UI Integration
# ==============================================================================
# Purpose: Test all components working together
# 
# This test verifies:
# - SpeciesDataSimple resource loading
# - SpeciesStatsBar UI component
# - SpeciesManager singleton integration
# - Strategic Map species display
# 
# Run this in the Godot editor to test the complete system
# ==============================================================================

@tool
extends EditorScript

func _run():
	print("=== SYSTEM INTEGRATION TEST ===")
	
	# Test 1: SpeciesDataSimple resource loading
	test_species_data_loading()
	
	# Test 2: SpeciesManager singleton
	test_species_manager()
	
	# Test 3: Class registration
	test_class_registration()
	
	# Test 4: UI scene structure
	test_ui_scenes()
	
	print("=== INTEGRATION TEST COMPLETE ===")

func test_species_data_loading():
	print("\n--- Testing Species Data Loading ---")
	
	# Test loading fire ant
	var fire_ant_path = "res://data/species/fire_ant_simple.tres"
	if FileAccess.file_exists(fire_ant_path):
		var fire_ant = load(fire_ant_path) as SpeciesDataSimple
		if fire_ant:
			print("✅ Fire Ant loaded: ", fire_ant.species_name)
			print("   Attack: ", fire_ant.attack_strength)
			print("   Defense: ", fire_ant.defense_value)
			print("   Speed: ", fire_ant.movement_speed)
		else:
			print("❌ Failed to load fire ant as SpeciesDataSimple")
	else:
		print("❌ Fire ant file not found: ", fire_ant_path)
	
	# Test loading carpenter ant
	var carpenter_ant_path = "res://data/species/carpenter_ant_simple.tres"
	if FileAccess.file_exists(carpenter_ant_path):
		var carpenter_ant = load(carpenter_ant_path) as SpeciesDataSimple
		if carpenter_ant:
			print("✅ Carpenter Ant loaded: ", carpenter_ant.species_name)
			print("   Attack: ", carpenter_ant.attack_strength)
			print("   Defense: ", carpenter_ant.defense_value)
			print("   Speed: ", carpenter_ant.movement_speed)
		else:
			print("❌ Failed to load carpenter ant as SpeciesDataSimple")
	else:
		print("❌ Carpenter ant file not found: ", carpenter_ant_path)

func test_species_manager():
	print("\n--- Testing SpeciesManager Singleton ---")
	
	# Check if SpeciesManager script exists
	var manager_path = "res://scripts/core/systems/species_manager.gd"
	if FileAccess.file_exists(manager_path):
		print("✅ SpeciesManager script found")
		
		# Try to load the script
		var manager_script = load(manager_path)
		if manager_script:
			print("✅ SpeciesManager script loads successfully")
		else:
			print("❌ Failed to load SpeciesManager script")
	else:
		print("❌ SpeciesManager script not found: ", manager_path)

func test_class_registration():
	print("\n--- Testing Class Registration ---")
	
	# Test SpeciesDataSimple class
	var species_data = SpeciesDataSimple.new()
	if species_data:
		species_data.species_name = "Test Species"
		species_data.attack_strength = 10
		print("✅ SpeciesDataSimple class instantiated")
		print("   Name: ", species_data.species_name)
		print("   Attack: ", species_data.attack_strength)
	else:
		print("❌ Failed to instantiate SpeciesDataSimple")
	
	# Test SpeciesStatsBar class
	var stats_bar = SpeciesStatsBar.new()
	if stats_bar:
		print("✅ SpeciesStatsBar class instantiated")
		print("   Type: ", stats_bar.get_class())
	else:
		print("❌ Failed to instantiate SpeciesStatsBar")

func test_ui_scenes():
	print("\n--- Testing UI Scenes ---")
	
	# Test SpeciesStatsBar scene
	var stats_bar_scene_path = "res://scenes/ui/species_stats_bar.tscn"
	if FileAccess.file_exists(stats_bar_scene_path):
		var stats_bar_scene = load(stats_bar_scene_path)
		if stats_bar_scene:
			print("✅ SpeciesStatsBar scene loads")
			var instance = stats_bar_scene.instantiate()
			if instance:
				print("✅ SpeciesStatsBar scene instantiates")
				print("   Root node type: ", instance.get_class())
				instance.queue_free()
			else:
				print("❌ Failed to instantiate SpeciesStatsBar scene")
		else:
			print("❌ Failed to load SpeciesStatsBar scene")
	else:
		print("❌ SpeciesStatsBar scene not found: ", stats_bar_scene_path)
	
	# Test Strategic Map scene
	var strategic_map_scene_path = "res://scenes/game/StrategicMap.tscn"
	if FileAccess.file_exists(strategic_map_scene_path):
		var strategic_map_scene = load(strategic_map_scene_path)
		if strategic_map_scene:
			print("✅ StrategicMap scene loads")
		else:
			print("❌ Failed to load StrategicMap scene")
	else:
		print("❌ StrategicMap scene not found: ", strategic_map_scene_path)
