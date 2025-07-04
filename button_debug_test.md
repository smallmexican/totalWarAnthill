# Button Debug Test Guide

## Test Instructions

### 1. Test Strategic Map Colony Button

1. **Go to Strategic Map**
2. **Look for the Colony button** - it should be in the center-bottom area
3. **Try clicking it** and watch for debug output

**Expected Output if Working:**
```
Colony button clicked!
StrategicMap: enter_colony_view() called
StrategicMap: main_scene_manager found, calling load_game_scene()
StrategicMap: load_game_scene method exists
Main.gd: load_game_scene() called with path: res://scenes/game/ColonyView.tscn
[... colony loading ...]
```

**If No Output:** The button click isn't being detected

### 2. Test Colony View Buttons

1. **Enter Colony View** (using C key since that works)
2. **Look for these buttons on the right side:**
   - "🔨 Dig Tunnel"
   - "👷 Manage Workers" 
   - "⬅️ Back to Strategic Map"
3. **Click each button** and watch for debug output

**Expected Output:**
- **Dig Button:** `=== DIG BUTTON CLICKED ===`
- **Workers Button:** `=== MANAGE WORKERS BUTTON CLICKED ===`
- **Back Button:** `=== BACK BUTTON CLICKED ===`

### 3. What to Report

Please tell me:

1. **Strategic Map Colony Button:**
   - ✅ Can you see it? 
   - ✅ Does clicking it produce any debug output?
   - ✅ Does it visually respond to clicks?

2. **Colony View Buttons:**
   - ✅ Can you see them?
   - ✅ Do they respond to clicks?
   - ✅ What debug output appears when you click them?

3. **Visual Layout:**
   - Are the buttons properly positioned?
   - Do they look clickable (not grayed out)?
   - Are they overlapped by other elements?

## Possible Issues

### Strategic Map Colony Button:
- Button might be behind other UI elements
- Signal connection might be broken
- Button might be outside the clickable area

### Colony View Buttons:
- Layout anchoring issues
- Z-order problems (covered by other elements)
- Signal connections broken
- Script methods not found

Report back exactly what you see and what debug output appears!
