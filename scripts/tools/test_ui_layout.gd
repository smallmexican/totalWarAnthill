# Test script to verify UI layout and mouse input
@tool
extends EditorScript

func _run():
	print("🧪 Testing UI Layout and Mouse Input...")
	
	# Test 1: Load Strategic Map scene
	print("\n1️⃣ Testing Strategic Map scene loading...")
	var strategic_map_scene = preload("res://scenes/game/StrategicMap.tscn")
	var strategic_map = strategic_map_scene.instantiate()
	
	if not strategic_map:
		print("❌ Failed to load strategic map")
		return
	
	print("✅ Strategic map loaded")
	
	# Test 2: Check species stats bar
	print("\n2️⃣ Testing species stats bar...")
	var species_bar = strategic_map.get_node_or_null("SpeciesStatsBar")
	if species_bar:
		print("✅ Species stats bar found")
		print("   Position: " + str(species_bar.position))
		print("   Size: " + str(species_bar.size))
		print("   Z-Index: " + str(species_bar.z_index))
		print("   Mouse Filter: " + str(species_bar.mouse_filter))
	else:
		print("❌ Species stats bar not found")
	
	# Test 3: Check colony button
	print("\n3️⃣ Testing colony button...")
	var colony_button = strategic_map.get_node_or_null("ColonyButton")
	if colony_button:
		print("✅ Colony button found")
		print("   Position: " + str(colony_button.position))
		print("   Size: " + str(colony_button.size))
		print("   Z-Index: " + str(colony_button.z_index))
		print("   Text: " + colony_button.text)
	else:
		print("❌ Colony button not found")
	
	# Test 4: Check Z-index ordering
	print("\n4️⃣ Testing Z-index ordering...")
	if species_bar and colony_button:
		if colony_button.z_index > species_bar.z_index:
			print("✅ Colony button Z-index (" + str(colony_button.z_index) + ") > Species bar Z-index (" + str(species_bar.z_index) + ")")
		else:
			print("❌ Z-index issue: Colony button (" + str(colony_button.z_index) + ") <= Species bar (" + str(species_bar.z_index) + ")")
	
	# Test 5: Check species stats bar UI structure
	print("\n5️⃣ Testing species stats bar UI structure...")
	if species_bar:
		var background = species_bar.get_node_or_null("Background")
		var hbox = species_bar.get_node_or_null("HBoxContainer")
		
		if background:
			print("✅ Background found - Mouse Filter: " + str(background.mouse_filter))
		else:
			print("❌ Background not found")
		
		if hbox:
			print("✅ HBoxContainer found")
		else:
			print("❌ HBoxContainer not found")
	
	# Cleanup
	strategic_map.queue_free()
	
	print("\n🎉 UI Layout test completed!")
	print("\n📋 Expected layout:")
	print("   - Species stats bar at top of screen (anchored, mouse_filter = PASS)")
	print("   - Colony button at bottom center (z_index = 20)")
	print("   - Colony button should be clickable")
	print("   - Species bar should not block input to other elements")
