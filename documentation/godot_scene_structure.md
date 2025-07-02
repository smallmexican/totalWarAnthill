# 🎞️ Godot Scene Structure and Flow for Total War: Anthill

## 🔍 Overview

This document outlines the structure of a Godot project for a pixel-art, ant-themed RTS game similar to Total War. It explains how to set up the core scenes, how they interact, and includes a flow diagram for visual clarity.

---

## 🌐 Scene Architecture

### 🎮 Main Scene: `Main.tscn`

**Purpose**: Acts as the root node for the entire game, handling scene transitions and persistent global setup.

**Structure:**

```plaintext
Main.tscn
└── Node ("Main")
    ├── MenuLayer (Control)        ← UI scenes like Main Menu, Settings, Pause
    ├── GameLayer (Node or Node2D) ← Game scenes like Strategic Map, Colony View
    └── UIManager.gd (optional)    ← Helper script to manage UI switching
```

---

## 📊 Scene Roles

### 🌍 MainMenu.tscn

- Type: `Control`
- Buttons: Start Game, Settings, Quit
- Calls `Main.gd` to load the Strategic Map scene

### ⚙️ SettingsMenu.tscn

- Type: `Control`
- Accessed from Main Menu and Pause Menu
- Modifies and stores player preferences

### ⏸️ PauseMenu.tscn

- Type: `Control`
- Instanced during gameplay
- Buttons: Resume, Settings, Exit to Menu

### 🌎 StrategicMap.tscn

- Type: `Node2D` or `Control`
- Displays the overworld garden map
- Allows ant armies to move between zones
- Triggers battles or colony entry

### 🏠 ColonyView\.tscn

- Type: `Node2D`
- Zoomed-in underground view
- Shows tunnels, rooms, and workers
- Supports resource management and construction

---

## 🚀 Scene Switching Logic

```gdscript
# Main.gd
var current_game_scene: Node = null

func _ready():
    load_menu("res://scenes/ui/MainMenu.tscn")

func load_menu(path):
    clear_game_layer()
    var menu = load(path).instantiate()
    $MenuLayer.add_child(menu)

func start_game():
    load_game_scene("res://scenes/StrategicMap.tscn")

func load_game_scene(path):
    clear_game_layer()
    current_game_scene = load(path).instantiate()
    $GameLayer.add_child(current_game_scene)

func clear_game_layer():
    for child in $GameLayer.get_children():
        child.queue_free()
```

---

## 🔧 Autoloaded Singletons (Optional)

- `GameState.gd` → Stores player progress, map state, current colony
- `AudioManager.gd` → Plays and manages background music and SFX
- `SaveManager.gd` → Manages game save/load functionality

---

## 📄 Visio Flow Description

**Scene Flow Diagram** (for visual diagramming in Visio, draw boxes connected as follows):

```plaintext
[ Main.tscn (root) ]
       |
       |
   [ MenuLayer ]
       |---> [ MainMenu.tscn ]
       |---> [ SettingsMenu.tscn ]
       |---> [ PauseMenu.tscn ]

   [ GameLayer ]
       |---> [ StrategicMap.tscn ]
               |
               |---> [ ColonyView.tscn ]
               |---> [ BattleScene.tscn ] (future)
```

Use arrows to indicate possible scene transitions:

- `MainMenu` → `StrategicMap`
- `StrategicMap` → `ColonyView`
- `PauseMenu` accessible from gameplay scenes

---

