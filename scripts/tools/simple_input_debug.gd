# ==============================================================================
# SIMPLE INPUT DEBUG TEST
# ==============================================================================
# Purpose: Minimal test to check if ANY input reaches Strategic Map
# ==============================================================================

extends SceneTree

func _init():
	print("🔍 SIMPLE INPUT DEBUG TEST")
	print("============================")
	
	# Load the scene and add it to the tree
	var strategic_map_scene = load("res://scenes/game/StrategicMap.tscn")
	var strategic_map = strategic_map_scene.instantiate()
	
	# Add to scene tree so it can receive input
	root.add_child(strategic_map)
	current_scene = strategic_map
	
	print("✅ Strategic Map added as current scene")
	print("✅ Press any key to test input...")
	
	# Wait a moment for initialization
	await get_process_frame()
	await get_process_frame()
	
	print("🔍 Ready for input testing!")

func _input(event):
	if event is InputEventKey and event.pressed:
		print("🎯 GLOBAL INPUT DETECTED: ", OS.get_keycode_string(event.keycode))
		if event.keycode == KEY_Q:
			print("Q pressed - quitting test")
			quit()
