# 🚀 Direct Testing Commands - No Godot Editor Required

## ⚡ **Quick Test Commands**

### **Option 1: Simple Launch (PowerShell)**
```powershell
cd "c:\Godot Games\Godot_v4.3-stable_mono_win64\Game Projects\total-war-anthill"
& "c:\Godot Games\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64.exe" --path .
```

### **Option 2: Error Check First (PowerShell)**
```powershell
# Test for errors without opening window
cd "c:\Godot Games\Godot_v4.3-stable_mono_win64\Game Projects\total-war-anthill"
& "c:\Godot Games\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64.exe" --headless --quit --path . --verbose

# If no errors, launch with window
& "c:\Godot Games\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64.exe" --path .
```

### **Option 3: Use Batch File (Easiest)**
```cmd
# Just double-click: test_game.bat
# Or run from command line:
cd "c:\Godot Games\Godot_v4.3-stable_mono_win64\Game Projects\total-war-anthill"
test_game.bat
```

## 🎯 **Command Line Arguments Explained**

| Argument | Purpose |
|----------|---------|
| `--path .` | Run project from current directory |
| `--headless` | No window (for error checking) |
| `--quit` | Exit immediately after loading |
| `--verbose` | Show detailed output |
| `--debug` | Enable debug mode |

## 🧪 **Testing Checklist**

When the game launches, verify:

### **✅ Menu Centering Test**
- [ ] Main menu appears centered on screen
- [ ] Green background covers entire window
- [ ] Title "🐜 TOTAL WAR: ANTHILL" visible at top
- [ ] Three buttons centered: Start Game, Settings, Quit

### **✅ Navigation Test**
- [ ] Start Game → Strategic Map loads
- [ ] Settings → Settings menu appears centered
- [ ] Back button returns to main menu

### **✅ Strategic Map Input Test**
- [ ] ESC key → Returns to main menu
- [ ] P key → Shows pause menu overlay
- [ ] C key → Enters colony view

### **✅ Pause Menu Test**
- [ ] P key shows pause menu overlay
- [ ] ESC in pause menu → Resumes game
- [ ] Resume button → Resumes game
- [ ] Strategic map still visible behind pause menu

## 📊 **Console Output to Look For**

### **Good Signs:**
```
=== STRATEGIC MAP LOADED ===
Key pressed: 80 (P)
P key detected - showing pause menu
=== PAUSE MENU LOADED ===
ESC pressed in pause menu - resuming game
```

### **Bad Signs:**
```
ERROR: main_scene_manager is null!
ERROR: Cannot load scene
ERROR: Scene not found
```

## 🔧 **Troubleshooting Commands**

### **Force Godot to Rebuild Project**
```powershell
# Delete cache and rebuild
cd "c:\Godot Games\Godot_v4.3-stable_mono_win64\Game Projects\total-war-anthill"
Remove-Item -Recurse -Force ".godot\editor"
& "c:\Godot Games\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64.exe" --headless --quit --path .
```

### **Export Project for Standalone Testing**
```powershell
# Export as executable (requires export template)
& "c:\Godot Games\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64.exe" --headless --export-debug "Windows Desktop" "total_war_anthill.exe" --path .
```

## ⚡ **Fastest Test Method**

1. **Open PowerShell in project folder**
2. **Run this one command:**
   ```powershell
   & "c:\Godot Games\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64.exe" --path .
   ```
3. **Game launches immediately** - no editor needed!

## 🎮 **What to Test**

1. **Launch game** → Should see centered main menu
2. **Click Start Game** → Should see Strategic Map
3. **Press P** → Should see pause menu overlay
4. **Press ESC** → Should resume game
5. **Press ESC again** → Should return to main menu

---

**Your game can be tested directly without ever opening the Godot editor! 🚀**
