# ==============================================================================
# PAUSE MENU DEBUG TEST - Test button interaction directly
# ==============================================================================

extends Control

func _ready():
	print("🔍 PAUSE MENU DEBUG TEST")
	
	# Load the actual pause menu scene
	test_pause_menu_loading()

func test_pause_menu_loading():
	print("Loading PauseMenu.tscn...")
	
	var pause_menu_scene = load("res://scenes/ui/PauseMenu.tscn")
	if not pause_menu_scene:
		print("❌ Failed to load PauseMenu.tscn")
		return
	
	print("✅ PauseMenu.tscn loaded successfully")
	
	# Instantiate the pause menu
	var pause_menu = pause_menu_scene.instantiate()
	add_child(pause_menu)
	
	print("✅ PauseMenu instantiated and added to scene")
	
	# Debug the menu structure
	debug_menu_structure(pause_menu)
	
	# Try to find and test the resume button directly
	test_resume_button(pause_menu)

func debug_menu_structure(node: Node, depth: int = 0):
	var indent = "  ".repeat(depth)
	print(indent, "- ", node.name, " (", node.get_class(), ")")
	
	if node is Control:
		print(indent, "  Visible: ", node.visible)
		print(indent, "  Mouse Filter: ", node.mouse_filter)
		if node.has_method("get_global_rect"):
			print(indent, "  Global Rect: ", node.get_global_rect())
	
	if node is Button:
		print(indent, "  [BUTTON] Text: '", node.text, "'")
		print(indent, "  [BUTTON] Disabled: ", node.disabled)
		print(indent, "  [BUTTON] Flat: ", node.flat if node.has_method("set_flat") else "N/A")
		
		# Check signal connections
		if node.has_signal("pressed"):
			var connections = node.get_signal_connection_list("pressed")
			print(indent, "  [BUTTON] Signal connections: ", connections.size())
			for connection in connections:
				print(indent, "    -> ", connection.callable.get_object().name, ".", connection.callable.get_method())
	
	# Recurse through children
	for child in node.get_children():
		debug_menu_structure(child, depth + 1)

func test_resume_button(pause_menu: Node):
	print("\n🔍 TESTING RESUME BUTTON...")
	
	# Find the resume button
	var resume_button = find_button_by_text(pause_menu, "Resume")
	if not resume_button:
		resume_button = find_node_by_name(pause_menu, "ResumeButton")
	
	if resume_button:
		print("✅ Resume button found: ", resume_button.name)
		print("   Text: '", resume_button.text, "'")
		print("   Disabled: ", resume_button.disabled)
		print("   Visible: ", resume_button.visible)
		print("   Global Position: ", resume_button.global_position)
		print("   Size: ", resume_button.size)
		print("   Mouse Filter: ", resume_button.mouse_filter)
		
		# Test manual button press
		print("\n🔧 TESTING MANUAL BUTTON PRESS...")
		if resume_button.has_signal("pressed"):
			print("   Emitting pressed signal manually...")
			resume_button.pressed.emit()
			print("   Signal emitted")
		
		# Test button click simulation
		print("\n🔧 TESTING BUTTON CLICK SIMULATION...")
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = true
		event.position = resume_button.global_position + resume_button.size / 2
		
		print("   Simulating click at: ", event.position)
		resume_button._gui_input(event)
		
		# Release
		event.pressed = false
		resume_button._gui_input(event)
		
	else:
		print("❌ Resume button not found!")
		print("Available buttons:")
		find_all_buttons(pause_menu)

func find_button_by_text(node: Node, text: String) -> Button:
	if node is Button and text.to_lower() in node.text.to_lower():
		return node
	
	for child in node.get_children():
		var result = find_button_by_text(child, text)
		if result:
			return result
	
	return null

func find_node_by_name(node: Node, name: String) -> Node:
	if name.to_lower() in node.name.to_lower():
		return node
	
	for child in node.get_children():
		var result = find_node_by_name(child, name)
		if result:
			return result
	
	return null

func find_all_buttons(node: Node, depth: int = 0):
	var indent = "  ".repeat(depth)
	
	if node is Button:
		print(indent, "BUTTON: ", node.name, " - '", node.text, "'")
	
	for child in node.get_children():
		find_all_buttons(child, depth + 1)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
