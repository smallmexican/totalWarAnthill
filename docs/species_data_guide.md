# Species Data Management Guide

## Overview

This guide covers the best practices for creating, storing, and managing ant species data in your RTS game. The system is designed to be data-driven, easily editable, and extensible.

## Architecture

### Core Components

1. **SpeciesData Resource** (`scripts/core/data/species_data.gd`)
   - Godot Resource class with @export variables
   - Contains all species attributes (stats, abilities, bonuses, etc.)
   - Automatically creates property inspector UI in editor

2. **SpeciesManager Singleton** (`scripts/core/systems/species_manager.gd`)
   - Loads and caches all species data
   - Provides runtime access to species information
   - Handles hot-reloading and validation

3. **Species Files** (`data/species/*.tres`)
   - Individual resource files for each species
   - Can be edited in Godot inspector or externally
   - Support for version control and modding

## Best Practices

### 1. Resource Files (.tres) - **RECOMMENDED**

**Why Use .tres Files:**
- ✅ Native Godot format with full editor support
- ✅ Type-safe with automatic validation
- ✅ Version control friendly (text-based)
- ✅ Supports complex nested data structures
- ✅ Automatic property inspector UI
- ✅ Easy to reference in code and scenes

**File Structure:**
```
data/
└── species/
    ├── fire_ant.tres
    ├── carpenter_ant.tres
    ├── leaf_cutter_ant.tres
    └── army_ant.tres
```

**Usage Example:**
```gdscript
# Load species data
var fire_ant_data = SpeciesManager.get_species_data("fire_ant")

# Apply to colony
colony.apply_species_modifiers(fire_ant_data)

# Check abilities
if fire_ant_data.has_ability("fire_attack"):
    enable_fire_damage()
```

### 2. Alternative: JSON Files

**When to Use JSON:**
- External editing tools
- Community modding
- Database integration
- Non-Godot editors

**Conversion Tools:**
```gdscript
# Export to JSON for external editing
var json_data = SpeciesCreator.export_to_json(species_data)

# Import from JSON back to .tres
var species_data = SpeciesCreator.import_from_json(json_string)
```

### 3. Dictionary Approach (NOT Recommended)

**Avoid hardcoded dictionaries because:**
- ❌ No type safety
- ❌ No editor validation
- ❌ Difficult to maintain
- ❌ No inspector UI
- ❌ Runtime errors from typos

## Creating New Species

### Method 1: Using the Editor Tool

1. Open `scenes/tools/species_editor.tscn` in Godot editor
2. Run the scene (F6)
3. Click "Create New Species"
4. Enter species ID and name
5. Edit the generated .tres file in inspector

### Method 2: Manual Creation

1. Create new .tres file in `data/species/`
2. Set script to `SpeciesData`
3. Fill in all required properties
4. Add to `SpeciesManager.species_paths`

### Method 3: Script Generation

```gdscript
# Create template
var new_species = SpeciesCreator.create_species_template("my_ant", "My Ant")

# Customize
new_species.attack_modifier = 1.3
new_species.special_abilities = ["custom_ability"]

# Save
SpeciesCreator.save_species_to_file(new_species, "res://data/species/my_ant.tres")
```

## Data Structure

### Required Fields
```gdscript
species_name: String         # Display name
species_id: String          # Unique identifier
description: String         # Short description
difficulty_rating: int      # 1-3 difficulty
```

### Stat Modifiers
```gdscript
attack_modifier: float      # 1.0 = normal, 1.2 = +20%
defense_modifier: float
speed_modifier: float
health_modifier: float
energy_modifier: float
```

### Resource Efficiency
```gdscript
food_efficiency: float      # Resource gathering/consumption
material_efficiency: float
water_efficiency: float
research_efficiency: float
```

### Special Features
```gdscript
special_abilities: Array[String]    # Unique abilities
passive_traits: Array[String]       # Always-on traits
ability_descriptions: Dictionary    # Ability explanations
```

### Bonuses and Restrictions
```gdscript
building_bonuses: Dictionary        # Building type -> multiplier
building_restrictions: Array[String] # Forbidden buildings
research_bonuses: Dictionary        # Research type -> multiplier
research_restrictions: Array[String] # Forbidden research
```

