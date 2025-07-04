# Debug Test for GameMenu Issue

## Test Instructions

1. **Start the game** and go to Strategic Map
2. **Press ESC** and look for this debug output sequence:

### Expected Debug Output:
```
Key pressed: 4194305 (Escape)
ESC key detected (ui_cancel) - showing game menu
StrategicMap: show_game_menu() called
StrategicMap: main_scene_manager found, calling show_game_menu()
StrategicMap: show_game_menu method exists on main_scene_manager
Main.gd: show_game_menu() called
Main.gd: MenuLayer cleared
Main.gd: Loading GameMenu.tscn...
Main.gd: GameMenu instantiated successfully
Main.gd: Set previous scene to: [scene path]
Main.gd: GameMenu added to MenuLayer
GameMenu: _ready() called
GameMenu: main_scene_manager found: Main
=== GAME MENU LOADED ===
In-game menu active. Game is paused.
```

### If You See Error Messages:
- **"Failed to load GameMenu.tscn!"** → Scene file has syntax error
- **"Failed to instantiate GameMenu!"** → Script attachment issue
- **"show_game_menu method NOT found!"** → Method missing from Main.gd
- **"main_scene_manager not found!"** → Scene hierarchy issue

### If You See No Output:
- The ESC key detection isn't working
- Strategic Map script isn't attached properly
- Input handling is broken

## Troubleshooting Steps:

### 1. If GameMenu doesn't appear but debug shows success:
- The menu might be loading but not visible
- Check if GameMenu.tscn has proper layout/anchors

### 2. If no debug output at all:
- Strategic Map input handling isn't working
- Check that ui_cancel action is properly mapped

### 3. If "method NOT found" error:
- Main.gd script might not be properly saved
- Try restarting Godot editor

## Quick Manual Test:
You can also test by opening the Godot editor and:
1. Open `scenes/ui/GameMenu.tscn`
2. Click "Play Scene" button
3. See if the GameMenu appears by itself

Report back exactly what debug output you see (or don't see) when pressing ESC!
