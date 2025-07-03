# 📋 Script Usage Guide - Total War: Anthill

## 🎯 Overview

This document explains how to use and extend the existing scripts in the Total War: Anthill project. Each script is thoroughly documented with comments, but this guide provides additional context and usage examples.

---

## 🎮 Main.gd - Scene Manager

### Purpose
Central hub that manages all scene transitions and maintains the game's architecture.

### How It Works
```gdscript
# The Main scene has two layers:
Main (Node)
├── MenuLayer (Control)     ← UI scenes (menus, HUD)
└── GameLayer (Node2D)      ← Gameplay scenes (maps, battles)
```

### Key Methods
- `load_menu(path)` - Load UI scenes like menus
- `start_game()` - Begin gameplay (loads Strategic Map)
- `load_game_scene(path)` - Load gameplay scenes
- `clear_game_layer()` - Clean up before scene transitions

### Usage Examples
```gdscript
# From any script, access the Main scene manager:
var main = get_tree().root.get_node("Main")

# Load a different menu
main.load_menu("res://ui/PauseMenu.tscn")

# Switch to colony management
main.load_game_scene("res://scenes/game/ColonyView.tscn")

# Return to strategic map
main.load_game_scene("res://scenes/game/StrategicMap.tscn")
```

### Extension Points
1. **Add Transition Effects**: Modify `load_game_scene()` to include fade/slide transitions
2. **Scene Preloading**: Implement background loading for large scenes
3. **Pause System**: Add pause functionality that doesn't clear the current scene
4. **Audio Management**: Integrate scene-specific music changes

---

## 🖱️ main_menu.gd - Menu Controller

### Purpose
Handles user interactions on the main menu and communicates with the scene manager.

### Required Setup
1. **Scene Structure**: Attach to root Control node of MainMenu.tscn
2. **Button Connections**: Connect these signals in the Godot editor:
   - `StartButton.pressed` → `_on_start_button_pressed()`
   - `SettingsButton.pressed` → `_on_settings_button_pressed()`
   - `QuitButton.pressed` → `_on_quit_button_pressed()`

### Method Breakdown
- `_on_start_button_pressed()` - Launches main gameplay
- `_on_settings_button_pressed()` - Opens settings menu
- `_on_quit_button_pressed()` - Exits application

### Creating Similar Menu Scripts
Follow this pattern for other menus (Settings, Pause, etc.):

```gdscript
extends Control

# Always access Main scene manager for transitions
func _on_back_button_pressed():
    get_tree().root.get_node("Main").load_menu("res://ui/MainMenu.tscn")

func _on_apply_settings_pressed():
    # Apply settings logic here
    # Then return to previous menu
    get_tree().root.get_node("Main").load_menu("res://ui/MainMenu.tscn")
```

---

## 🚀 How to Extend the System

### Adding New Game Scenes

1. **Create the Scene**: Make a new .tscn file in `scenes/game/`
2. **Create the Script**: Add corresponding .gd file in `scripts/game/`
3. **Load via Main**: Use `main.load_game_scene("res://scenes/game/YourScene.tscn")`

Example for BattleScene:
```gdscript
# In StrategicMap.gd when armies meet:
func start_battle(army1, army2):
    var main = get_tree().root.get_node("Main")
    main.load_game_scene("res://scenes/game/BattleScene.tscn")
```

### Adding New Menu Scenes

1. **Create the Scene**: Make a new .tscn file in `ui/`
2. **Create the Script**: Add corresponding .gd file in `scripts/ui/`
3. **Load via Main**: Use `main.load_menu("res://ui/YourMenu.tscn")`

Example for PauseMenu:
```gdscript
# From any gameplay scene:
func _input(event):
    if event.is_action_pressed("ui_cancel"):  # ESC key
        var main = get_tree().root.get_node("Main")
        main.load_menu("res://ui/PauseMenu.tscn")
```

### Adding Persistent Data

Create an autoload singleton for game state:

1. **Create GameState.gd**:
```gdscript
# GameState.gd (Autoload singleton)
extends Node

var player_colonies = []
var current_resources = {"food": 100, "workers": 50}
var game_time = 0.0

func save_game():
    # Save logic here
    pass

func load_game():
    # Load logic here  
    pass
```

2. **Add to Autoload**: Project → Project Settings → Autoload → Add GameState.gd

3. **Access from anywhere**:
```gdscript
# Any script can now access:
GameState.current_resources["food"] += 10
GameState.player_colonies.append(new_colony)
```

---

## 🔧 Common Patterns

### Scene Communication
```gdscript
# Child scene talking to Main:
get_tree().root.get_node("Main").start_game()

# Scene talking to sibling (via Main):
var main = get_tree().root.get_node("Main")
main.load_game_scene("res://scenes/game/ColonyView.tscn")
```

### Error Handling
```gdscript
func load_scene_safely(path: String):
    if ResourceLoader.exists(path):
        load_game_scene(path)
    else:
        print("ERROR: Scene not found: ", path)
        # Fallback to main menu
        load_menu("res://ui/MainMenu.tscn")
```

### Scene Transitions with Data
```gdscript
# Pass data to new scene:
func enter_colony(colony_data):
    load_game_scene("res://scenes/game/ColonyView.tscn")
    # Access the loaded scene and pass data
    current_game_scene.setup_colony(colony_data)
```

---

## 📝 Next Steps

### Immediate Todos
1. **Create StrategicMap.tscn** - Referenced in Main.gd but doesn't exist yet
2. **Create SettingsMenu.tscn** - Referenced in main_menu.gd
3. **Add GameState singleton** - For persistent game data
4. **Create scene transition effects** - Polish the user experience

### Future Enhancements
1. **Input handling system** - Centralized input management
2. **Audio manager** - Scene-specific music and SFX
3. **Save/Load system** - Game persistence
4. **Performance optimization** - Scene pooling and preloading

---

## 🐛 Troubleshooting

### Common Issues

**"Node not found" errors:**
- Ensure Main.tscn is set as the main scene in Project Settings
- Check that node names match exactly ("Main", "MenuLayer", "GameLayer")

**Scene won't load:**
- Verify the scene path is correct and the file exists
- Check for typos in the path string
- Ensure the scene is properly saved

**Buttons not responding:**
- Verify signal connections in the Godot editor
- Check that method names match exactly
- Ensure the script is attached to the correct node

**Memory leaks:**
- Always use `queue_free()` instead of `free()` for scene cleanup
- The `clear_game_layer()` method handles this automatically

---

This documentation will evolve as the project grows. Keep it updated when adding new scripts or changing the architecture!
