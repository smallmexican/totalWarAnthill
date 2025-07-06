# ==============================================================================
# COMPREHENSIVE UI AND INPUT TEST
# ==============================================================================
# Purpose: Test both UI centering and keyboard input functionality
# ==============================================================================

extends SceneTree

func _init():
	print("🎯 COMPREHENSIVE UI AND INPUT TEST")
	print("==================================")
	
	# Load strategic map scene
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
	
	# Add to scene tree so it can receive input
	root.add_child(strategic_map)
	current_scene = strategic_map
	
	print("✅ Strategic Map loaded as current scene")
	
	# Test UI structure
	test_ui_structure(strategic_map)
	
	# Test for input blocking elements
	test_input_blocking(strategic_map)
	
	print("\n🎯 SUMMARY:")
	print("- Species stats bar should be centered at top")
	print("- All UI elements should have proper mouse filters")
	print("- Input should reach the Strategic Map")
	print("- Debug label should update when keys are pressed")
	
	print("\n🧪 MANUAL TEST:")
	print("1. Load the game and go to Strategic Map")
	print("2. Look for debug label at top-left")
	print("3. Press any key - debug label should update")
	print("4. Check species stats bar is centered")
	print("5. Try ESC, C, P keys")
	
	# Don't quit automatically - let user test manually
	print("\n⏳ Test environment ready. Run the game to test manually.")
	quit()

func test_ui_structure(strategic_map: Node):
	print("\n📋 UI Structure Test:")
	
	# Check UILayer
	var ui_layer = strategic_map.get_node_or_null("UILayer")
	if ui_layer:
		print("✅ UILayer found: ", ui_layer.get_class())
		
		# Check SpeciesStatsBar
		var stats_bar = ui_layer.get_node_or_null("SpeciesStatsBar")
		if stats_bar:
			print("✅ SpeciesStatsBar found in UILayer")
			print("   Anchors: left=", stats_bar.anchor_left, " right=", stats_bar.anchor_right)
			print("   Offset bottom: ", stats_bar.offset_bottom)
			
			# Check CenterContainer
			var center_container = stats_bar.get_node_or_null("CenterContainer")
			if center_container:
				print("✅ CenterContainer found - stats bar should be centered")
			else:
				print("❌ CenterContainer missing - stats bar won't be centered")
		else:
			print("❌ SpeciesStatsBar not found in UILayer")
		
		# Check ColonyButton
		var colony_button = ui_layer.get_node_or_null("ColonyButton")
		if colony_button:
			print("✅ ColonyButton found in UILayer")
			print("   Position: ", colony_button.position)
			print("   Z-Index: ", colony_button.z_index)
		else:
			print("❌ ColonyButton not found in UILayer")
	else:
		print("❌ UILayer not found")
	
	# Check debug label
	var debug_label = strategic_map.get_node_or_null("InputDebugLabel")
	if debug_label:
		print("✅ InputDebugLabel found")
	else:
		print("❌ InputDebugLabel not found")

func test_input_blocking(strategic_map: Node):
	print("\n🚫 Input Blocking Test:")
	
	var ui_layer = strategic_map.get_node_or_null("UILayer")
	if ui_layer:
		var stats_bar = ui_layer.get_node_or_null("SpeciesStatsBar")
		if stats_bar:
			var blocking_elements = []
			check_for_blocking_elements(stats_bar, "SpeciesStatsBar", blocking_elements)
			
			if blocking_elements.size() == 0:
				print("✅ NO INPUT BLOCKING ELEMENTS found in SpeciesStatsBar")
			else:
				print("⚠️ Found ", blocking_elements.size(), " potentially blocking elements:")
				for element in blocking_elements:
					print("   - ", element)

func check_for_blocking_elements(node: Node, path: String, blocking_elements: Array):
	if node is Control:
		if node.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			blocking_elements.append(path + " (filter: " + str(node.mouse_filter) + ")")
	
	for child in node.get_children():
		check_for_blocking_elements(child, path + "/" + child.name, blocking_elements)
