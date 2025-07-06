# ==============================================================================
# FINAL INPUT DEBUG TEST
# ==============================================================================
# Purpose: Debug why input is not working on Strategic Map
# This test will check scene focus, input configuration, and process modes

extends SceneTree

func _init():
	print("🔍 FINAL INPUT DEBUG TEST STARTING")
	print("="*50)
	
	# Change to the Strategic Map scene
	var strategic_map_scene = load("res://scenes/game/StrategicMap.tscn")
	if strategic_map_scene:
		print("✅ Strategic Map scene loaded")
		var instance = strategic_map_scene.instantiate()
		
		# Initialize with test config
		var test_config = {
			"player_species": "fire_ant",
			"opponent_species": "carpenter_ant"
		}
		
		if instance.has_method("initialize_with_gameplay"):
			instance.initialize_with_gameplay(test_config)
			print("✅ Strategic Map initialized with test config")
		
		# Set as current scene
		current_scene = instance
		root.add_child(instance)
		print("✅ Strategic Map set as current scene")
		
		# Wait a frame then check input state
		await process_frame
		
		# Debug input state
		debug_input_state(instance)
		
		# Test input handling
		test_input_handling(instance)
		
	else:
		print("❌ Failed to load Strategic Map scene")
	
	print("="*50)
	print("🔍 INPUT DEBUG TEST COMPLETE")
	quit()

func debug_input_state(scene_instance):
	print("\n🔍 DEBUGGING INPUT STATE:")
	print("   Current scene: ", current_scene.name if current_scene else "NONE")
	print("   Scene instance name: ", scene_instance.name)
	print("   Scene process mode: ", scene_instance.process_mode)
	print("   Scene can process: ", scene_instance.can_process())
	
	# Check if the scene is actually active
	print("   Scene is inside tree: ", scene_instance.is_inside_tree())
	print("   Scene has focus: ", scene_instance.has_focus() if scene_instance.has_method("has_focus") else "N/A")
	
	# Check viewport input handling
	var viewport = scene_instance.get_viewport()
	if viewport:
		print("   Viewport: ", viewport.name)
		print("   Viewport GUI disabled: ", viewport.gui_disable_input)
		print("   Viewport physics object picking: ", viewport.physics_object_picking)
	
	# Check UILayer
	var ui_layer = scene_instance.get_node_or_null("UILayer")
	if ui_layer:
		print("   UILayer found: ", ui_layer.name)
		print("   UILayer process mode: ", ui_layer.process_mode)
		print("   UILayer enabled: ", ui_layer.enabled)
		print("   UILayer layer: ", ui_layer.layer)
		
		# Check children
		var species_bar = ui_layer.get_node_or_null("SpeciesStatsBar")
		if species_bar:
			print("   SpeciesStatsBar mouse filter: ", species_bar.mouse_filter)
			print("   SpeciesStatsBar process mode: ", species_bar.process_mode)
		
		var colony_button = ui_layer.get_node_or_null("ColonyButton")
		if colony_button:
			print("   ColonyButton mouse filter: ", colony_button.mouse_filter)
			print("   ColonyButton process mode: ", colony_button.process_mode)
			print("   ColonyButton visible: ", colony_button.visible)
			print("   ColonyButton disabled: ", colony_button.disabled)

func test_input_handling(scene_instance):
	print("\n🔍 TESTING INPUT HANDLING:")
	
	# Test if _unhandled_input method exists
	if scene_instance.has_method("_unhandled_input"):
		print("✅ _unhandled_input method exists")
	else:
		print("❌ _unhandled_input method missing!")
	
	# Test if _input method exists
	if scene_instance.has_method("_input"):
		print("✅ _input method exists")
	else:
		print("❌ _input method missing")
	
	# Check input map
	var input_map = InputMap
	print("   ui_cancel action exists: ", input_map.has_action("ui_cancel"))
	if input_map.has_action("ui_cancel"):
		var events = input_map.action_get_events("ui_cancel")
		print("   ui_cancel events: ", events.size())
		for event in events:
			if event is InputEventKey:
				print("     Key event: ", event.keycode, " (", OS.get_keycode_string(event.keycode), ")")
	
	# Simulate input events
	print("\n🔍 SIMULATING INPUT EVENTS:")
	
	# Create ESC key event
	var esc_event = InputEventKey.new()
	esc_event.keycode = KEY_ESCAPE
	esc_event.pressed = true
	
	print("   Simulating ESC key press...")
	Input.parse_input_event(esc_event)
	
	# Wait a frame
	await process_frame
	
	# Create C key event
	var c_event = InputEventKey.new()
	c_event.keycode = KEY_C
	c_event.pressed = true
	
	print("   Simulating C key press...")
	Input.parse_input_event(c_event)
	
	# Wait a frame
	await process_frame
	
	print("   Input simulation complete")
