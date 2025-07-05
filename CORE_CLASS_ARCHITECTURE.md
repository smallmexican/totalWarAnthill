# Total War Anthill - Core Class Architecture Design

## Primary Classes (Your Suggestions)

### 1. **ANT** 🐜
**Purpose**: Individual ant units with roles and behaviors
```gdscript
class_name Ant extends Node2D

# Core Properties
var ant_type: String          # Worker, Soldier, Queen, etc.
var species: String           # Fire Ants, Carpenter Ants, etc.
var health: int
var energy: int
var current_task: String      # Gathering, Building, Fighting, etc.
var carrying_resource: String # Food, Material, Larvae, etc.
var movement_speed: float
var attack_power: int
var defense_rating: int

# Behaviors
func assign_task(task: String)
func move_to_location(target: Vector2)
func gather_resource(resource_type: String)
func attack_target(target: Node)
func return_to_colony()
```

### 2. **BUILDING** 🏗️
**Purpose**: Colony structures and rooms
```gdscript
class_name Building extends Node2D

# Core Properties
var building_type: String     # Nursery, Storage, Barracks, etc.
var health: int
var max_capacity: int
var current_occupancy: int
var construction_progress: float
var resource_cost: Dictionary
var species_bonuses: Dictionary

# Functions
func construct(resources: Dictionary)
func upgrade()
func assign_workers(worker_count: int)
func process_function()       # Breed larvae, store food, etc.
```

### 3. **COLONY** 🏛️
**Purpose**: High-level colony management and coordination
```gdscript
class_name Colony extends Node2D

# Core Properties
var colony_name: String
var species: String
var population: int
var food_storage: int
var material_storage: int
var territory_size: int
var buildings: Array[Building]
var ants: Array[Ant]
var research_progress: Dictionary

# Management
func spawn_ant(ant_type: String)
func construct_building(building_type: String, location: Vector2)
func allocate_workers(task: String, count: int)
func manage_resources()
```

---

## Essential Supporting Classes

### 4. **RESOURCE** 💎
**Purpose**: All harvestable materials and consumables
```gdscript
class_name Resource extends Node2D

var resource_type: String     # Food, Stone, Wood, Water
var quantity: int
var regeneration_rate: float
var depletion_rate: float
var location: Vector2
var accessibility: float     # How easy to harvest

func harvest(amount: int) -> int
func regenerate()
```

### 5. **TERRAIN_TILE** 🗺️
**Purpose**: Map tiles with different properties
```gdscript
class_name TerrainTile extends Node2D

var tile_type: String         # Grass, Dirt, Rock, Water
var movement_cost: float      # How hard to traverse
var diggable: bool
var resources: Array[Resource]
var occupied_by: Node         # Building or tunnel
var visibility: float        # Fog of war

func can_build_here() -> bool
func get_movement_cost(ant_species: String) -> float
```

### 6. **TUNNEL** 🕳️
**Purpose**: Underground pathways connecting colony areas
```gdscript
class_name Tunnel extends Node2D

var tunnel_width: int
var depth_level: int
var connected_rooms: Array[Building]
var traffic_capacity: int
var construction_progress: float

func connect_to(target: Building)
func calculate_travel_time(start: Vector2, end: Vector2) -> float
```

### 7. **TASK** 📋
**Purpose**: Individual work assignments for ants
```gdscript
class_name Task extends RefCounted

var task_type: String         # Gather, Build, Fight, Patrol
var priority: int
var target_location: Vector2
var required_ants: int
var assigned_ants: Array[Ant]
var completion_progress: float
var estimated_time: float

func assign_ant(ant: Ant)
func update_progress()
func is_complete() -> bool
```

### 8. **PHEROMONE_TRAIL** 🔴
**Purpose**: Chemical communication between ants
```gdscript
class_name PheromoneTrail extends Node2D

var trail_type: String        # Food, Danger, Home, Enemy
var intensity: float
var decay_rate: float
var path_points: Array[Vector2]
var created_by: Ant

func strengthen_trail()
func decay_over_time()
func follow_trail(ant: Ant)
```

---

## Management & System Classes

### 9. **SPECIES_DATA** 🧬
**Purpose**: Define characteristics of different ant species
```gdscript
class_name SpeciesData extends Resource

var species_name: String
var base_stats: Dictionary    # Attack, Defense, Speed, etc.
var special_abilities: Array[String]
var building_bonuses: Dictionary
var resource_preferences: Dictionary
var reproduction_rate: float

func get_species_bonus(stat_name: String) -> float
func get_building_bonus(building_type: String) -> float
```

