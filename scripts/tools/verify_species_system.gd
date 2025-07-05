# ==============================================================================
# SPECIES SYSTEM VERIFICATION - Final Test
# ==============================================================================
# Purpose: Quick verification that all fixes are working
# 
# Instructions:
# 1. Open Godot editor
# 2. In the FileSystem dock, navigate to scripts/tools/
# 3. Right-click on verify_species_system.gd
# 4. Select "Run in Godot"
# 5. Check the Output tab for results
# ==============================================================================

@tool
extends EditorScript

func _run():
	print("🔍 VERIFYING SPECIES SYSTEM...")
	
	var all_good = true
	
	# Check 1: Project configuration
	print("\n1️⃣ Checking project configuration...")
	if verify_project_config():
		print("✅ Project autoloads configured correctly")
	else:
		print("❌ Project configuration issues")
		all_good = false
	
	# Check 2: Class registration
	print("\n2️⃣ Checking class registration...")
	if verify_classes():
		print("✅ All classes registered correctly")
	else:
		print("❌ Class registration issues")
		all_good = false
	
	# Check 3: Resource files
	print("\n3️⃣ Checking resource files...")
	if verify_resources():
		print("✅ All resource files valid")
	else:
		print("❌ Resource file issues")
		all_good = false
	
	# Check 4: Scene files
	print("\n4️⃣ Checking scene files...")
	if verify_scenes():
		print("✅ All scene files valid")
	else:
		print("❌ Scene file issues")
		all_good = false
	
	# Final result
	print("\n" + "="*50)
	if all_good:
		print("🎉 ALL SYSTEMS GO! Species system is ready!")
		print("🚀 You can now run the game and test species selection!")
	else:
		print("⚠️  Some issues found. Check the messages above.")
	print("="*50)

func verify_project_config() -> bool:
	# Check if project.godot contains SpeciesManager autoload
	var project_file = FileAccess.open("res://project.godot", FileAccess.READ)
	if not project_file:
		print("   ❌ Cannot read project.godot")
		return false
	
	var content = project_file.get_as_text()
	project_file.close()
	
	if "SpeciesManager=" in content:
		print("   ✅ SpeciesManager autoload found")
		return true
	else:
		print("   ❌ SpeciesManager autoload missing")
		return false

func verify_classes() -> bool:
	var success = true
	
	# Test SpeciesDataSimple
	var species_data = SpeciesDataSimple.new()
	if species_data:
		print("   ✅ SpeciesDataSimple class works")
	else:
		print("   ❌ SpeciesDataSimple class failed")
		success = false
	
	# Test SpeciesStatsBar
	var stats_bar = SpeciesStatsBar.new()
	if stats_bar:
		print("   ✅ SpeciesStatsBar class works")
		stats_bar.queue_free()
	else:
		print("   ❌ SpeciesStatsBar class failed")
		success = false
	
	return success

func verify_resources() -> bool:
	var success = true
	var resources = [
		"res://data/species/fire_ant_simple.tres",
		"res://data/species/carpenter_ant_simple.tres"
	]
	
	for path in resources:
		if FileAccess.file_exists(path):
			var resource = load(path)
			if resource and resource is SpeciesDataSimple:
				print("   ✅ ", path.get_file(), " loads correctly")
			else:
				print("   ❌ ", path.get_file(), " failed to load as SpeciesDataSimple")
				success = false
		else:
			print("   ❌ ", path.get_file(), " not found")
			success = false
	
	return success

func verify_scenes() -> bool:
	var success = true
	var scenes = [
		"res://scenes/ui/species_stats_bar.tscn",
		"res://scenes/game/StrategicMap.tscn"
	]
	
	for path in scenes:
		if FileAccess.file_exists(path):
			var scene = load(path)
			if scene:
				print("   ✅ ", path.get_file(), " loads correctly")
			else:
				print("   ❌ ", path.get_file(), " failed to load")
				success = false
		else:
			print("   ❌ ", path.get_file(), " not found")
			success = false
	
	return success
