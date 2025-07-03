# 🔧 Quick Menu Centering Verification

## Files Fixed:

### ✅ **Main.tscn**
- MenuLayer now has `anchors_preset = 15` (fullscreen)
- MenuLayer fills entire screen (1280x720)

### ✅ **MainMenu.tscn** 
- Root Control has `anchors_preset = 15` (fullscreen)
- Background ColorRect covers entire screen
- Title label centered at top
- VBoxContainer anchored to screen center
- Buttons properly spaced and centered

### ✅ **Main.gd**
- `load_menu()` now calls `clear_menu_layer()` instead of wrong function
- Added `clear_menu_layer()` function for proper cleanup

## 🧪 **Test Steps:**

1. **Open project in Godot**
2. **Press F5 to run**
3. **Verify main menu appears centered with:**
   - Green background covering entire screen
   - "🐜 TOTAL WAR: ANTHILL" title at top
   - Three centered buttons: Start Game, Settings, Quit
   - No UI elements cut off or offset

## 🎯 **Expected Layout:**

```
┌─────────────────────────────────────┐
│              🐜 TOTAL WAR: ANTHILL              │
│                                     │
│                                     │
│              [Start Game]           │
│              [Settings]             │
│                [Quit]               │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

## 🚨 **If Still Not Centered:**

1. **Close Godot completely**
2. **Delete `.godot/editor/` folder**
3. **Reopen project**
4. **Test again**

This forces Godot to refresh all scene cache and editor settings.

---

**The main menu should now be perfectly centered! 🎯**
