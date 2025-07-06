extends SceneTree

# Simple test to verify the pause menu can be loaded and Resume button works

func _init():
	print("=== SIMPLE PAUSE MENU TEST ===")
	
	# Load the pause menu scene
	var pause_menu_scene = preload("res://scenes/ui/PauseMenu.tscn")
	var pause_menu = pause_menu_scene.instantiate()
	
	print("✅ Pause menu loaded successfully")
	
	# Add to root to simulate being displayed
	root.add_child(pause_menu)
	
	# Wait a frame for ready to be called
	await process_frame
	
	print("✅ Pause menu added to tree and ready called")
	
	# Find the Resume button
	var resume_button = pause_menu.get_node_or_null("MenuPanel/VBoxContainer/ResumeButton")
	
	if resume_button:
		print("✅ Resume button found: ", resume_button.name)
		print("   Button text: ", resume_button.text)
		print("   Button disabled: ", resume_button.disabled)
		print("   Button visible: ", resume_button.visible)
		print("   Button mouse_filter: ", resume_button.mouse_filter)
		
		# Check signal connection
		if resume_button.is_connected("pressed", pause_menu._on_resume_button_pressed):
			print("✅ Resume button signal is connected")
		else:
			print("❌ Resume button signal is NOT connected")
		
		# Simulate button press
		print("🔄 Simulating Resume button press...")
		resume_button.emit_signal("pressed")
		print("✅ Resume button press simulated")
		
	else:
		print("❌ Resume button not found at expected path")
	
	# Check parent mouse filters
	print("\n🔍 Checking parent node mouse filters:")
	var background = pause_menu.get_node_or_null("Background")
	if background:
		print("   Background mouse_filter: ", background.mouse_filter)
	
	var menu_panel = pause_menu.get_node_or_null("MenuPanel")
	if menu_panel:
		print("   MenuPanel mouse_filter: ", menu_panel.mouse_filter)
	
	var vbox = pause_menu.get_node_or_null("MenuPanel/VBoxContainer")
	if vbox:
		print("   VBoxContainer mouse_filter: ", vbox.mouse_filter)
	
	print("\n=== PAUSE MENU TEST COMPLETE ===")
	quit()
