extends SceneTree

# Test the pause menu in the context of the actual game

func _init():
	print("=== GAME PAUSE MENU INTEGRATION TEST ===")
	
	# Load the main scene
	var main_scene = preload("res://scenes/Main.tscn")
	var main = main_scene.instantiate()
	
	print("✅ Main scene loaded")
	
	# Add to root
	root.add_child(main)
	
	# Wait for ready
	await process_frame
	
	print("✅ Main scene added and ready")
	
	# Navigate to Strategic Map
	if main.has_method("load_game_scene"):
		print("🔄 Loading Strategic Map...")
		main.load_game_scene("res://scenes/game/StrategicMap.tscn")
		await process_frame
		print("✅ Strategic Map loaded")
	else:
		print("❌ Main scene doesn't have load_game_scene method")
		quit()
		return
	
	# Wait a bit for everything to settle
	await process_frame
	
	# Now try to open pause menu
	if main.has_method("load_menu"):
		print("🔄 Opening Pause Menu...")
		main.load_menu("res://scenes/ui/PauseMenu.tscn")
		await process_frame
		print("✅ Pause Menu should be open")
		
		# Find the pause menu
		var menu_layer = main.get_node_or_null("MenuLayer")
		if menu_layer and menu_layer.get_child_count() > 0:
			var pause_menu = menu_layer.get_child(0)
			print("✅ Pause menu found in MenuLayer: ", pause_menu.name)
			
			# Find the Resume button
			var resume_button = pause_menu.get_node_or_null("MenuPanel/VBoxContainer/ResumeButton")
			if resume_button:
				print("✅ Resume button found in game context")
				print("   Button text: ", resume_button.text)
				print("   Button disabled: ", resume_button.disabled)
				print("   Button visible: ", resume_button.visible)
				
				# Test the button press
				print("🔄 Testing Resume button press...")
				resume_button.emit_signal("pressed")
				await process_frame
				
				# Check if menu is still there (should be gone)
				if menu_layer.get_child_count() == 0:
					print("✅ Resume button worked - menu is closed!")
				else:
					print("❌ Resume button didn't work - menu is still open")
			else:
				print("❌ Resume button not found in game context")
		else:
			print("❌ Pause menu not found in MenuLayer")
	else:
		print("❌ Main scene doesn't have load_menu method")
	
	print("=== GAME PAUSE MENU INTEGRATION TEST COMPLETE ===")
	quit()
