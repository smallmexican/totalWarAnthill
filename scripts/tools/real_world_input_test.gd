# ==============================================================================
# REAL-WORLD INPUT TEST
# ==============================================================================
# Purpose: Test input in the actual game flow

extends SceneTree

func _init():
	print("🎮 REAL-WORLD INPUT TEST")
	print("========================================")
	
	# Load the main scene
	var main_scene = load("res://scenes/Main.tscn")
	if not main_scene:
		print("❌ Failed to load Main scene")
		quit()
		return
	
	var main_instance = main_scene.instantiate()
	root.add_child(main_instance)
	current_scene = main_instance
	
	print("✅ Main scene loaded")
	
	# Wait a moment for initialization
	await create_timer(1.0).timeout
	
	# Navigate to Strategic Map through normal flow
	print("🔍 Loading Strategic Map through normal flow...")
	
	# Create test skirmish config
	var test_config = {
		"player_species": "fire_ant",
		"opponent_species": "carpenter_ant"
	}
	
	# Load Strategic Map directly through the scene manager
	if main_instance.has_method("load_strategic_map"):
		main_instance.load_strategic_map(test_config)
		print("✅ Strategic Map loaded via load_strategic_map")
	elif main_instance.has_method("load_game_scene"):
		main_instance.load_game_scene("res://scenes/game/StrategicMap.tscn")
		print("✅ Strategic Map loaded via load_game_scene")
		
		# Initialize with config if possible
		await create_timer(0.5).timeout
		var strategic_map = current_scene
		if strategic_map and strategic_map.has_method("initialize_with_gameplay"):
			strategic_map.initialize_with_gameplay(test_config)
			print("✅ Strategic Map initialized with test config")
	else:
		print("❌ No method found to load Strategic Map")
		quit()
		return
	
	# Wait for loading
	await create_timer(2.0).timeout
	
	print("\n🔍 Current scene after loading: ", current_scene.name if current_scene else "NONE")
	
	# Check if Strategic Map is ready
	if current_scene and current_scene.name == "StrategicMap":
		print("✅ Strategic Map is active scene")
		
		# Test manual input simulation
		print("🔍 Simulating input events...")
		
		# Test C key
		print("   Testing C key...")
		simulate_key_press(KEY_C)
		await create_timer(1.0).timeout
		
		print("🔍 Input test complete - Check output above for input detection")
	else:
		print("❌ Strategic Map is not the active scene")
	
	quit()

func simulate_key_press(keycode: int):
	var key_event = InputEventKey.new()
	key_event.keycode = keycode
	key_event.pressed = true
	
	print("   Sending key event: ", keycode)
	Input.parse_input_event(key_event)
