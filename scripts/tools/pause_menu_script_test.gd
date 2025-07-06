extends SceneTree

# Test to check if pause menu script is even loading and if button events are being received

func _init():
	print("=== PAUSE MENU SCRIPT LOADING TEST ===")
	
	# Load the pause menu scene
	var pause_menu_scene = preload("res://scenes/ui/PauseMenu.tscn")
	var pause_menu = pause_menu_scene.instantiate()
	
	print("✅ Pause menu scene instantiated")
	
	# Add to root
	root.add_child(pause_menu)
	
	# Wait for ready
	await process_frame
	
	print("✅ Pause menu added to tree")
	
	# Check if the script is attached and working
	if pause_menu.has_method("_on_resume_button_pressed"):
		print("✅ Pause menu script has _on_resume_button_pressed method")
	else:
		print("❌ Pause menu script missing _on_resume_button_pressed method!")
	
	# Find the Resume button
	var resume_button = pause_menu.get_node_or_null("MenuPanel/VBoxContainer/ResumeButton")
	
	if resume_button:
		print("✅ Resume button found: ", resume_button.name)
		print("   Button text: ", resume_button.text)
		print("   Button disabled: ", resume_button.disabled)
		print("   Button visible: ", resume_button.visible)
		print("   Button modulate: ", resume_button.modulate)
		print("   Button mouse_filter: ", resume_button.mouse_filter)
		print("   Button size: ", resume_button.size)
		print("   Button global_position: ", resume_button.global_position)
		
		# Check if button is receiving input at all
		print("\n🔍 Connecting to button's internal signals for debugging...")
		
		# Connect to gui_input to see if ANY input reaches the button
		if not resume_button.is_connected("gui_input", _on_button_gui_input):
			resume_button.gui_input.connect(_on_button_gui_input)
			print("✅ Connected to button gui_input signal")
		
		# Check signal connections
		var connections = resume_button.get_signal_connection_list("pressed")
		print("🔍 Button 'pressed' signal connections: ", connections.size())
		for connection in connections:
			print("   -> ", connection.target.name, ".", connection.method)
		
		# Test direct method call
		print("\n🔄 Testing direct method call on pause menu...")
		if pause_menu.has_method("_on_resume_button_pressed"):
			pause_menu._on_resume_button_pressed()
			print("✅ Direct method call completed")
		
		# Test signal emit
		print("\n🔄 Testing signal emit...")
		resume_button.pressed.emit()
		print("✅ Signal emit completed")
		
		# Test simulate press using _pressed method
		print("\n🔄 Testing button _pressed method...")
		if resume_button.has_method("_pressed"):
			resume_button._pressed()
			print("✅ Button _pressed method called")
		
		await process_frame
		
	else:
		print("❌ Resume button not found!")
	
	print("\n=== PAUSE MENU SCRIPT LOADING TEST COMPLETE ===")
	quit()

func _on_button_gui_input(event: InputEvent):
	print("🎯 BUTTON GUI INPUT DETECTED: ", event.get_class())
	if event is InputEventMouseButton:
		print("   Mouse button: ", event.button_index, " pressed: ", event.pressed)
