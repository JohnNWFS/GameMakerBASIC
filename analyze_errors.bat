@echo off
setlocal enabledelayedexpansion

set "SEARCH_DIR=%~dp0"
set "OUTPUT_DIR=%SEARCH_DIR%error_analysis_v2"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
del /q "%OUTPUT_DIR%\*.txt" 2>nul

echo Refined search for error handling inconsistencies...

:: Look for show_debug_message with specific error keywords
findstr /s /n /c:"show_debug_message" "%SEARCH_DIR%*.gml" | findstr /i "error\|syntax\|warning\|invalid\|missing\|not found\|fail" > "%OUTPUT_DIR%\debug_with_errors.txt" 2>nul

:: Look for places where execution continues after potential errors
findstr /s /n /c:"show_debug_message" "%SEARCH_DIR%*.gml" > "%OUTPUT_DIR%\all_debug_messages.txt" 2>nul

:: Find return statements that might indicate error conditions
findstr /s /n /r "return.*0.*//.*error\|return.*false.*//.*error\|return.*//.*error" "%SEARCH_DIR%*.gml" > "%OUTPUT_DIR%\commented_error_returns.txt" 2>nul

:: Find basic_show_message calls (might contain errors disguised as messages)
findstr /s /n /c:"basic_show_message" "%SEARCH_DIR%*.gml" > "%OUTPUT_DIR%\all_user_messages.txt" 2>nul

:: Find interpreter_running = false (should have user feedback)
findstr /s /n /c:"interpreter_running = false" "%SEARCH_DIR%*.gml" > "%OUTPUT_DIR%\interpreter_stops.txt" 2>nul

echo Search complete. Check the files for manual review.
pause