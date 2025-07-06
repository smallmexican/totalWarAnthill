# ==============================================================================
# PAUSE MENU BUTTON TEST - Verify Resume button functionality
# ==============================================================================

extends Control

var resume_button: Button

func _ready():
	print("🔍 PAUSE MENU BUTTON TEST")
	
	# Create a simple pause menu for testing
	var panel = Panel.new()
	panel.size = Vector2(400, 300)
	panel.position = Vector2(400, 200)
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(50, 50)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "TEST PAUSE MENU"
	vbox.add_child(title)
	
	resume_button = Button.new()
	resume_button.text = "▶️ Resume Game"
	resume_button.custom_minimum_size = Vector2(200, 50)
	vbox.add_child(resume_button)
	
	# Connect the button signal
	resume_button.pressed.connect(_on_resume_pressed)
	
	print("✅ Test pause menu created with Resume button")
	print("   Button enabled: ", resume_button.disabled)
	print("   Button visible: ", resume_button.visible)
	print("   Button mouse_filter: ", resume_button.mouse_filter)
	print("   Button size: ", resume_button.size)
	print("   Signal connected: ", resume_button.pressed.is_connected(_on_resume_pressed))

func _on_resume_pressed():
	print("🎯 RESUME BUTTON CLICKED! - Test successful")
	print("   Time: ", Time.get_unix_time_from_system())
	get_tree().quit()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		print("🔍 Mouse clicked at: ", event.position)
		print("   Button global position: ", resume_button.global_position)
		print("   Button global rect: ", resume_button.get_global_rect())
		var button_rect = resume_button.get_global_rect()
		if button_rect.has_point(event.position):
			print("   ✅ Click is within button bounds")
		else:
			print("   ❌ Click is outside button bounds")
