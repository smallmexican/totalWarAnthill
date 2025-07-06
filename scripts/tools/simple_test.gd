# ==============================================================================
# SIMPLE TEST - Quick validation without dependencies
# ==============================================================================

extends Node

func _ready():
	print("🧪 SIMPLE TEST START")
	
	# Test SpeciesDataSimple creation
	var species = SpeciesDataSimple.new()
	species.species_name = "Test"
	species.attack_modifier = 1.5
	print("✅ SpeciesDataSimple works")
	
	# Test resource loading
	var resource_path = "res://data/species/fire_ant_simple.tres"
	var loaded_resource = load(resource_path)
	if loaded_resource:
		print("✅ Resource loading works: ", loaded_resource.species_name)
	else:
		print("❌ Resource loading failed")
	
	print("🧪 SIMPLE TEST END")
	get_tree().quit()
