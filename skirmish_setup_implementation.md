# Skirmish Setup Menu - Implementation Guide

## Overview
Created a comprehensive Skirmish Setup menu that allows players to configure their match before starting gameplay, including species selection, map choice, and opponent configuration.

## New Flow
**Before:**
```
Game Selection → Skirmish → Strategic Map
```

**After:**
```
Game Selection → Skirmish → Skirmish Setup Menu → Configure:
├── Player Species (Fire/Carpenter/Harvester Ants)
├── Map Selection (Garden Valley + Coming Soon options)  
├── Opponent (Species + Difficulty)
└── Start Match → Strategic Map
```

## Features Implemented

### 1. Player Species Selection
- **Fire Ants 🔴**: Strong Attack, Fast Workers
- **Carpenter Ants ⚫**: Excellent Building, Strong Defense  
- **Harvester Ants 🟡**: Superior Resources, Fast Gathering
- **Toggle Buttons**: Visual selection with detailed stats
- **Species Info Panel**: Dynamic descriptions with pros/cons

### 2. Opponent Configuration
- **Species Options**: Random, Fire Ants, Carpenter Ants, Harvester Ants
- **Difficulty Levels**: Easy, Normal, Hard
- **Dropdown Menus**: Clean selection interface

### 3. Map Selection
- **Garden Valley**: Available (green garden theme)
- **Desert Oasis**: Coming Soon (disabled)
- **Forest Floor**: Coming Soon (disabled)  
- **Visual Preview**: Color-coded map preview area
- **Expandable**: Easy to add new maps

### 4. Match Information Panel
- **Real-time Updates**: Shows current configuration
- **Player Info**: Selected species display
- **Opponent Info**: Species and difficulty
- **Map Info**: Current map selection
- **Species Details**: Detailed stats and descriptions

## UI Layout

### Three-Panel Design:
```
┌─────────────┬─────────────┬─────────────┐
│ LEFT PANEL  │CENTER PANEL │RIGHT PANEL  │
│             │             │             │
│ Species     │ Map         │ Match Info  │
│ Selection   │ Preview &   │ &           │
│ +           │ Selection   │ Species     │
│ Opponent    │             │ Details     │
│ Config      │             │             │
└─────────────┴─────────────┴─────────────┘
│                                         │
│        [Back]     [Start Match]         │
└─────────────────────────────────────────┘
```

## Test Procedure

### Test 1: Species Selection
1. **Navigate**: Main Menu → Start Game → Skirmish
2. **Skirmish Setup appears**: Should show Fire Ants selected by default
3. **Click Carpenter Ants**: Button highlights, species info updates
4. **Click Harvester Ants**: Button highlights, species info updates  
5. **Verify**: Only one species selected at a time
6. **Check Info Panel**: Species details update with each selection

### Test 2: Opponent Configuration
1. **Opponent Species**: Dropdown shows "Random Species" by default
2. **Change to specific species**: Select Fire Ants, Carpenter Ants, etc.
3. **Difficulty**: Dropdown shows "Normal" by default
4. **Change difficulty**: Select Easy or Hard
5. **Verify Match Info**: Updates show opponent changes

### Test 3: Map Selection  
1. **Default Map**: Garden Valley selected
2. **Map Preview**: Shows green color for Garden Valley
3. **Try other maps**: Should be disabled ("Coming Soon")
4. **Verify**: Only Garden Valley is selectable

### Test 4: Match Information
1. **Real-time Updates**: All panels update when selections change
2. **Player Info**: Shows "Player: [Selected Species]"
3. **Opponent Info**: Shows "Opponent: [Species] ([Difficulty])"
4. **Map Info**: Shows "Map: [Selected Map]"

### Test 5: Navigation
1. **ESC Key**: Should return to Game Selection
2. **Back Button**: Should return to Game Selection  
3. **Start Match**: Should load Strategic Map with configuration
4. **All buttons responsive**: No lag or missing responses

### Test 6: Tooltips
1. **Species Buttons**: Hover shows species descriptions
2. **Opponent Dropdowns**: Hover shows explanations
3. **Map Options**: Hover shows map descriptions
4. **Navigation Buttons**: Hover shows function explanations

## Expected Debug Output

### Menu Loading:
```
GameSelectionMenu: Skirmish Mode selected
Opening Skirmish Setup menu...
SkirmishSetupMenu: _ready() called
=== SKIRMISH SETUP MENU LOADED ===
```

### Species Selection:
```
Player species selected: Carpenter Ants
```

### Opponent Configuration:
```
Opponent species selected: Fire Ants
Difficulty selected: Hard
```

### Map Selection:
```
Map selected: Garden Valley
```

### Starting Match:
```
SkirmishSetupMenu: Start Match button pressed
Starting skirmish with configuration:
  Player: Harvester Ants
  Opponent: Fire Ants (Hard)
  Map: Garden Valley
Main.gd: load_game_scene() called with path: res://scenes/game/StrategicMap.tscn
```

## Configuration Data Structure

The match configuration is stored in:
```gdscript
var match_config = {
    "player_species": "Fire Ants",
    "opponent_species": "Random", 
    "opponent_difficulty": "Normal",
    "map": "Garden Valley"
}
```

## Future Expansion Points

### 1. Species System
- Add more ant species (Army Ants, Leafcutter Ants, etc.)
- Implement species-specific abilities and units
- Add visual species representations

### 2. Map System
- Create actual map assets for Desert Oasis and Forest Floor
- Add map-specific mechanics (water sources, terrain types)
- Implement procedural map generation

### 3. Opponent AI
- Implement difficulty scaling (resource bonuses, decision speed)
- Add AI personality types (aggressive, defensive, economic)
- Create AI behavior patterns specific to species

### 4. Match Configuration Persistence
- Pass configuration to Strategic Map
- Apply species bonuses in gameplay
- Load map-specific assets and mechanics

## Visual Design Notes

### Color Scheme
- **Background**: Dark green (forest/garden theme)
- **Species Colors**: Red/Black/Yellow for visual distinction
- **Map Preview**: Color-coded based on terrain type
- **UI Elements**: Consistent with existing menu design

### User Experience
- **Clear Visual Hierarchy**: Title → Configuration → Action buttons
- **Immediate Feedback**: Real-time updates in info panel
- **Tooltips**: Helpful information without clutter
- **Accessibility**: High contrast, clear labels, logical flow

---

**Result**: Players now have a comprehensive pre-match configuration system that sets up the foundation for species-based gameplay and map variety, while maintaining a professional and intuitive interface.
