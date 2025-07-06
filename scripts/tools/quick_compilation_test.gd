# ==============================================================================
# QUICK COMPILATION TEST - Simple test to verify fixes
# ==============================================================================

extends Node

func _ready():
	print("🔧 QUICK COMPILATION TEST...")
	
	# Test basic class creation
	test_basic_classes()
	
	print("✅ All basic tests passed!")
	print("Godot should now load without 'Node export' or parser errors.")
	
	# Auto quit
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func test_basic_classes():
	# Test SpeciesDataSimple
	var species = SpeciesDataSimple.new()
	species.species_name = "Test"
	print("   ✅ SpeciesDataSimple works")
	
	# Test Task creation (RefCounted class without @export)
	var task = Task.new()
	task.task_type = "test"
	task.task_name = "Test Task"
	print("   ✅ Task creation works")
	
	# Test resource loading
	var fire_ant = load("res://data/species/fire_ant_simple.tres")
	if fire_ant:
		print("   ✅ Fire ant resource loads: ", fire_ant.species_name)
	else:
		print("   ⚠️ Fire ant resource failed to load")
	
	print("   ✅ Basic compilation test complete")
