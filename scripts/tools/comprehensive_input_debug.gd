extends SceneTree

# Comprehensive test to debug all input issues in pause menu

func _init():
	print("=== COMPREHENSIVE PAUSE MENU INPUT DEBUG TEST ===")
	
	# Load the main scene
	var main_scene = preload("res://scenes/Main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	
	# Load Strategic Map
	main.load_game_scene("res://scenes/game/StrategicMap.tscn")
	await process_frame
	
	# Load Pause Menu
	main.load_menu("res://scenes/ui/PauseMenu.tscn")
	await process_frame
	await process_frame
	
	print("✅ Game and pause menu loaded")
	
	# Find components
	var menu_layer = main.get_node_or_null("MenuLayer")
	var pause_menu = menu_layer.get_child(0) if menu_layer.get_child_count() > 0 else null
	var resume_button = pause_menu.get_node_or_null("MenuPanel/VBoxContainer/ResumeButton") if pause_menu else null
	
	if pause_menu and resume_button:
		print("\n🔍 DETAILED PAUSE MENU STATE:")
		print("   Pause menu class: ", pause_menu.get_class())
		print("   Pause menu script: ", pause_menu.get_script())
		print("   Pause menu visible: ", pause_menu.visible)
		print("   Pause menu modulate: ", pause_menu.modulate)
		print("   Pause menu process_mode: ", pause_menu.process_mode)
		print("   Pause menu mouse_filter: ", pause_menu.mouse_filter)
		print("   Pause menu z_index: ", pause_menu.z_index)
		print("   Pause menu has focus: ", pause_menu.has_focus())
		
		print("\n🔍 RESUME BUTTON STATE:")
		print("   Button class: ", resume_button.get_class())
		print("   Button text: ", resume_button.text)
		print("   Button disabled: ", resume_button.disabled)
		print("   Button visible: ", resume_button.visible)
		print("   Button modulate: ", resume_button.modulate)
		print("   Button mouse_filter: ", resume_button.mouse_filter)
		print("   Button focus_mode: ", resume_button.focus_mode)
		print("   Button has focus: ", resume_button.has_focus())
		print("   Button flat: ", resume_button.flat)
		print("   Button global_position: ", resume_button.global_position)
		print("   Button size: ", resume_button.size)
		print("   Button global_rect: ", resume_button.get_global_rect())
		
		print("\n🔍 SIGNAL CONNECTIONS:")
		var connections = resume_button.get_signal_connection_list("pressed")
		print("   'pressed' signal connections: ", connections.size())
		for i in range(connections.size()):
			var conn = connections[i]
			print("     ", i, ": target=", conn.get("callable", "unknown"))
		
		print("\n🔍 INPUT PROCESSING CHAIN:")
		print("   Root can_process: ", root.can_process())
		print("   Main can_process: ", main.can_process() if main.has_method("can_process") else "N/A")
		print("   MenuLayer can_process: ", menu_layer.can_process() if menu_layer.has_method("can_process") else "N/A")
		print("   PauseMenu can_process: ", pause_menu.can_process() if pause_menu.has_method("can_process") else "N/A")
		print("   ResumeButton can_process: ", resume_button.can_process() if resume_button.has_method("can_process") else "N/A")
		
		# Test direct method calls
		print("\n🔄 TESTING DIRECT METHOD CALLS:")
		
		# 1. Test if the method exists and can be called
		if pause_menu.has_method("_on_resume_button_pressed"):
			print("✅ _on_resume_button_pressed method exists")
			
			var menu_count_before = menu_layer.get_child_count()
			print("   Menu count before direct call: ", menu_count_before)
			
			print("🔄 Calling _on_resume_button_pressed directly...")
			pause_menu._on_resume_button_pressed()
			await process_frame
			
			var menu_count_after = menu_layer.get_child_count()
			print("   Menu count after direct call: ", menu_count_after)
			
			if menu_count_after < menu_count_before:
				print("✅ Direct method call works!")
			else:
				print("❌ Direct method call failed")
		else:
			print("❌ _on_resume_button_pressed method missing!")
		
		# Reload pause menu for signal test
		main.load_menu("res://scenes/ui/PauseMenu.tscn")
		await process_frame
		pause_menu = menu_layer.get_child(0)
		resume_button = pause_menu.get_node_or_null("MenuPanel/VBoxContainer/ResumeButton")
		
		# 2. Test signal emission
		print("\n🔄 TESTING SIGNAL EMISSION:")
		var menu_count_before2 = menu_layer.get_child_count()
		print("   Menu count before signal: ", menu_count_before2)
		
		print("🔄 Emitting pressed signal...")
		resume_button.pressed.emit()
		await process_frame
		
		var menu_count_after2 = menu_layer.get_child_count()
		print("   Menu count after signal: ", menu_count_after2)
		
		if menu_count_after2 < menu_count_before2:
			print("✅ Signal emission works!")
		else:
			print("❌ Signal emission failed")
		
		# Reload pause menu for input test
		main.load_menu("res://scenes/ui/PauseMenu.tscn")
		await process_frame
		pause_menu = menu_layer.get_child(0)
		resume_button = pause_menu.get_node_or_null("MenuPanel/VBoxContainer/ResumeButton")
		
		# 3. Test ESC key handling
		print("\n🔄 TESTING ESC KEY INPUT:")
		
		# Connect to input signals to monitor
		if not pause_menu.is_connected("tree_exiting", _on_pause_menu_exiting):
			pause_menu.tree_exiting.connect(_on_pause_menu_exiting)
		
		# Create ESC key event
		var esc_event = InputEventKey.new()
		esc_event.keycode = KEY_ESCAPE
		esc_event.pressed = true
		
		print("🔄 Sending ESC key event to pause menu...")
		print("   Before ESC - MenuLayer children: ", menu_layer.get_child_count())
		
		# Send to pause menu directly
		if pause_menu.has_method("_input"):
			pause_menu._input(esc_event)
		
		# Also send to main for comparison
		if main.has_method("_input"):
			print("🔄 Also sending ESC to Main scene...")
			main._input(esc_event)
		
		await process_frame
		await process_frame
		
		print("   After ESC - MenuLayer children: ", menu_layer.get_child_count())
		if menu_layer.get_child_count() > 0:
			var current_menu = menu_layer.get_child(0)
			print("   Current menu after ESC: ", current_menu.name if current_menu else "None")
		
		# 4. Test mouse click simulation
		print("\n🔄 TESTING MOUSE CLICK SIMULATION:")
		
		# Check if we have a pause menu to test
		if menu_layer.get_child_count() > 0:
			pause_menu = menu_layer.get_child(0)
			resume_button = pause_menu.get_node_or_null("MenuPanel/VBoxContainer/ResumeButton")
			
			if resume_button:
				# Try to simulate actual button press detection
				print("🔄 Simulating button press detection...")
				
				# Check if button can receive mouse input
				var button_rect = resume_button.get_global_rect()
				var test_point = button_rect.get_center()
				
				print("   Button rect: ", button_rect)
				print("   Test point: ", test_point)
				
				# Test if point is inside button
				var point_in_button = button_rect.has_point(test_point)
				print("   Point in button rect: ", point_in_button)
				
				# Simulate button press using internal method
				if resume_button.has_method("_pressed"):
					print("🔄 Calling button._pressed()...")
					resume_button._pressed()
					await process_frame
		
		print("\n=== FINAL STATE CHECK ===")
		print("   MenuLayer children: ", menu_layer.get_child_count())
		if menu_layer.get_child_count() > 0:
			var final_menu = menu_layer.get_child(0)
			print("   Final menu: ", final_menu.name if final_menu else "None")
		
	else:
		print("❌ Pause menu or resume button not found!")
	
	print("\n=== COMPREHENSIVE INPUT DEBUG TEST COMPLETE ===")
	quit()

func _on_pause_menu_exiting():
	print("🔔 Pause menu is exiting!")
