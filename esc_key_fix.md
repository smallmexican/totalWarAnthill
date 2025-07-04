# ESC Key Menu Transition Fix

## Issue Identified
The problem was that when pressing ESC in the Strategic Map, the scene transition to Main Menu wasn't properly clearing the game layer, causing:
1. Strategic Map scene to continue running in background
2. Input still being processed by the old scene
3. Repeated "Returning to Main Menu..." messages
4. Unicode parsing errors when displaying ESC key character

## Fixes Applied

### ✅ Fix 1: Clear Game Layer in load_menu()
**File:** `scripts/Main.gd`
**Change:** Added `clear_game_layer()` call to `load_menu()` function
**Effect:** When returning to main menu, both MenuLayer AND GameLayer are cleared

```gdscript
func load_menu(path: String):
	clear_menu_layer()
	clear_game_layer()  # ← NEW: This ensures game scenes are properly removed
	var menu = load(path).instantiate()
	$MenuLayer.add_child(menu)
```

### ✅ Fix 2: Better Debug Output
**File:** `scripts/game/strategic_map.gd`
**Change:** Replaced `char(event.keycode)` with `OS.get_keycode_string(event.keycode)`
**Effect:** No more Unicode parsing errors for special keys like ESC

```gdscript
# OLD (caused Unicode error):
print("Key pressed: ", event.keycode, " (", char(event.keycode), ")")

# NEW (safe for all keys):
var key_name = OS.get_keycode_string(event.keycode)
print("Key pressed: ", event.keycode, " (", key_name, ")")
```

## Expected Results After Fix

### ✅ Strategic Map → Main Menu (ESC)
1. Press ESC in Strategic Map
2. Should see: `Key pressed: 4194305 (Escape)`
3. Should see: `ESC key detected (ui_cancel) - returning to main menu`
4. Should see: `Returning to Main Menu...`
5. Strategic Map scene should be completely removed
6. Main Menu should appear
7. **No repeated messages**

### ✅ No More Unicode Errors
- All key presses should show proper key names (e.g., "Escape", "P", "C")
- No more "Unicode parsing error: Invalid unicode codepoint" messages

### ✅ Clean Scene Transitions
- When returning to main menu, strategic map is completely destroyed
- No background input processing from old scenes
- Proper memory cleanup

## Test Instructions

1. **Start Game** from Main Menu
2. **Wait for Strategic Map** to fully load
3. **Press ESC** and verify:
   - Only ONE "Returning to Main Menu..." message appears
   - No Unicode errors in console
   - Clean transition back to Main Menu
   - Key shows as "Escape" instead of garbled character

4. **Test Pause Menu** (Press P):
   - Should open pause menu overlay
   - Strategic map should remain visible in background
   - No repeated messages

5. **Test Colony View** (Press C):
   - Should transition to colony view
   - No repeated messages

## Debug Output Examples

### ✅ GOOD (After Fix):
```
Key pressed: 4194305 (Escape)
ESC key detected (ui_cancel) - returning to main menu
Returning to Main Menu...
[Scene transition completes cleanly]
```

### ❌ BAD (Before Fix):
```
Key pressed: 4194305 (�)
Unicode parsing error: Invalid unicode codepoint (400001)
ESC key detected (ui_cancel) - returning to main menu
Returning to Main Menu...
[Message repeats because scene wasn't cleared]
```

## Files Modified
1. `scripts/Main.gd` - Added `clear_game_layer()` to `load_menu()`
2. `scripts/game/strategic_map.gd` - Fixed debug output Unicode issue

The ESC key functionality should now work properly with clean scene transitions!
