# ==============================================================================
# RESUME BUTTON TEST - Isolated test for pause menu functionality
# ==============================================================================

extends Control

var pause_menu_scene
var main_scene_manager

func _ready():
	print("🔍 RESUME BUTTON TEST STARTING...")
	
	# Setup a simple background
	var bg = ColorRect.new()
	bg.color = Color.DARK_GRAY
	bg.size = get_viewport().size
	add_child(bg)
	
	# Create a label
	var label = Label.new()
	label.text = "Resume Button Test\nPress SPACE to load pause menu"
	label.position = Vector2(50, 50)
	label.add_theme_font_size_override("font_size", 24)
	add_child(label)
	
	# Load the pause menu scene
	pause_menu_scene = load("res://scenes/ui/PauseMenu.tscn")
	if not pause_menu_scene:
		print("❌ Failed to load PauseMenu.tscn")
		return
	
	print("✅ PauseMenu.tscn loaded successfully")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			show_test_pause_menu()
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()

func show_test_pause_menu():
	print("🔍 Creating pause menu instance...")
	
	# Clear any existing pause menu
	var existing = get_node_or_null("PauseMenu")
	if existing:
		existing.queue_free()
	
	# Create pause menu instance
	var pause_menu = pause_menu_scene.instantiate()
	pause_menu.name = "PauseMenu"
	
	# Set previous scene (simulating normal behavior)
	if pause_menu.has_method("set_previous_scene"):
		pause_menu.set_previous_scene("res://scenes/game/StrategicMap.tscn")
	
	# Add to scene
	add_child(pause_menu)
	
	# Debug the pause menu structure
	debug_pause_menu_structure(pause_menu)
	
	print("✅ Pause menu created and added to scene")

func debug_pause_menu_structure(menu_node: Node):
	print("🔍 Debugging pause menu structure:")
	print("   Menu node: ", menu_node.name, " (", menu_node.get_class(), ")")
	print("   Visible: ", menu_node.visible if menu_node.has_method("set_visible") else "N/A")
	print("   Mouse filter: ", menu_node.mouse_filter if menu_node.has_method("set_mouse_filter") else "N/A")
	
	# Find resume button
	var resume_button = find_resume_button(menu_node)
	if resume_button:
		print("   ✅ Resume button found: ", resume_button.name)
		print("      Text: ", resume_button.text if resume_button.has_method("set_text") else "N/A")
		print("      Disabled: ", resume_button.disabled if resume_button.has_method("set_disabled") else "N/A")
		print("      Position: ", resume_button.position if resume_button.has_method("set_position") else "N/A")
		print("      Size: ", resume_button.size if resume_button.has_method("set_size") else "N/A")
		
		# Check signal connections
		if resume_button.has_signal("pressed"):
			var connections = resume_button.get_signal_connection_list("pressed")
			print("      Signal connections: ", connections.size())
			for connection in connections:
				print("         -> ", connection.callable.get_object().name, ".", connection.callable.get_method())
		
		# Test clicking the button manually
		print("🔍 Testing manual button press...")
		if resume_button.has_method("emit_signal"):
			resume_button.pressed.emit()
			print("      Button press signal emitted")
	else:
		print("   ❌ Resume button not found")
		debug_all_children(menu_node, 0)

func find_resume_button(node: Node) -> Button:
	if node is Button and ("resume" in node.name.to_lower() or "resume" in node.text.to_lower()):
		return node
	
	for child in node.get_children():
		var result = find_resume_button(child)
		if result:
			return result
	
	return null

func debug_all_children(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	print(indent, "- ", node.name, " (", node.get_class(), ")")
	
	if node is Button:
		print(indent, "  Button text: ", node.text)
	
	for child in node.get_children():
		debug_all_children(child, depth + 1)
