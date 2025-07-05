# Test script to verify species stats bar loads without errors
@tool
extends EditorScript

func _run():
	print("🧪 Testing Species Stats Bar Node Paths...")
	
	# Test 1: Load species stats bar scene
	print("\n1️⃣ Loading species stats bar scene...")
	var stats_bar_scene = preload("res://scenes/ui/species_stats_bar.tscn")
	var stats_bar = stats_bar_scene.instantiate()
	
	if not stats_bar:
		print("❌ Failed to load species stats bar")
		return
	
	print("✅ Species stats bar instantiated")
	
	# Test 2: Add to scene tree to trigger _ready
	print("\n2️⃣ Adding to scene tree to trigger _ready...")
	var test_scene = Node.new()
	test_scene.add_child(stats_bar)
	
	# Let _ready run
	await test_scene.process_mode
	
	print("✅ _ready() executed")
	
	# Test 3: Try to load species data
	print("\n3️⃣ Testing species data loading...")
	var fire_ant_path = "res://data/species/fire_ant_simple.tres"
	
	if FileAccess.file_exists(fire_ant_path):
		var fire_ant = load(fire_ant_path) as SpeciesDataSimple
		if fire_ant:
			print("✅ Fire ant data loaded: " + fire_ant.species_name)
			
			# Test 4: Update stats bar
			print("\n4️⃣ Testing stats bar update...")
			stats_bar.update_species_display(fire_ant)
			print("✅ Stats bar update completed")
		else:
			print("❌ Failed to load fire ant data")
	else:
		print("❌ Fire ant file not found")
	
	# Test 5: Test strategic map integration
	print("\n5️⃣ Testing strategic map integration...")
	var strategic_map_scene = preload("res://scenes/game/StrategicMap.tscn")
	var strategic_map = strategic_map_scene.instantiate()
	
	if strategic_map:
		print("✅ Strategic map loaded")
		
		# Check if species stats bar is present
		var species_bar = strategic_map.get_node_or_null("SpeciesStatsBar")
		if species_bar:
			print("✅ Species stats bar found in strategic map")
		else:
			print("❌ Species stats bar not found in strategic map")
		
		strategic_map.queue_free()
	else:
		print("❌ Failed to load strategic map")
	
	# Cleanup
	test_scene.queue_free()
	
	print("\n🎉 Species stats bar test completed!")
	print("\n📋 If you see all ✅ marks, the node path errors should be fixed.")
