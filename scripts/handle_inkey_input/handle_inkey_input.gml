// === 2A. Create this as a separate script file (handle_inkey_input.gml) ===
/// @function handle_inkey_input()
/// @description Handle INKEY$ input during pause
function handle_inkey_input() {
    // Only process if we're in INKEY$ mode
    if (!global.inkey_mode) return false;
    
    // Scan for any printable key press
    for (var key = 32; key <= 126; key++) { // printable ASCII range
        if (keyboard_check_pressed(key)) {
            var ch = chr(key);
            
            // Store the result
            global.basic_variables[? "__INKEY_RESULT"] = ch;
            
            // Resume program execution
            global.pause_in_effect = false;
            global.awaiting_input = false;
            global.input_target_var = "";
            global.pause_mode = false;
            global.input_expected = false;
            global.inkey_mode = false;
            
            if (dbg_on(DBG_FLOW)) show_debug_message("INKEY$: Got keypress '" + ch + "' (code " + string(key) + "), resuming program");
            return true; // Input was handled
        }
    }
    
    // Handle special keys if needed
    if (keyboard_check_pressed(vk_enter)) {
        global.basic_variables[? "__INKEY_RESULT"] = chr(13);
        // Resume execution (same cleanup as above)
        global.pause_in_effect = false;
        global.awaiting_input = false;
        global.input_target_var = "";
        global.pause_mode = false;
        global.input_expected = false;
        global.inkey_mode = false;
        
        if (dbg_on(DBG_FLOW)) show_debug_message("INKEY$: Got ENTER, resuming program");
        return true;
    }
    
    return false; // No input yet, keep waiting
}