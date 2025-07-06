extends SceneTree

# Test the pause menu exactly as it would be loaded in the real game

func _init():
	print("=== REAL GAME CONTEXT PAUSE MENU TEST ===")
	
	# Load the main scene exactly like the game does
	var main_scene = preload("res://scenes/Main.tscn")
	var main = main_scene.instantiate()
	
	print("✅ Main scene loaded")
	
	# Add to root
	root.add_child(main)
	
	# Wait for ready
	await process_frame
	await process_frame  # Extra frame for safety
	
	print("✅ Main scene ready")
	
	# Load a game scene first (to simulate normal flow)
	if main.has_method("load_game_scene"):
		print("🔄 Loading Strategic Map...")
		main.load_game_scene("res://scenes/game/StrategicMap.tscn")
		await process_frame
		print("✅ Strategic Map loaded")
	
	# Now load the pause menu exactly like pressing P would
	if main.has_method("load_menu"):
		print("🔄 Loading Pause Menu through Main.gd...")
		main.load_menu("res://scenes/ui/PauseMenu.tscn")
		await process_frame
		await process_frame  # Extra frame for pause menu ready
		print("✅ Pause Menu loaded through Main.gd")
		
		# Find the pause menu in the menu layer
		var menu_layer = main.get_node_or_null("MenuLayer")
		if menu_layer and menu_layer.get_child_count() > 0:
			var pause_menu = menu_layer.get_child(0)
			print("✅ Found pause menu in MenuLayer: ", pause_menu.name)
			print("   Pause menu script: ", pause_menu.get_script())
			print("   Pause menu visible: ", pause_menu.visible)
			print("   Pause menu modulate: ", pause_menu.modulate)
			print("   Pause menu process_mode: ", pause_menu.process_mode)
			print("   Pause menu mouse_filter: ", pause_menu.mouse_filter)
			
			# Check if the resume button exists and is set up correctly
			var resume_button = pause_menu.get_node_or_null("MenuPanel/VBoxContainer/ResumeButton")
			if resume_button:
				print("✅ Resume button found in real game context")
				print("   Button visible: ", resume_button.visible)
				print("   Button disabled: ", resume_button.disabled)
				print("   Button modulate: ", resume_button.modulate)
				print("   Button mouse_filter: ", resume_button.mouse_filter)
				print("   Button size: ", resume_button.size)
				print("   Button global_position: ", resume_button.global_position)
				
				# Check signal connections in real context
				var connections = resume_button.get_signal_connection_list("pressed")
				print("🔍 Real context button signal connections: ", connections.size())
				for i in range(connections.size()):
					var conn = connections[i]
					print("   Connection ", i, ": ", conn.get("callable", "unknown"))
				
				# Test if the pause menu script method exists
				if pause_menu.has_method("_on_resume_button_pressed"):
					print("✅ Pause menu has _on_resume_button_pressed method")
					
					# Try calling the method directly
					print("🔄 Calling _on_resume_button_pressed directly...")
					pause_menu._on_resume_button_pressed()
					await process_frame
					
					# Check if menu is still there
					if menu_layer.get_child_count() == 0:
						print("✅ Direct method call worked - menu closed!")
					else:
						print("❌ Direct method call didn't close menu")
					
					# Reload menu for signal test
					main.load_menu("res://scenes/ui/PauseMenu.tscn")
					await process_frame
					pause_menu = menu_layer.get_child(0)
					resume_button = pause_menu.get_node_or_null("MenuPanel/VBoxContainer/ResumeButton")
					
					# Try emitting the signal
					print("🔄 Emitting pressed signal...")
					resume_button.pressed.emit()
					await process_frame
					
					# Check if menu is still there
					if menu_layer.get_child_count() == 0:
						print("✅ Signal emit worked - menu closed!")
					else:
						print("❌ Signal emit didn't close menu")
				else:
					print("❌ Pause menu missing _on_resume_button_pressed method!")
			else:
				print("❌ Resume button not found in real game context!")
		else:
			print("❌ No pause menu found in MenuLayer!")
	else:
		print("❌ Main doesn't have load_menu method!")
	
	print("=== REAL GAME CONTEXT PAUSE MENU TEST COMPLETE ===")
	quit()
