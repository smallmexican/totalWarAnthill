# Z-Index/Mouse Filter Fix - Test Guide

## Problem Identified
The MenuLayer (Control node) was blocking mouse input to the GameLayer even when empty, because:
1. Control nodes default to `mouse_filter = STOP` (blocks input)
2. MenuLayer sits above GameLayer in the scene tree
3. Even when empty, MenuLayer was intercepting all mouse clicks

## Solution Applied
**Dynamic Mouse Filter Management:**
- MenuLayer starts with `mouse_filter = IGNORE` (2) in Main.tscn
- When a menu is loaded: Set to `STOP` (0) to block input to game
- When MenuLayer is cleared: Set back to `IGNORE` (2) to allow input through

## Changes Made

### 1. Main.tscn
```gdscript
# Added mouse_filter = 2 to MenuLayer
[node name="MenuLayer" type="Control" parent="."]
mouse_filter = 2  # IGNORE - allows input to pass through when empty
```

### 2. Main.gd - Added mouse filter management to all menu methods:
- `load_menu()` - Sets STOP when menu loaded
- `show_pause_menu()` - Sets STOP when pause menu shown
- `show_game_menu()` - Sets STOP when game menu shown  
- `show_settings_menu()` - Sets STOP when settings shown
- `clear_menu_layer()` - Sets IGNORE when MenuLayer cleared
- `load_game_scene()` - Sets IGNORE when game scene loads

## Test Procedure

### Test 1: Direct Scene Access (Should work - baseline)
1. Run StrategicMap.tscn directly from Godot editor
2. Colony button should be clickable ✅

### Test 2: Through Main Menu (Should now work)
1. Run Main.tscn (or F5 to run project)
2. Main Menu → Start Game
3. Strategic Map should load
4. **Colony button should now be clickable** ✅
5. Check debug output: Should see "MenuLayer mouse_filter set to IGNORE"

### Test 3: ESC Menu Overlay (Should work)
1. From Strategic Map, press ESC
2. Game Menu overlay should appear
3. Check debug output: Should see "MenuLayer mouse_filter set to STOP"
4. Resume → Should clear overlay and set back to IGNORE
5. Colony button should be clickable again ✅

### Test 4: Colony View Transition (Should work)
1. From Strategic Map, click Colony button
2. Should transition to Colony View
3. All Colony View buttons should be clickable
4. Back button should return to Strategic Map

## Expected Debug Output

### When loading Strategic Map:
```
Main.gd: load_game_scene() called with path: res://scenes/game/StrategicMap.tscn
Main.gd: MenuLayer cleared, mouse_filter set to IGNORE
Main.gd: MenuLayer mouse_filter set to IGNORE (game scene active)
```

### When pressing ESC (Game Menu):
```
Main.gd: show_game_menu() called
Main.gd: MenuLayer cleared, mouse_filter set to IGNORE
Main.gd: MenuLayer mouse_filter set to STOP (game menu loaded)
```

### When resuming from Game Menu:
```
Main.gd: MenuLayer cleared, mouse_filter set to IGNORE
Main.gd: MenuLayer mouse_filter set to IGNORE (game scene active)
```

## Mouse Filter Values Reference
- `0` = STOP: Blocks input, handles events
- `1` = PASS: Handles events but passes through
- `2` = IGNORE: Completely ignores input, passes through

## Root Cause Summary
**The issue wasn't Z-index ordering** - it was **mouse input blocking** with two problems:

### Primary Issue: Empty MenuLayer Blocking Input
The MenuLayer Control node was always above the GameLayer and blocking all mouse events, even when visually empty.

### Secondary Issue: Menu Self-Freeing Without Notification
When menus called `queue_free()` on themselves (Resume buttons), they bypassed Main.gd's mouse filter management, leaving the MenuLayer in a blocking state.

## Additional Fix Applied

### Problem: Resume Button Not Restoring Input
After using ESC menu or pause menu, clicking Resume would leave buttons non-functional because:
1. Game menu called `queue_free()` directly  
2. Main.gd's `clear_menu_layer()` wasn't called
3. MenuLayer mouse_filter remained at STOP

### Solution: Proper Resume Handling
**Updated game_menu.gd and pause_menu.gd:**
```gdscript
func _on_resume_button_pressed():
    # Call Main.gd to properly clear menu layer
    main_scene_manager.clear_menu_layer()
    # No longer call queue_free() directly
```

**Updated Main.gd clear_menu_layer():**
```gdscript
func clear_menu_layer():
    for child in $MenuLayer.get_children():
        child.queue_free()
    # Defer mouse filter change until nodes are freed
    call_deferred("_set_menu_layer_ignore")
```

This fix ensures that:
- ✅ Game buttons work when accessed through Main Menu  
- ✅ Menu overlays properly block game input when shown
- ✅ Game input is restored when menus are dismissed via Resume
- ✅ Game input is restored when returning from Settings menu
- ✅ No timing issues with queue_free() and mouse filter changes
