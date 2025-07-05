# 🐜 Total War: Anthill - Core Gameplay Implementation Guide

## 🎯 What We've Built

You now have a **complete foundation** for your ant colony RTS! Here's what's been implemented:

### ✅ **Core Classes (Phase 1)**
- **`Ant`** - Individual ant units with roles, tasks, combat, and AI
- **`Colony`** - High-level colony management with population, resources, and buildings  
- **`Building`** - Structures with construction, upgrades, and worker management
- **`Resource`** - Harvestable materials with depletion and regeneration
- **`Task`** - Work assignment system with priority and progress tracking
- **`GameState`** - Central game coordinator with save/load and victory conditions

### 🎮 **Integration Ready**
- **`GameplayIntegration`** - Bridge between your menu system and gameplay classes
- Compatible with your existing SkirmishSetupMenu configuration
- Ready to replace placeholder functionality with real gameplay

---

## 🚀 **Next Steps: Integration**

### **Step 1: Setup GameState Autoload**
1. Open **Project Settings** → **Autoload**
2. Add new autoload:
   - **Path**: `res://scripts/core/systems/game_state.gd`
   - **Node Name**: `GameState`
   - **Singleton**: ✅ Enabled
3. Click **Add** and save

### **Step 2: Update SkirmishSetupMenu**
In your `scripts/ui/skirmish_setup_menu.gd`, update the start match function:

```gdscript
func _on_start_match_button_pressed():
	var config = {
		"player_species": selected_species,
		"opponent_species": selected_opponent,
		"opponent_difficulty": selected_difficulty,
		"map": selected_map
	}
	
	# Use the new gameplay integration
	GameplayIntegration.start_skirmish_match(config)
```

### **Step 3: Update Strategic Map Scene**
Add to your `scripts/game/strategic_map.gd`:

```gdscript
# Add at the top of _ready():
func _ready():
	# ... existing code ...
	
	# Connect to GameState for live updates
	if GameState:
		GameState.colony_created.connect(_on_colony_created)
		GameState.resource_node_discovered.connect(_on_resource_discovered)
		update_map_display()

# Add these new functions:
func update_map_display():
	for colony in GameState.all_colonies:
		create_colony_marker(colony)
	
	for resource in GameState.world_resources:
		create_resource_marker(resource)

func create_colony_marker(colony: Colony):
	var marker = ColorRect.new()
	marker.size = Vector2(20, 20)
	marker.position = colony.global_position - Vector2(10, 10)
	marker.color = Color.BLUE if colony.player_controlled else Color.RED
	add_child(marker)
	
	# Add label
	var label = Label.new()
	label.text = colony.colony_name
	label.position = colony.global_position + Vector2(25, -10)
	add_child(label)

func create_resource_marker(resource: Resource):
	var marker = ColorRect.new()
	marker.size = Vector2(15, 15)
	marker.position = resource.global_position - Vector2(7, 7)
	
	match resource.resource_type:
		"food": marker.color = Color.GREEN
		"materials": marker.color = Color.BROWN
		"water": marker.color = Color.BLUE
		"rare_minerals": marker.color = Color.GOLD
	
	add_child(marker)

func _on_colony_created(colony: Colony):
	create_colony_marker(colony)

func _on_resource_discovered(resource: Resource):
	print("🌿 Resource discovered: ", resource.resource_name)
```

### **Step 4: Update Colony View Scene**
Add to your `scripts/game/colony_view.gd`:

```gdscript
# Add these variables at the top:
var active_colony: Colony

# Update _ready():
func _ready():
	# ... existing code ...
	
	# Find player colony from GameState
	if GameState and not GameState.player_colonies.is_empty():
		initialize_with_colony(GameState.player_colonies[0])

# Add these new functions:
func initialize_with_colony(colony: Colony):
	active_colony = colony
	colony.ant_spawned.connect(_on_ant_spawned)
	colony.building_constructed.connect(_on_building_constructed)
	colony.resource_changed.connect(_on_resource_changed)
	colony.population_changed.connect(_on_population_changed)
	update_colony_display()

func update_colony_display():
	update_population_display()
	update_resource_display()
	update_building_display()

func update_population_display():
	if active_colony:
		worker_count = active_colony.ant_types_count.get("Worker", 0)
		soldier_count = active_colony.ant_types_count.get("Soldier", 0)
		# Update your UI labels here

func update_resource_display():
	if active_colony:
		food_count = active_colony.resources.get("food", 0)
		material_count = active_colony.resources.get("materials", 0)
		# Update your UI labels here

func update_building_display():
	if active_colony:
		building_count = active_colony.buildings.size()
		# Update your UI labels here

# Update button handlers to use real functionality:
func _on_manage_button_pressed():
	print("=== MANAGE BUTTON CLICKED ===")
	if active_colony:
		# Assign idle workers to gathering tasks
		var idle_ants = active_colony.get_idle_ants()
		for ant in idle_ants:
			if ant.ant_type == "Worker":
				var gather_task = active_colony.create_gather_task(Vector2(100, 100))
				ant.assign_task(gather_task)
		print("🐜 Assigned ", idle_ants.size(), " workers to gathering")

func _on_build_button_pressed():
	print("=== BUILD BUTTON CLICKED ===")
	if active_colony:
		# Build a storage building
		var building = active_colony.construct_building("Storage", Vector2(50, 50))
		if building:
			print("🏗️ Started building construction")
		else:
			print("⚠️ Cannot build - insufficient resources")

# Signal handlers:
func _on_ant_spawned(colony: Colony, ant: Ant):
	update_population_display()
	print("🐜 New ant spawned: ", ant.ant_type)

func _on_building_constructed(colony: Colony, building: Building):
	update_building_display()
	print("🏗️ Building completed: ", building.building_name)

func _on_resource_changed(colony: Colony, resource_type: String, new_amount: int):
	update_resource_display()

func _on_population_changed(colony: Colony, new_population: int):
	update_population_display()
```