## Integration with Gameplay

### Colony Creation
```gdscript
func create_colony(species_id: String, position: Vector2):
    var colony = ColonyScene.instantiate()
    var species_data = SpeciesManager.get_species_data(species_id)
    
    colony.apply_species_data(species_data)
    colony.position = position
    add_child(colony)
```

### Ant Spawning
```gdscript
func spawn_ant(colony: Colony, ant_type: String):
    var ant = AntScene.instantiate()
    var species_data = colony.species_data
    
    # Apply species modifiers
    ant.attack *= species_data.attack_modifier
    ant.defense *= species_data.defense_modifier
    ant.speed *= species_data.speed_modifier
    
    # Apply special abilities
    for ability in species_data.special_abilities:
        ant.add_ability(ability)
```

### Building Construction
```gdscript
func can_build(building_type: String, species_data: SpeciesData) -> bool:
    return not species_data.building_restrictions.has(building_type)

func get_building_bonus(building_type: String, species_data: SpeciesData) -> float:
    return species_data.building_bonuses.get(building_type, 1.0)
```

## Validation and Testing

### Automatic Validation
```gdscript
# Validate single species
var errors = SpeciesCreator.validate_species_data(species_data)
for error in errors:
    print("Error: " + error)

# Validate all species
SpeciesManager.validate_all_species()
```

### Balance Testing
```gdscript
# Generate balance report
var all_species = SpeciesManager.get_all_species()
var report = SpeciesCreator.generate_balance_report(all_species)
print(report)
```

### Hot-Reloading
```gdscript
# Reload species data during development
SpeciesManager.reload_species_data("fire_ant")
```

## Performance Considerations

### Caching
- Species data is loaded once at startup
- Cached in memory for fast access
- No file I/O during gameplay

### Memory Usage
- ~1-2KB per species resource
- Dictionary lookups are O(1)
- Consider lazy loading for 100+ species

### Optimization Tips
```gdscript
# Cache frequently used species
var player_species = SpeciesManager.get_species_data(player_species_id)

# Batch operations
var species_list = SpeciesManager.get_multiple_species(["fire_ant", "carpenter_ant"])

# Avoid repeated lookups
var species_data = colony.species_data  # Store reference
var bonus = species_data.building_bonuses.get("barracks", 1.0)
```

## Modding Support

### File Structure for Mods
```
mods/
└── cool_ants_mod/
    ├── mod_info.json
    └── data/
        └── species/
            ├── laser_ant.tres
            └── cyber_ant.tres
```

### Loading Mod Species
```gdscript
func load_mod_species(mod_path: String):
    var mod_species_path = mod_path + "/data/species/"
    SpeciesManager.load_species_from_directory(mod_species_path)
```

## Version Control

### .tres Files in Git
- Text-based format
- Shows meaningful diffs
- Easy to merge changes
- Track balance modifications

### Best Practices
```gitignore
# Include species data
data/species/*.tres

# Exclude temporary files
data/species/*.tmp
```

## Common Patterns

### Species Templates
Create base templates for common ant types:
```gdscript
# Combat-focused template
var combat_template = create_combat_species_template()
combat_template.attack_modifier = 1.3
combat_template.special_abilities = ["berserker_rage"]

# Builder-focused template  
var builder_template = create_builder_species_template()
builder_template.material_efficiency = 1.4
builder_template.building_bonuses["walls"] = 1.5
```

### Ability System Integration
```gdscript
# Define abilities in separate resources
var fire_attack_ability = preload("res://data/abilities/fire_attack.tres")

# Reference in species data
species_data.special_abilities = ["fire_attack"]
species_data.ability_resources = {"fire_attack": fire_attack_ability}
```

### Dynamic Species Creation
```gdscript
# Create species from external data
func create_species_from_api(api_data: Dictionary):
    var species = SpeciesData.new()
    species.import_from_dictionary(api_data)
    return species
```

This system provides a robust, flexible foundation for managing species data that can grow with your game's complexity while remaining easy to use and modify.
