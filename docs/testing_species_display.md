# Testing Species Stats Display

## Overview

This test verifies that the species data system works end-to-end from skirmish setup to strategic map display.

## How to Test

### Option 1: Quick Test (Recommended)

1. **Run Test Script:**
   - In Godot Editor: `Tools → Execute Script`
   - Select: `scripts/tools/test_species_display.gd`
   - Check console output for test results

### Option 2: Full Integration Test

1. **Start from Main Menu:**
   - Run the project (F5)
   - Go to Skirmish Setup
   - Select "Fire Ant" as your species
   - Click "Start Match"

2. **Check Strategic Map:**
   - You should see a black top bar with species stats
   - Fire Ant stats should be displayed:
     - **Species:** Fire Ant ★★
     - **Combat:** ATK: 1.3 (green), DEF: 1.1 (white), SPD: 1.0 (white)
     - **Resources:** Food: -10% (red), Materials: -20% (red)
     - **Abilities:** Fire Attack, Heat Resistance

### Option 3: Manual Testing

1. **Load Species Directly:**
   ```gdscript
   var fire_ant = load("res://data/species/fire_ant_simple.tres") as SpeciesDataSimple
   print(fire_ant.species_name)  # Should print "Fire Ant"
   ```

2. **Test Stats Bar:**
   ```gdscript
   var stats_bar = preload("res://scenes/ui/species_stats_bar.tscn").instantiate()
   stats_bar.update_species_display(fire_ant)
   ```

## Expected Results

### ✅ Working Results:
- Species stats bar appears at top of strategic map
- Fire Ant name and ★★ difficulty displayed
- Combat stats show with appropriate colors:
  - Attack 1.3 (green - above average)
  - Defense 1.1 (white - normal)
  - Speed 1.0 (white - normal)
- Resource efficiency shows percentages with colors:
  - Food -10% (red - penalty)
  - Materials -20% (red - penalty)
- Abilities list shows: "Fire Attack, Heat Resistance"

### ❌ Troubleshooting:

**Problem:** Stats bar not visible
- Check console for error messages
- Verify `fire_ant_simple.tres` file exists and loads correctly
- Check that SpeciesStatsBar is added to StrategicMap scene

**Problem:** Species data not loading
- Run `test_simple_species.gd` to verify basic species system
- Check species file paths in console output
- Ensure SpeciesManager singleton is created

**Problem:** Stats show as "Unknown Species"
- Check that game config includes `player_species: "fire_ant"`
- Verify species ID matches the file name (`fire_ant_simple.tres`)
- Check console for species loading error messages

## Console Output

Look for these messages in the output:

```
🎮 Initializing Strategic Map with gameplay config:
   Player Species: fire_ant
✅ Loaded species data from file: Fire Ant
🧬 SpeciesStatsBar: Updating display with species data...
✅ Updating display for: Fire Ant
✅ Species stats bar update completed
```

## File Structure

```
data/species/
├── fire_ant_simple.tres          ✅ Working
├── carpenter_ant_simple.tres     ✅ Working
└── leaf_cutter_ant.tres          ⚠️ Old format

scenes/ui/
└── species_stats_bar.tscn        ✅ UI Component

scripts/ui/
└── species_stats_bar.gd          ✅ Logic

scripts/game/
└── strategic_map.gd               ✅ Updated with species integration
```

## Next Steps

Once the species stats display is working:

1. **Add More Species:** Create more `*_simple.tres` files
2. **Enhance UI:** Add species icons, tooltips, animations
3. **Gameplay Integration:** Use species stats in actual combat/resource systems
4. **Opponent Display:** Show opponent species stats as well
5. **Dynamic Updates:** Update stats when abilities are gained/lost

This system provides a solid foundation for displaying species information throughout your RTS game!
