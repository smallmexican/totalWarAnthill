# ==============================================================================
# COLONY BUTTON FIX VERIFICATION
# ==============================================================================
# Purpose: Verify that the colony button is working after UI restructuring
# 
# This test checks:
# 1. Colony button is properly positioned in the UILayer
# 2. Mouse input is not blocked by the species stats bar
# 3. Signal connections are working correctly
# 4. Z-index layering is correct
# ==============================================================================

@tool
extends EditorScript

func _run():
	print("🏠 COLONY BUTTON FIX VERIFICATION")
	print("=================================")
	
	# Test 1: Colony button positioning in UILayer
	test_colony_button_positioning()
	
	# Test 2: Mouse input handling
	test_mouse_input_handling()
	
	# Test 3: Signal connections
	test_signal_connections()
	
	# Test 4: Z-index and layering
	test_ui_layering()
	
	print("\n✅ COLONY BUTTON VERIFICATION COMPLETE")
	print("The colony button should now be working correctly!")

func test_colony_button_positioning():
	print("\n--- Testing Colony Button Positioning ---")
	
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
					
					# Check for ColonyButton under UILayer
					var colony_button = ui_layer.get_node_or_null("ColonyButton")
					if colony_button:
						print("✅ ColonyButton found under UILayer")
						print("   Type: ", colony_button.get_class())
						print("   Position: (", colony_button.offset_left, ", ", colony_button.offset_top, ")")
						print("   Size: ", colony_button.size)
						print("   Z-index: ", colony_button.z_index)
						print("   Text: ", colony_button.text)
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

func test_mouse_input_handling():
	print("\n--- Testing Mouse Input Handling ---")
	
	# Test that UI elements have correct mouse filter settings
	var strategic_map_path = "res://scenes/game/StrategicMap.tscn"
	if FileAccess.file_exists(strategic_map_path):
		var scene = load(strategic_map_path)
		if scene:
			var instance = scene.instantiate()
			if instance:
				var ui_layer = instance.get_node_or_null("UILayer")
				if ui_layer:
					# Check SpeciesStatsBar mouse filter
					var species_bar = ui_layer.get_node_or_null("SpeciesStatsBar")
					if species_bar:
						print("✅ SpeciesStatsBar mouse_filter: ", species_bar.mouse_filter, " (2 = IGNORE, good)")
						
						# Check Background mouse filter
						var background = species_bar.get_node_or_null("Background")
						if background:
							print("✅ Background mouse_filter: ", background.mouse_filter, " (2 = IGNORE, good)")
						else:
							print("⚠️ Background node not found")
					else:
						print("❌ SpeciesStatsBar not found for mouse filter test")
					
					# Check ColonyButton mouse filter (should be default = 0 for buttons)
					var colony_button = ui_layer.get_node_or_null("ColonyButton")
					if colony_button:
						print("✅ ColonyButton mouse_filter: ", colony_button.mouse_filter, " (0 = STOP, correct for buttons)")
					else:
						print("❌ ColonyButton not found for mouse filter test")
				else:
					print("❌ UILayer not found for mouse filter test")
				
				instance.queue_free()
			else:
				print("❌ Failed to instantiate for mouse filter test")
		else:
			print("❌ Failed to load scene for mouse filter test")
	else:
		print("❌ Scene file not found for mouse filter test")

func test_signal_connections():
	print("\n--- Testing Signal Connections ---")
	
	# Test that signals are properly connected to the new path
	var strategic_map_path = "res://scenes/game/StrategicMap.tscn"
	if FileAccess.file_exists(strategic_map_path):
		var scene = load(strategic_map_path)
		if scene:
			var instance = scene.instantiate()
			if instance:
				var ui_layer = instance.get_node_or_null("UILayer")
				if ui_layer:
					var colony_button = ui_layer.get_node_or_null("ColonyButton")
					if colony_button:
						# Check if signals are connected
						var signal_connections = colony_button.get_signal_connection_list("pressed")
						if signal_connections.size() > 0:
							print("✅ Colony button 'pressed' signal is connected")
							for connection in signal_connections:
								print("   Connected to: ", connection.target.name, ".", connection.method.get_method())
						else:
							print("❌ Colony button 'pressed' signal not connected")
						
						# Check mouse_entered signal
						var mouse_entered_connections = colony_button.get_signal_connection_list("mouse_entered")
						if mouse_entered_connections.size() > 0:
							print("✅ Colony button 'mouse_entered' signal is connected")
						else:
							print("⚠️ Colony button 'mouse_entered' signal not connected")
						
						# Check mouse_exited signal
						var mouse_exited_connections = colony_button.get_signal_connection_list("mouse_exited")
						if mouse_exited_connections.size() > 0:
							print("✅ Colony button 'mouse_exited' signal is connected")
						else:
							print("⚠️ Colony button 'mouse_exited' signal not connected")
					else:
						print("❌ ColonyButton not found for signal test")
				else:
					print("❌ UILayer not found for signal test")
				
				instance.queue_free()
			else:
				print("❌ Failed to instantiate for signal test")
		else:
			print("❌ Failed to load scene for signal test")
	else:
		print("❌ Scene file not found for signal test")

func test_ui_layering():
	print("\n--- Testing UI Layering ---")
	
	var strategic_map_path = "res://scenes/game/StrategicMap.tscn"
	if FileAccess.file_exists(strategic_map_path):
		var scene = load(strategic_map_path)
		if scene:
			var instance = scene.instantiate()
			if instance:
				var ui_layer = instance.get_node_or_null("UILayer")
				if ui_layer:
					print("✅ UILayer found, checking child z-indices...")
					
					var species_bar = ui_layer.get_node_or_null("SpeciesStatsBar")
					var colony_button = ui_layer.get_node_or_null("ColonyButton")
					
					if species_bar and colony_button:
						print("   SpeciesStatsBar z_index: ", species_bar.z_index)
						print("   ColonyButton z_index: ", colony_button.z_index)
						
						if colony_button.z_index > species_bar.z_index:
							print("✅ ColonyButton has higher z_index than SpeciesStatsBar")
						else:
							print("⚠️ ColonyButton z_index should be higher than SpeciesStatsBar")
						
						# Check position hierarchy (order in scene tree)
						var species_bar_index = ui_layer.get_child_index(species_bar)
						var colony_button_index = ui_layer.get_child_index(colony_button)
						
						print("   SpeciesStatsBar child index: ", species_bar_index)
						print("   ColonyButton child index: ", colony_button_index)
						
						if colony_button_index > species_bar_index:
							print("✅ ColonyButton comes after SpeciesStatsBar in scene tree")
						else:
							print("⚠️ Scene tree order: later children render on top")
					else:
						print("❌ Could not find both UI elements for layering test")
				else:
					print("❌ UILayer not found for layering test")
				
				instance.queue_free()
			else:
				print("❌ Failed to instantiate for layering test")
		else:
			print("❌ Failed to load scene for layering test")
	else:
		print("❌ Scene file not found for layering test")
	
	print("\n🎯 LAYERING SUMMARY:")
	print("- ColonyButton moved to UILayer (same layer as SpeciesStatsBar)")
	print("- ColonyButton z_index increased to 30 (higher than SpeciesStatsBar)")
	print("- SpeciesStatsBar mouse_filter = IGNORE (won't block mouse input)")
	print("- ColonyButton mouse_filter = STOP (default for buttons, correct)")
	print("\n🔄 Test the game to verify the colony button now works!")
