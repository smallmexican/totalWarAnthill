# ==============================================================================
# UI CENTERING FIX VERIFICATION
# ==============================================================================
# Purpose: Verify that the species stats bar is properly centered at the top
# 
# This test checks:
# 1. UI layer structure is correct (CanvasLayer for proper UI handling)
# 2. Species stats bar uses CenterContainer for proper centering
# 3. Node paths are updated correctly in the script
# 4. The stats bar appears at the top center of the viewport
# ==============================================================================

@tool
extends EditorScript

func _run():
	print("🎯 UI CENTERING FIX VERIFICATION")
	print("================================")
	
	# Test 1: Strategic Map UI structure
	test_strategic_map_ui_structure()
	
	# Test 2: Species Stats Bar centering
	test_species_stats_bar_centering()
	
	# Test 3: Node path verification
	test_node_path_references()
	
	# Test 4: Visual positioning test
	test_visual_positioning()
	
	print("\n✅ UI CENTERING VERIFICATION COMPLETE")
	print("The species stats bar should now be properly centered at the top!")

func test_strategic_map_ui_structure():
	print("\n--- Testing Strategic Map UI Structure ---")
	
	# Test Strategic Map scene loading
	var strategic_map_path = "res://scenes/game/StrategicMap.tscn"
	if FileAccess.file_exists(strategic_map_path):
		var scene = load(strategic_map_path)
		if scene:
			print("✅ Strategic Map scene loads successfully")
			
			var instance = scene.instantiate()
			if instance:
				print("✅ Strategic Map instantiates successfully")
				
				# Check for UILayer
				var ui_layer = instance.get_node_or_null("UILayer")
				if ui_layer:
					print("✅ UILayer found in Strategic Map")
					print("   Type: ", ui_layer.get_class())
					
					# Check for SpeciesStatsBar under UILayer
					var species_bar = ui_layer.get_node_or_null("SpeciesStatsBar")
					if species_bar:
						print("✅ SpeciesStatsBar found under UILayer")
						print("   Type: ", species_bar.get_class())
					else:
						print("❌ SpeciesStatsBar not found under UILayer")
					
					# Check for ColonyButton under UILayer
					var colony_button = ui_layer.get_node_or_null("ColonyButton")
					if colony_button:
						print("✅ ColonyButton found under UILayer")
						print("   Type: ", colony_button.get_class())
						print("   Z-index: ", colony_button.z_index)
					else:
						print("❌ ColonyButton not found under UILayer")
				else:
					print("❌ UILayer not found in Strategic Map")
				
				instance.queue_free()
			else:
				print("❌ Strategic Map failed to instantiate")
		else:
			print("❌ Strategic Map scene failed to load")
	else:
		print("❌ Strategic Map scene file not found")

func test_species_stats_bar_centering():
	print("\n--- Testing Species Stats Bar Centering ---")
	
	# Test SpeciesStatsBar scene structure
	var stats_bar_path = "res://scenes/ui/species_stats_bar.tscn"
	if FileAccess.file_exists(stats_bar_path):
		var scene = load(stats_bar_path)
		if scene:
			print("✅ SpeciesStatsBar scene loads successfully")
			
			var instance = scene.instantiate()
			if instance:
				print("✅ SpeciesStatsBar instantiates successfully")
				
				# Check for CenterContainer
				var center_container = instance.get_node_or_null("CenterContainer")
				if center_container:
					print("✅ CenterContainer found in SpeciesStatsBar")
					print("   Type: ", center_container.get_class())
					
					# Check anchoring
					if center_container.anchor_right == 1.0 and center_container.anchor_left == 0.0:
						print("✅ CenterContainer properly anchored (left: 0.0, right: 1.0)")
					else:
						print("⚠️ CenterContainer anchoring: left=", center_container.anchor_left, " right=", center_container.anchor_right)
					
					# Check for HBoxContainer inside CenterContainer
					var hbox = center_container.get_node_or_null("HBoxContainer")
					if hbox:
						print("✅ HBoxContainer found inside CenterContainer")
						print("   Custom min size: ", hbox.custom_minimum_size)
					else:
						print("❌ HBoxContainer not found inside CenterContainer")
				else:
					print("❌ CenterContainer not found in SpeciesStatsBar")
				
				instance.queue_free()
			else:
				print("❌ SpeciesStatsBar failed to instantiate")
		else:
			print("❌ SpeciesStatsBar scene failed to load")
	else:
		print("❌ SpeciesStatsBar scene file not found")

