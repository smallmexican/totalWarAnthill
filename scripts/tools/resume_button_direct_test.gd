# ==============================================================================
# RESUME BUTTON DIRECT TEST - Find and test resume button functionality
# ==============================================================================

extends Control

var main_scene_manager

func _ready():
	print("🔍 RESUME BUTTON DIRECT TEST")
	
	# Setup background
	var bg = ColorRect.new()
	bg.color = Color.DARK_BLUE
	bg.size = get_viewport().size
	add_child(bg)
	
	var label = Label.new()
	label.text = "Resume Button Test\nPress SPACE to test pause menu\nPress ESC to quit"
	label.position = Vector2(50, 50)
	add_child(label)
	
	# Get main scene manager reference
	main_scene_manager = get_tree().root.get_node_or_null("Main")
	if main_scene_manager:
		print("✅ Main scene manager found")
	else:
		print("❌ Main scene manager not found")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			test_pause_menu()
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()

func test_pause_menu():
	print("\n🔧 TESTING PAUSE MENU...")
	
	# Load pause menu scene
	var pause_menu_scene = load("res://scenes/ui/PauseMenu.tscn")
	if not pause_menu_scene:
		print("❌ Failed to load PauseMenu.tscn")
		return
	
	# Clear any existing pause menu
	for child in get_children():
		if child.name.begins_with("PauseMenu"):
			child.queue_free()
	
	# Instantiate pause menu
	var pause_menu = pause_menu_scene.instantiate()
	pause_menu.name = "PauseMenuTest"
	add_child(pause_menu)
	
	print("✅ Pause menu instantiated")
	
	# Set up the pause menu properly
	if pause_menu.has_method("set_previous_scene"):
		pause_menu.set_previous_scene("res://scenes/game/StrategicMap.tscn")
	
	# Wait a frame for the menu to initialize
	await get_tree().process_frame
	
	# Debug the menu structure and find the resume button
	print("\n🔍 MENU STRUCTURE DEBUG:")
	debug_node_tree(pause_menu)
	
	# Find and test the resume button
	print("\n🔧 FINDING RESUME BUTTON...")
	var resume_button = find_resume_button(pause_menu)
	
	if resume_button:
		print("✅ Resume button found: ", resume_button.get_path())
		test_button_functionality(resume_button, pause_menu)
	else:
		print("❌ Resume button not found in pause menu!")
		print("Available buttons:")
		list_all_buttons(pause_menu)

func find_resume_button(node: Node) -> Button:
	# Try multiple strategies to find the resume button
	
	# Strategy 1: Look for button with "resume" in the name
	var button = find_node_recursive(node, func(n): return n is Button and "resume" in n.name.to_lower())
	if button:
		print("   Found by name: ", button.name)
		return button
	
	# Strategy 2: Look for button with "resume" in the text
	button = find_node_recursive(node, func(n): return n is Button and "resume" in n.text.to_lower())
	if button:
		print("   Found by text: ", button.text)
		return button
	
	# Strategy 3: Look for button with play symbol
	button = find_node_recursive(node, func(n): return n is Button and "▶" in n.text)
	if button:
		print("   Found by play symbol: ", button.text)
		return button
	
	return null

func find_node_recursive(node: Node, predicate: Callable) -> Node:
	if predicate.call(node):
		return node
	
	for child in node.get_children():
		var result = find_node_recursive(child, predicate)
		if result:
			return result
	
	return null

func test_button_functionality(button: Button, pause_menu: Node):
	print("\n🔧 TESTING BUTTON FUNCTIONALITY...")
	print("   Button name: ", button.name)
	print("   Button text: ", button.text)
	print("   Button disabled: ", button.disabled)
	print("   Button visible: ", button.visible)
	print("   Button mouse_filter: ", button.mouse_filter)
	print("   Button position: ", button.global_position)
	print("   Button size: ", button.size)
	
	# Check parent mouse filters
	print("\n🔍 CHECKING PARENT MOUSE FILTERS...")
	var current = button.get_parent()
	var depth = 0
	while current and depth < 10:
		if current is Control:
			print("   Parent ", depth, ": ", current.name, " - mouse_filter: ", current.mouse_filter)
			if current.mouse_filter == Control.MOUSE_FILTER_IGNORE:
				print("   ⚠️ FOUND IGNORE FILTER - This could block button clicks!")
		current = current.get_parent()
		depth += 1
	
	# Check signal connections
	print("\n🔍 CHECKING SIGNAL CONNECTIONS...")
	if button.has_signal("pressed"):
		var connections = button.get_signal_connection_list("pressed")
		print("   Signal 'pressed' connections: ", connections.size())
		for connection in connections:
			print("      -> ", connection.callable.get_object().name, ".", connection.callable.get_method())
			
			# Test the connection by calling it manually
			print("   🧪 Testing signal connection manually...")
			connection.callable.call()
	else:
		print("   ❌ Button has no 'pressed' signal")
	
	# Test manual button activation
	print("\n🧪 TESTING MANUAL BUTTON ACTIVATION...")
	button.grab_focus()
	button.pressed.emit()
	print("   Manual pressed signal emitted")

func debug_node_tree(node: Node, depth: int = 0):
	var indent = "  ".repeat(depth)
	var info = indent + "- " + node.name + " (" + node.get_class() + ")"
	
	if node is Control:
		info += " visible:" + str(node.visible) + " mouse_filter:" + str(node.mouse_filter)
	
	if node is Button:
		info += " TEXT:'" + node.text + "'"
	
	print(info)
	
	if depth < 5:  # Limit depth to avoid spam
		for child in node.get_children():
			debug_node_tree(child, depth + 1)

func list_all_buttons(node: Node, depth: int = 0):
	var indent = "  ".repeat(depth)
	
	if node is Button:
		print(indent, "BUTTON: ", node.name, " - '", node.text, "' (disabled:", node.disabled, ")")
	
	for child in node.get_children():
		list_all_buttons(child, depth + 1)
