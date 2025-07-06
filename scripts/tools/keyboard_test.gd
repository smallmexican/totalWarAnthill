# ==============================================================================
# KEYBOARD INPUT TEST
# ==============================================================================
# Purpose: Test if keyboard input works on Strategic Map
# ==============================================================================

extends Node

func _ready():
	print("🎯 KEYBOARD INPUT TEST READY")
	print("Press ESC, C, or P to test...")
	print("Press Q to quit this test")

func _input(event):
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		print("🔍 Key detected: ", key_name, " (code: ", event.keycode, ")")
		
		match event.keycode:
			KEY_ESCAPE:
				print("✅ ESC key working!")
			KEY_C:
				print("✅ C key working!")
			KEY_P:
				print("✅ P key working!")
			KEY_Q:
				print("Quitting test...")
				get_tree().quit()