---

## 🎨 **Visual Integration (Optional)**

### **Add Ant Sprites**
Create simple colored rectangles that represent ants moving around:

```gdscript
# In Colony script, when spawning ants:
func spawn_ant_visual(ant: Ant):
	var sprite = ColorRect.new()
	sprite.size = Vector2(8, 8)
	sprite.position = ant.global_position
	
	match ant.ant_type:
		"Worker": sprite.color = Color.BROWN
		"Soldier": sprite.color = Color.RED
		"Queen": sprite.color = Color.GOLD
		"Scout": sprite.color = Color.GREEN
	
	add_child(sprite)
	
	# Move sprite with ant
	var tween = create_tween()
	tween.tween_property(sprite, "position", ant.target_position, 2.0)
```

---

## 🧪 **Testing Your Implementation**

### **Test 1: Basic Flow**
1. Run your game
2. Navigate: Main Menu → Start Game → Skirmish → Start Match
3. You should see:
   - Strategic Map with colony markers
   - Real resource nodes
   - Transition to Colony View works
   - Live population/resource counts

### **Test 2: Gameplay Systems**
1. In Colony View, click "Manage Colony"
   - Should assign ants to gathering tasks
   - Resource counts should increase over time
2. Click "Build Structures"
   - Should consume resources
   - Building count should increase
3. Press ESC for Game Menu - should still work

### **Test 3: AI and Progression**
1. Let the game run for a few minutes
2. You should see:
   - Ants spawning automatically
   - Resources being gathered
   - AI colony making decisions
   - Turn progression messages in console

---

## 🎯 **What You'll See**

### **Strategic Map**
- 🔵 Blue markers = Your colonies
- 🔴 Red markers = AI colonies  
- 🟢 Green dots = Food resources
- 🟤 Brown dots = Material resources
- 🔵 Blue dots = Water resources
- 🟡 Gold dots = Rare minerals

### **Colony View**
- Live population counts updating
- Real resource numbers changing
- Building construction progress
- Ant task assignments working

### **Console Output**
- 🐜 Ant spawning messages
- 📋 Task assignment logs
- 🏗️ Building construction updates
- 📦 Resource gathering notifications
- ⏰ Turn progression
- 🎲 Random events

---

## 🚀 **Future Expansion**

Your foundation supports easy expansion:

### **Phase 2 (Infrastructure)**
- **Navigation System** - Pathfinding for ants
- **Tunnel Networks** - Underground connections
- **Pheromone Trails** - Ant communication
- **Species Differences** - Unique abilities per species

### **Phase 3 (Advanced Features)**
- **Combat System** - Battles between colonies
- **Research Tree** - Technology progression
- **AI Improvements** - Smarter computer opponents
- **Map Editor** - Custom battlefields

### **Phase 4 (Polish)**
- **Visual Effects** - Particles, animations
- **Audio System** - Sounds and music
- **UI Polish** - Professional interface
- **Campaign Mode** - Story-driven gameplay

---

## 📝 **Summary**

You now have:
✅ **Complete RTS foundation** with all core systems
✅ **Integration bridge** to your existing menu system  
✅ **Modular architecture** for easy expansion
✅ **Save/load system** for game persistence
✅ **AI framework** for computer opponents
✅ **Victory conditions** for competitive gameplay

**Your ant colony RTS is ready to come alive!** 🐜👑

The transition from placeholder to real gameplay is just 4 simple steps away. Once implemented, you'll have a fully functional RTS with strategic depth, resource management, and AI opponents.

Ready to watch your ant empire grow? 🏛️⚔️
