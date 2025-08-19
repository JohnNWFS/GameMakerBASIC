// @function basic_cmd_print_mode1(arg)
/// @description MODE 1 version of PRINT that writes to the grid using cursor position
function basic_cmd_print_mode1(arg) {
    // Initialize cursor if not set
    if (!variable_global_exists("mode1_cursor_x")) global.mode1_cursor_x = 0;
    if (!variable_global_exists("mode1_cursor_y")) global.mode1_cursor_y = 0;
    
    var suppress_newline = false;
    
    // Check for trailing semicolon
    if (string_length(arg) > 0 && string_char_at(arg, string_length(arg)) == ";") {
        suppress_newline = true;
        arg = string_copy(arg, 1, string_length(arg) - 1);
        if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: Semicolon detected, suppressing newline");
    }
    
    arg = string_trim(arg);
    if (arg == "") {
        if (!suppress_newline) {
            // Move cursor to next line
            global.mode1_cursor_x = 0;
            global.mode1_cursor_y = min(24, global.mode1_cursor_y + 1);
            if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: Empty line, cursor now at (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
        }
        return;
    }
    
    var output_text = "";
    
    // Handle simple quoted strings directly
    if (string_length(arg) >= 2 && string_char_at(arg, 1) == "\"" && string_char_at(arg, string_length(arg)) == "\"") {
        output_text = string_copy(arg, 2, string_length(arg) - 2);
        if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: Simple quoted string: '" + output_text + "'");
    } else {
        // Evaluate as expression for variables, numbers, etc.
        try {
            var tokens = basic_tokenize_expression_v2(arg);
            var postfix = infix_to_postfix(tokens);
            var result = evaluate_postfix(postfix);
            output_text = string(result);
            if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: Evaluated expression '" + arg + "' to: '" + output_text + "'");
        } catch (e) {
            // If evaluation fails, treat as literal string
            output_text = arg;
            if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: Expression failed, using literal: '" + output_text + "'");
        }
    }
    
    if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: Starting at cursor (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
    
    // Print each character at cursor position using mode1_grid_set
    for (var i = 0; i < string_length(output_text); i++) {
        var ch = ord(string_char_at(output_text, i + 1));
        
        if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: Setting char '" + string_char_at(output_text, i + 1) + "' (code " + string(ch) + ") at (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
        
        // Use mode1_grid_set to place character
        mode1_grid_set(global.mode1_cursor_x, global.mode1_cursor_y, ch, c_white, c_black);
        
        // Advance cursor
        global.mode1_cursor_x++;
        if (global.mode1_cursor_x >= 40) {
            global.mode1_cursor_x = 0;
            global.mode1_cursor_y = min(24, global.mode1_cursor_y + 1);
            if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: Wrapped to next line, cursor now at (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
        }
    }
    
    if (!suppress_newline) {
        global.mode1_cursor_x = 0;
        global.mode1_cursor_y = min(24, global.mode1_cursor_y + 1);
        if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: Newline, cursor now at (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
    }
    
    if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: Finished printing '" + output_text + "', cursor at (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
}