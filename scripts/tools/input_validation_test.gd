# ==============================================================================
# INPUT VALIDATION TEST
# ==============================================================================
# Purpose: Simple test to validate Strategic Map input detection

extends SceneTree

func _init():
	print("🔍 INPUT VALIDATION TEST")
	print("========================================")
	
	# Load and instantiate the Strategic Map
	var strategic_map_scene = load("res://scenes/game/StrategicMap.tscn")
	if not strategic_map_scene:
		print("❌ Failed to load Strategic Map scene")
		quit()
		return
	
	var instance = strategic_map_scene.instantiate()
	
	# Add to tree
	root.add_child(instance)
	current_scene = instance
	
	# Initialize with test config
	var test_config = {
		"player_species": "fire_ant",
		"opponent_species": "carpenter_ant"
	}
	
	if instance.has_method("initialize_with_gameplay"):
		instance.initialize_with_gameplay(test_config)
	
	print("✅ Strategic Map loaded and ready")
	print("   - Scene is in tree: ", instance.is_inside_tree())
	print("   - Current scene: ", current_scene.name if current_scene else "NONE")
	
	# Wait 1 second then simulate input
	await create_timer(1.0).timeout
	
	print("\n🔍 Testing keyboard input detection...")
	
	# Create and send keyboard events
	test_key_input(KEY_ESCAPE, "ESC")
	await create_timer(0.5).timeout
	
	test_key_input(KEY_C, "C")
	await create_timer(0.5).timeout
	
	test_key_input(KEY_P, "P")
	await create_timer(0.5).timeout
	
	print("\n✅ Input test complete")
	quit()

func test_key_input(keycode: int, key_name: String):
	print("   Simulating ", key_name, " key press...")
	
	var key_event = InputEventKey.new()
	key_event.keycode = keycode
	key_event.pressed = true
	
	# Send the input event
	Input.parse_input_event(key_event)
	
	# Also try through viewport
	root.get_viewport()._input(key_event)
