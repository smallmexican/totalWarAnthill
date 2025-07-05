# Quick Fix: Species Data System

## Problem Resolution

The original `SpeciesData` class had complex default values that caused serialization issues with Godot's `.tres` format. Here's the **fixed, working solution**:

## ✅ Working Solution

### 1. Use `SpeciesDataSimple` class
Located at: `scripts/core/data/species_data_simple.gd`

**Benefits:**
- ✅ Simple, reliable serialization
- ✅ No complex default values
- ✅ Works with Godot's inspector
- ✅ Easy to edit and modify

### 2. Working Species Files
- `data/species/fire_ant_simple.tres` ✅ 
- `data/species/carpenter_ant_simple.tres` ✅ 

### 3. Testing Tools
- `scripts/tools/test_simple_species.gd` - Test the system
- `scenes/tools/species_editor.tscn` - Updated editor tool

## How to Use

### Load Species Data:
```gdscript
# Load species
var fire_ant = load("res://data/species/fire_ant_simple.tres") as SpeciesDataSimple

# Check species info
print(fire_ant.species_name)  # "Fire Ant"
print(fire_ant.attack_modifier)  # 1.3
print(fire_ant.has_ability("fire_attack"))  # true
```

### Create New Species:
```gdscript
# Create new species
var my_species = SpeciesDataSimple.new()
my_species.species_name = "My Ant"
my_species.species_id = "my_ant"
my_species.attack_modifier = 1.2

# Save to file
ResourceSaver.save(my_species, "res://data/species/my_ant.tres")
```

### Use in Gameplay:
```gdscript
# Apply to colony
func apply_species_data(colony: Colony, species_data: SpeciesDataSimple):
    colony.attack_bonus = species_data.attack_modifier
    colony.defense_bonus = species_data.defense_modifier
    
    # Apply special abilities
    for ability in species_data.special_abilities:
        colony.add_ability(ability)
```

## Testing Steps

1. **Run Test Script:**
   - In Godot Editor: Tools → Execute Script → `test_simple_species.gd`

2. **Use Species Editor:**
   - Open scene: `scenes/tools/species_editor.tscn`
   - Run scene (F6) in editor
   - Create, validate, and export species

3. **Verify Files Load:**
   - In Inspector, try loading `fire_ant_simple.tres`
   - Should load without errors

## Key Properties

### Basic Info:
- `species_name: String` - Display name
- `species_id: String` - Unique identifier  
- `description: String` - Short description
- `difficulty_rating: int` - 1-3 difficulty

### Combat Stats:
- `attack_modifier: float` - 1.0 = normal, 1.2 = +20%
- `defense_modifier: float`
- `speed_modifier: float`
- `health_modifier: float`

### Abilities:
- `special_abilities: Array[String]` - Unique abilities
- `passive_traits: Array[String]` - Always-on traits

### Utility Methods:
- `has_ability(name: String) -> bool`
- `get_total_stat_modifiers() -> float`
- `get_display_name() -> String`
- `get_summary() -> String`

## Migration Path

If you want to migrate the complex `SpeciesData` class later:

1. Start with `SpeciesDataSimple` for core functionality
2. Add properties incrementally as needed
3. Test each addition with `.tres` files
4. Use `@export_group` to organize inspector UI
5. Avoid complex default values in Dictionary/Array exports

## Next Steps

1. ✅ Use the working `SpeciesDataSimple` system
2. ✅ Create species using the editor tool or manually
3. ✅ Integrate with your colony/ant spawning systems
4. ✅ Add more species as needed
5. 🔄 Gradually expand properties when required

The simplified system gives you everything needed for a working species system while avoiding serialization issues.
