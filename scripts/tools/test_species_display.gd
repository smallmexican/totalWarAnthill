# Test script to simulate the full species selection to strategic map flow
@tool
extends EditorScript

func _run():
	print("🧪 Testing Species Display End-to-End Flow...")
	
	# Test 1: Load species data
	print("\n1️⃣ Testing species data loading...")
	var fire_ant_path = "res://data/species/fire_ant_simple.tres"
	
	if not FileAccess.file_exists(fire_ant_path):
		print("❌ Fire ant file not found: " + fire_ant_path)
		return
	
	var fire_ant = load(fire_ant_path) as SpeciesDataSimple
	if not fire_ant:
		print("❌ Failed to load fire ant as SpeciesDataSimple")
		return
	
	print("✅ Loaded fire ant: " + fire_ant.species_name)
	print("   Attack: " + str(fire_ant.attack_modifier))
	print("   Abilities: " + str(fire_ant.special_abilities))
	
	# Test 2: Create species stats bar
	print("\n2️⃣ Testing species stats bar...")
	var stats_bar_scene = preload("res://scenes/ui/species_stats_bar.tscn")
	var stats_bar = stats_bar_scene.instantiate()
	
	if not stats_bar:
		print("❌ Failed to instantiate species stats bar")
		return
	
	print("✅ Created species stats bar")
	
	# Test 3: Update stats bar with species data
	print("\n3️⃣ Testing stats bar update...")
	stats_bar.update_species_display(fire_ant)
	print("✅ Updated stats bar with fire ant data")
	
	# Test 4: Simulate game config
	print("\n4️⃣ Testing game configuration...")
	var test_config = {
		"player_species": "fire_ant",
		"opponent_species": "carpenter_ant", 
		"opponent_difficulty": "Normal",
		"map": "Garden Valley"
	}
	
	print("✅ Test config: " + str(test_config))
	
	# Test 5: Check strategic map integration
	print("\n5️⃣ Testing strategic map scene...")
	var strategic_map_scene = preload("res://scenes/game/StrategicMap.tscn")
	var strategic_map = strategic_map_scene.instantiate()
	
	if not strategic_map:
		print("❌ Failed to load strategic map")
		return
	
	print("✅ Loaded strategic map")
	
	# Check if it has the species stats bar
	var species_bar = strategic_map.get_node_or_null("SpeciesStatsBar")
	if species_bar:
		print("✅ Strategic map has species stats bar")
	else:
		print("❌ Strategic map missing species stats bar")
	
	# Check if it has the initialize method
	if strategic_map.has_method("initialize_with_gameplay"):
		print("✅ Strategic map has initialize_with_gameplay method")
		
		# Test the initialization (without actually running it)
		print("   Ready to test with config: " + str(test_config))
	else:
		print("❌ Strategic map missing initialize_with_gameplay method")
	
	# Cleanup
	stats_bar.queue_free()
	strategic_map.queue_free()
	
	print("\n🎉 End-to-end test completed!")
	print("\n📋 Next steps:")
	print("   1. Run a skirmish match from the menu")
	print("   2. Select 'Fire Ant' as your species")
	print("   3. Start the match to see species stats in the top bar")
	print("   4. The stats bar should show Fire Ant combat stats and abilities")