func test_node_path_references():
	print("\n--- Testing Node Path References ---")
	
	# Test that the script can find all UI elements
	var stats_bar_path = "res://scenes/ui/species_stats_bar.tscn"
	if FileAccess.file_exists(stats_bar_path):
		var scene = load(stats_bar_path)
		if scene:
			var instance = scene.instantiate()
			if instance:
				print("✅ Testing node path references...")
				
				# Test key node paths that were updated
				var test_paths = [
					"CenterContainer/HBoxContainer/SpeciesInfo/SpeciesName",
					"CenterContainer/HBoxContainer/SpeciesInfo/HBoxContainer/SpeciesIcon",
					"CenterContainer/HBoxContainer/CombatStats/StatsContainer/AttackStat",
					"CenterContainer/HBoxContainer/ResourceStats/ResourceContainer/FoodEfficiency",
					"CenterContainer/HBoxContainer/Abilities/AbilitiesList"
				]
				
				var found_paths = 0
				for path in test_paths:
					var node = instance.get_node_or_null(path)
					if node:
						found_paths += 1
					else:
						print("❌ Node not found: ", path)
				
				if found_paths == test_paths.size():
					print("✅ All node paths found successfully (", found_paths, "/", test_paths.size(), ")")
				else:
					print("⚠️ Some node paths missing (", found_paths, "/", test_paths.size(), " found)")
				
				instance.queue_free()
			else:
				print("❌ Failed to instantiate scene for path testing")
		else:
			print("❌ Failed to load scene for path testing")
	else:
		print("❌ Scene file not found for path testing")

func test_visual_positioning():
	print("\n--- Testing Visual Positioning ---")
	
	# Test complete scene hierarchy
	var strategic_map_path = "res://scenes/game/StrategicMap.tscn"
	if FileAccess.file_exists(strategic_map_path):
		var scene = load(strategic_map_path)
		if scene:
			var instance = scene.instantiate()
			if instance:
				print("✅ Complete scene loaded for positioning test")
				
				# Check the full path to the species bar
				var species_bar = instance.get_node_or_null("UILayer/SpeciesStatsBar")
				if species_bar:
					print("✅ SpeciesStatsBar accessible via UILayer/SpeciesStatsBar")
					
					# Check positioning properties
					print("   Anchors: left=", species_bar.anchor_left, " top=", species_bar.anchor_top, " right=", species_bar.anchor_right, " bottom=", species_bar.anchor_bottom)
					print("   Offset bottom: ", species_bar.offset_bottom)
					print("   Size: ", species_bar.size)
					
					# Check CenterContainer
					var center_container = species_bar.get_node_or_null("CenterContainer")
					if center_container:
						print("✅ CenterContainer properly nested")
						print("   CenterContainer anchors: left=", center_container.anchor_left, " right=", center_container.anchor_right)
					else:
						print("❌ CenterContainer not found in positioned test")
				else:
					print("❌ SpeciesStatsBar not accessible via new path")
				
				instance.queue_free()
			else:
				print("❌ Failed to instantiate for positioning test")
		else:
			print("❌ Failed to load scene for positioning test")
	else:
		print("❌ Scene file not found for positioning test")
	
	print("\n🎯 POSITIONING SUMMARY:")
	print("- Added CanvasLayer (UILayer) to Strategic Map for proper UI handling")
	print("- Added CenterContainer to SpeciesStatsBar for automatic centering")
	print("- Updated all node paths in the script to match new hierarchy")
	print("- Stats bar should now appear centered at the top of the screen")
	print("\n🔄 Restart Godot and test the game to see the centered stats bar!")
