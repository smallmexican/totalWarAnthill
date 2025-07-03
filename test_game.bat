@echo off
echo ===============================================
echo   TOTAL WAR: ANTHILL - DIRECT TESTING
echo ===============================================
echo.
echo Testing project without opening Godot editor...
echo.

cd /d "c:\Godot Games\Godot_v4.3-stable_mono_win64\Game Projects\total-war-anthill"

echo 1. Testing for errors (headless mode)...
"c:\Godot Games\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64.exe" --headless --quit --path . --verbose 2> error_log.txt

if %ERRORLEVEL% EQU 0 (
    echo    ✅ No critical errors found!
) else (
    echo    ❌ Errors detected! Check error_log.txt
    goto :end
)

echo.
echo 2. Launching game window...
echo    - Test menu centering
echo    - Test ESC and P keys in Strategic Map
echo    - Check console output for debug messages
echo.

"c:\Godot Games\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64.exe" --path .

:end
echo.
echo Testing complete!
pause
