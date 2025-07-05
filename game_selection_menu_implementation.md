# Game Selection Menu - Implementation Guide

## Overview
Added a Game Selection menu between Main Menu and gameplay to separate Campaign and Skirmish modes.

## New Flow
**Before:**
```
Main Menu → Start Game → Strategic Map
```

**After:**
```
Main Menu → Start Game → Game Selection Menu → Choose Mode:
├── Campaign (Disabled - "Coming Soon" tooltip)
└── Skirmish → Strategic Map
```

## Implementation Details

### 1. Created GameSelectionMenu.tscn
- **Location**: `scenes/ui/GameSelectionMenu.tscn`
- **Layout**: Centered menu with title and 3 buttons
- **Buttons**:
  - **Campaign**: Disabled with tooltip "Coming Soon - Follow the story..."
  - **Skirmish**: Functional - leads to Strategic Map
  - **Back**: Returns to Main Menu

### 2. Created game_selection_menu.gd
- **Location**: `scripts/ui/game_selection_menu.gd`
- **Features**:
  - ESC key support (returns to Main Menu)
  - Proper Main.gd integration
  - Debug output for all interactions
  - Placeholder methods for future Campaign implementation

### 3. Updated main_menu.gd
- **Changed**: Start Game button now loads Game Selection menu
- **Path**: `res://scenes/ui/GameSelectionMenu.tscn`
- **Maintains**: All existing error handling and debug output

### 4. Updated Main.gd
- **Kept**: `start_game()` method for backward compatibility
- **Marked**: As deprecated in favor of Game Selection menu flow

## Test Procedure

### Test 1: Main Menu Flow
1. **Run project** (F5)
2. **Main Menu**: Click "Start Game"
3. **Expected**: Game Selection menu appears with:
   - Title: "🎮 SELECT GAME MODE"
   - Campaign button (grayed out/disabled)
   - Skirmish button (active)
   - Back button

### Test 2: Campaign Button (Disabled)
1. **Hover over Campaign button**
2. **Expected**: Tooltip appears: "Coming Soon - Follow the story of the ant colony through multiple scenarios"
3. **Try clicking**: Should not respond (button disabled)

### Test 3: Skirmish Mode
1. **Click Skirmish button**
2. **Expected**: Loads Strategic Map scene
3. **Verify**: All existing Strategic Map functionality works
4. **Test**: Colony button, ESC menu, etc. should all work

### Test 4: Back Navigation
1. **From Game Selection menu, click Back**
2. **Expected**: Returns to Main Menu
3. **From Game Selection menu, press ESC**
4. **Expected**: Also returns to Main Menu

### Test 5: Tooltips
1. **Hover Campaign**: "Coming Soon" tooltip
2. **Hover Skirmish**: "Quick battle - Manage your colony and compete for territory"

## Expected Debug Output

### Main Menu → Game Selection:
```
MainMenu: Start Game button pressed
MainMenu: Found Main scene, loading Game Selection menu
Main.gd: MenuLayer mouse_filter set to STOP (menu loaded)
GameSelectionMenu: _ready() called
=== GAME SELECTION MENU LOADED ===
```

### Skirmish Selected:
```
GameSelectionMenu: Skirmish Mode selected
Starting Skirmish gameplay...
Main.gd: load_game_scene() called with path: res://scenes/game/StrategicMap.tscn
Main.gd: MenuLayer mouse_filter set to IGNORE (game scene active)
```

### Back to Main Menu:
```
GameSelectionMenu: Back button pressed
Returning to Main Menu...
Main.gd: MenuLayer mouse_filter set to STOP (menu loaded)
```

## Future Campaign Implementation

When Campaign mode is ready:

### 1. Enable Campaign Button
```gdscript
# In GameSelectionMenu.tscn
[node name="CampaignButton"]
disabled = false  # Change to true
```

### 2. Implement Campaign Handler
```gdscript
func _on_campaign_button_pressed():
    main_scene_manager.load_menu("res://scenes/ui/CampaignSelectionMenu.tscn")
```

### 3. Create Campaign Scenes
- `CampaignSelectionMenu.tscn` - Choose scenario/chapter
- Campaign-specific game scenes with story progression
- Save/load system for campaign progress

## UI Design Notes

### Visual Hierarchy
- **Title**: Large, centered, uses emoji for visual appeal
- **Buttons**: Clearly separated with HSeparators
- **Campaign**: Visually disabled to show "coming soon" status
- **Tooltips**: Provide context without cluttering interface

### User Experience
- **Clear Choice**: Two distinct game modes
- **Future-Proof**: Ready for Campaign implementation
- **Consistent**: Follows same navigation patterns as other menus
- **Accessible**: ESC key support, tooltips, clear labeling

---

**Result**: Players now have a clear choice between game modes, with Campaign clearly marked as "Coming Soon" while Skirmish provides immediate access to existing gameplay.
