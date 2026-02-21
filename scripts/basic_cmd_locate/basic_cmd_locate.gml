/// MODE 1 COMMAND
// =================================================================
// LOCATE command - set cursor position for next PRINT
// =================================================================
function basic_cmd_locate(arg) {
    if (global.current_mode < 1) {
        // In text mode, just ignore or show message
        if (dbg_on(DBG_FLOW)) show_debug_message("LOCATE: Not implemented in text mode");
        return;
    }
    
    var args = basic_parse_csv_args(arg);
    if (array_length(args) < 2) {
        if (dbg_on(DBG_FLOW)) show_debug_message("LOCATE requires 2 arguments: row, col");
        return;
    }
    
    var row = real(basic_evaluate_expression_v2(string_trim(args[0])));
    var col = real(basic_evaluate_expression_v2(string_trim(args[1])));
    
    // BASIC typically uses 1-based coordinates, convert to 0-based
    row = max(0, min(24, row - 1));
    col = max(0, min(39, col - 1));
    
    // Store cursor position in globals for PRINT to use
    global.mode1_cursor_x = col;
    global.mode1_cursor_y = row;
    
    if (dbg_on(DBG_FLOW)) show_debug_message("LOCATE: Set cursor to (" + string(col) + "," + string(row) + ")");
}