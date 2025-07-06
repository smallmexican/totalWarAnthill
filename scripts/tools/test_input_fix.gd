# ==============================================================================
# INPUT TEST SCRIPT
# ==============================================================================
# Purpose: Test that keyboard input (ESC, C, P) works on Strategic Map
# This script will verify that the species stats bar is not blocking input
# ==============================================================================

extends SceneTree

func _init():
	print("⌨️ ===========================")
	print("⌨️ INPUT TEST VERIFICATION")
	print("⌨️ ===========================")
	
	print("\n🔧 CHECKING INPUT BLOCKING ISSUES...")
	
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
	
	print("✅ Strategic Map loaded successfully")
	
	# Check UILayer
	var ui_layer = strategic_map.get_node_or_null("UILayer")
	if ui_layer:
		print("✅ UILayer found: ", ui_layer.get_class())
		
		# Check all UI elements in the layer
		print("\n📋 UI Layer Contents:")
		for child in ui_layer.get_children():
			print("   - ", child.name, " (", child.get_class(), ")")
			if child is Control:
				print("     Mouse Filter: ", child.mouse_filter, " (0=STOP, 1=PASS, 2=IGNORE)")
				print("     Process Mode: ", child.process_mode)
				
		# Check SpeciesStatsBar specifically
		var stats_bar = ui_layer.get_node_or_null("SpeciesStatsBar")
		if stats_bar:
			print("\n🧬 SpeciesStatsBar Analysis:")
			print("   Mouse Filter: ", stats_bar.mouse_filter, " (should be 2=IGNORE)")
			print("   Process Mode: ", stats_bar.process_mode)
			print("   Visible: ", stats_bar.visible)
			
			# Check child elements
			print("   Child Elements:")
			check_children_recursively(stats_bar, "     ")
			
		# Check ColonyButton
		var colony_button = ui_layer.get_node_or_null("ColonyButton")
		if colony_button:
			print("\n🏠 Colony Button Analysis:")
			print("   Mouse Filter: ", colony_button.mouse_filter, " (should be 0=STOP)")
			print("   Process Mode: ", colony_button.process_mode)
			print("   Visible: ", colony_button.visible)
			print("   Disabled: ", colony_button.disabled)
	else:
		print("❌ UILayer not found!")
	
	# Check if Strategic Map has _input method
	print("\n⌨️ Input Method Check:")
	if strategic_map.has_method("_input"):
		print("✅ Strategic Map has _input method")
	else:
		print("❌ Strategic Map missing _input method!")
	
	strategic_map.queue_free()
	
	print("\n🎯 SUMMARY:")
	print("- SpeciesStatsBar should have mouse_filter = 2 (IGNORE)")
	print("- All SpeciesStatsBar children should have mouse_filter = 2 (IGNORE)")
	print("- ColonyButton should have mouse_filter = 0 (STOP)")
	print("- Strategic Map should have _input method to handle ESC, C, P keys")
	
	print("\n🧪 WHAT TO TEST:")
	print("1. Load Strategic Map in game")
	print("2. Try pressing ESC - should show game menu")
	print("3. Try pressing C - should enter colony view")
	print("4. Try pressing P - should show pause menu")
	print("5. Try clicking colony button - should enter colony view")
	
	quit()

func check_children_recursively(node: Node, indent: String):
	for child in node.get_children():
		print(indent, "- ", child.name, " (", child.get_class(), ")")
		if child is Control:
			print(indent, "  Mouse Filter: ", child.mouse_filter)
		if child.get_child_count() > 0:
			check_children_recursively(child, indent + "  ")
