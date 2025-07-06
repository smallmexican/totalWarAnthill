# ==============================================================================
# FINAL INPUT FIX VERIFICATION
# ==============================================================================
# Purpose: Final comprehensive test to verify input fix is complete
# ==============================================================================

extends SceneTree

func _init():
	print("🎯 ===================================")
	print("🎯 FINAL INPUT FIX VERIFICATION")
	print("🎯 ===================================")
	
	# Load Strategic Map scene
	var strategic_map_scene = load("res://scenes/game/StrategicMap.tscn")
	if not strategic_map_scene:
		print("❌ Could not load Strategic Map scene!")
		quit()
		return
	
	var strategic_map = strategic_map_scene.instantiate()
	if not strategic_map:
		print("❌ Could not instantiate Strategic Map!")
		quit()
		return
	
	print("✅ Strategic Map loaded for final test")
	
	# Get UILayer and check all elements
	var ui_layer = strategic_map.get_node_or_null("UILayer")
	if ui_layer:
		var stats_bar = ui_layer.get_node_or_null("SpeciesStatsBar")
		if stats_bar:
			print("\n🧬 FINAL SpeciesStatsBar Analysis:")
			var blocking_elements = []
			check_for_blocking_elements(stats_bar, "", blocking_elements)
			
			if blocking_elements.size() == 0:
				print("✅ NO BLOCKING ELEMENTS FOUND!")
				print("✅ All elements have mouse_filter = 2 (IGNORE)")
			else:
				print("❌ Found ", blocking_elements.size(), " elements that might block input:")
				for element in blocking_elements:
					print("   - ", element)
		
		var colony_button = ui_layer.get_node_or_null("ColonyButton")
		if colony_button:
			print("\n🏠 Colony Button Final Check:")
			print("   Mouse Filter: ", colony_button.mouse_filter, " (should be 0)")
			print("   Disabled: ", colony_button.disabled, " (should be false)")
			print("   Visible: ", colony_button.visible, " (should be true)")
			
			if colony_button.mouse_filter == 0 and not colony_button.disabled and colony_button.visible:
				print("✅ Colony button is properly configured for clicking")
			else:
				print("❌ Colony button has issues")
	
	strategic_map.queue_free()
	
	print("\n🎯 FINAL RESULT:")
	print("The species stats bar should now be completely transparent to input.")
	print("The colony button should be clickable.")
	print("Keyboard input (ESC, C, P) should work on the Strategic Map.")
	
	print("\n🧪 TEST IN GAME:")
	print("1. Start the game and go to Strategic Map")
	print("2. Press ESC - should show game menu")
	print("3. Press C - should enter colony view") 
	print("4. Press P - should show pause menu")
	print("5. Click colony button - should enter colony view")
	print("6. Species stats bar should be visible at top but not block input")
	
	quit()

func check_for_blocking_elements(node: Node, path: String, blocking_elements: Array):
	var current_path = path + node.name
	
	if node is Control:
		if node.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			blocking_elements.append(current_path + " (filter: " + str(node.mouse_filter) + ")")
	
	for child in node.get_children():
		check_for_blocking_elements(child, current_path + "/", blocking_elements)
