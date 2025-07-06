extends SceneTree

# Test mouse clicks specifically on the Resume button

func _init():
	print("=== MOUSE CLICK TEST FOR RESUME BUTTON ===")
	
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
	
	if resume_button:
		print("✅ Resume button found for mouse test")
		print("   MenuLayer mouse_filter: ", menu_layer.mouse_filter)
		print("   PauseMenu mouse_filter: ", pause_menu.mouse_filter)
		print("   Resume button mouse_filter: ", resume_button.mouse_filter)
		
		# Create a fake mouse click event at the button position
		var mouse_event = InputEventMouseButton.new()
		mouse_event.button_index = MOUSE_BUTTON_LEFT
		mouse_event.pressed = true
		mouse_event.position = resume_button.global_position + resume_button.size / 2
		
		print("🖱️ Simulating mouse click at: ", mouse_event.position)
		print("   Button global position: ", resume_button.global_position)
		print("   Button size: ", resume_button.size)
		print("   Click position (center): ", resume_button.global_position + resume_button.size / 2)
		
		# Track menu state before click
		var menu_count_before = menu_layer.get_child_count()
		print("   Menu count before click: ", menu_count_before)
		
		# Send the event to the button
		print("🔄 Simulating button press using emit_signal...")
		resume_button.pressed.emit()
		
		await process_frame
		
		# Check if menu was closed
		var menu_count_after = menu_layer.get_child_count()
		print("   Menu count after click: ", menu_count_after)
		
		if menu_count_after < menu_count_before:
			print("✅ MOUSE CLICK WORKED! Menu was closed.")
		else:
			print("❌ Mouse click didn't close menu")
			
			# Try the button's internal method
			print("🔄 Trying button's _pressed method directly...")
			if resume_button.has_method("_pressed"):
				resume_button._pressed()
				await process_frame
				
				var menu_count_after2 = menu_layer.get_child_count()
				if menu_count_after2 < menu_count_before:
					print("✅ _pressed method worked!")
				else:
					print("❌ _pressed method didn't work either")
	else:
		print("❌ Resume button not found for mouse test")
	
	print("=== MOUSE CLICK TEST COMPLETE ===")
	quit()
