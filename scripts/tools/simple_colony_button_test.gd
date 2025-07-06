# ==============================================================================
# SIMPLE COLONY BUTTON TEST
# ==============================================================================
# Purpose: Simple test to verify colony button setup in Strategic Map
# ==============================================================================

extends SceneTree

func _init():
	print("🧪 =========================")
	print("🧪 SIMPLE COLONY BUTTON TEST")
	print("🧪 =========================")
	
	# Load strategic map scene
	var strategic_map_scene = load("res://scenes/game/StrategicMap.tscn")
	if not strategic_map_scene:
		print("❌ Failed to load StrategicMap.tscn")
		quit()
		return
	
	var strategic_map = strategic_map_scene.instantiate()
	if not strategic_map:
		print("❌ Failed to instantiate strategic map")
		quit()
		return
	
	print("✅ Strategic map loaded")
	
	# Check UILayer exists
	var ui_layer = strategic_map.get_node_or_null("UILayer")
	if ui_layer:
		print("✅ UILayer found: ", ui_layer.get_class())
	else:
		print("❌ UILayer not found!")
		strategic_map.queue_free()
		quit()
		return
	
	# Check colony button exists
	var colony_button = strategic_map.get_node_or_null("UILayer/ColonyButton")
	if colony_button:
		print("✅ Colony button found")
		print("   Type: ", colony_button.get_class())
		print("   Position: ", colony_button.position)
		print("   Size: ", colony_button.size)
		print("   Z-Index: ", colony_button.z_index)
		print("   Mouse Filter: ", colony_button.mouse_filter)
		print("   Text: ", colony_button.text)
	else:
		print("❌ Colony button not found at UILayer/ColonyButton!")
		# List UILayer children
		print("UILayer children:")
		for child in ui_layer.get_children():
			print("   - ", child.name, " (", child.get_class(), ")")
	
	# Check species stats bar
	var stats_bar = strategic_map.get_node_or_null("UILayer/SpeciesStatsBar")
	if stats_bar:
		print("✅ Species stats bar found")
		print("   Type: ", stats_bar.get_class())
		print("   Mouse Filter: ", stats_bar.mouse_filter)
	else:
		print("❌ Species stats bar not found!")
	
	print("🧪 Test completed!")
	
	strategic_map.queue_free()
	quit()