### 10. **AI_CONTROLLER** 🤖
**Purpose**: Manage computer opponent behavior
```gdscript
class_name AIController extends Node

var difficulty: String        # Easy, Normal, Hard
var personality: String       # Aggressive, Defensive, Economic
var controlled_colony: Colony
var decision_frequency: float
var current_strategy: String

func make_decision()
func prioritize_tasks()
func respond_to_threats()
```

### 11. **GAME_STATE** 💾
**Purpose**: Overall game state management and persistence
```gdscript
class_name GameState extends Node

var match_config: Dictionary  # From SkirmishSetupMenu
var game_time: float
var turn_number: int
var victory_conditions: Dictionary
var player_colonies: Array[Colony]
var ai_colonies: Array[Colony]

func save_game()
func load_game()
func check_victory_conditions()
```

### 12. **RESOURCE_MANAGER** 📊
**Purpose**: Track and manage all resources globally
```gdscript
class_name ResourceManager extends Node

var total_food: int
var total_materials: int
var resource_nodes: Array[Resource]
var trade_routes: Array[Dictionary]

func distribute_resources()
func calculate_income()
func handle_resource_depletion()
```

---

## Specialized Classes

### 13. **BATTLE_SYSTEM** ⚔️
**Purpose**: Handle combat between ants and colonies
```gdscript
class_name BattleSystem extends Node

func initiate_combat(attacker: Ant, defender: Ant)
func calculate_damage(attacker_stats: Dictionary, defender_stats: Dictionary)
func resolve_battle_outcome()
```

### 14. **RESEARCH_TREE** 🔬
**Purpose**: Technology progression system
```gdscript
class_name ResearchTree extends Node

var available_techs: Array[String]
var researched_techs: Array[String]
var current_research: String
var research_progress: float

func start_research(tech_name: String)
func complete_research()
func unlock_new_technologies()
```

### 15. **EVENT_SYSTEM** 📅
**Purpose**: Random events and environmental changes
```gdscript
class_name EventSystem extends Node

var active_events: Array[Dictionary]
var event_probability: float

func trigger_random_event()
func handle_weather_change()
func spawn_predator_attack()
```

---

## Class Hierarchy Overview

```
Game Architecture:
├── CORE ENTITIES
│   ├── Ant (individual units)
│   ├── Building (structures)  
│   ├── Colony (settlement management)
│   ├── Resource (harvestables)
│   └── Terrain_Tile (map components)
│
├── INFRASTRUCTURE  
│   ├── Tunnel (underground paths)
│   ├── Pheromone_Trail (communication)
│   └── Task (work assignments)
│
├── MANAGEMENT SYSTEMS
│   ├── AI_Controller (computer opponents)
│   ├── Game_State (overall state)
│   ├── Resource_Manager (economy)
│   └── Species_Data (ant characteristics)
│
└── SPECIALIZED SYSTEMS
    ├── Battle_System (combat)
    ├── Research_Tree (technology)
    └── Event_System (random events)
```

---

## Implementation Priority

### Phase 1 (Core Gameplay):
1. **Ant** - Basic unit movement and tasks
2. **Colony** - Simple colony management
3. **Resource** - Basic resource gathering
4. **Task** - Work assignment system

### Phase 2 (Infrastructure):
1. **Building** - Construction system
2. **Terrain_Tile** - Map interaction
3. **Tunnel** - Underground pathways
4. **Species_Data** - Ant species differences

### Phase 3 (Advanced Features):
1. **AI_Controller** - Computer opponents
2. **Battle_System** - Combat mechanics
3. **Pheromone_Trail** - Advanced ant behavior
4. **Game_State** - Save/load system

### Phase 4 (Polish):
1. **Research_Tree** - Technology progression
2. **Event_System** - Dynamic gameplay
3. **Resource_Manager** - Economic complexity

---

## Integration with Current System

Your existing menu system can pass configuration to these classes:
```gdscript
# From SkirmishSetupMenu to GameState
var match_config = {
    "player_species": "Fire Ants",
    "opponent_species": "Carpenter Ants", 
    "opponent_difficulty": "Normal",
    "map": "Garden Valley"
}

# GameState creates colonies with species data
func initialize_match(config: Dictionary):
    var player_colony = Colony.new()
    player_colony.setup_species(config.player_species)
    
    var ai_colony = Colony.new() 
    ai_colony.setup_species(config.opponent_species)
    ai_colony.set_ai_difficulty(config.opponent_difficulty)
```

This architecture provides a solid foundation for your ant colony RTS while remaining expandable for future features!
