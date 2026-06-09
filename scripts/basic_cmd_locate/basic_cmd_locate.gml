/// MODE 1 COMMAND
// =================================================================
// LOCATE command - set cursor position for next PRINT
// =================================================================
function basic_cmd_locate(arg) {
    if (global.current_mode != 2) {
        // In text mode, just ignore or show message
        dbg_log(DBG_FLOW, "LOCATE: Not implemented in text mode");
        return;
    }
    
    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "LOCATE", 2, 2, "row,col")) return;
    
    var row_arg = basic_eval_number_arg(args[0], "LOCATE", "row");
    var col_arg = basic_eval_number_arg(args[1], "LOCATE", "col");
    if (!row_arg.ok || !col_arg.ok) return;
    var row = row_arg.value;
    var col = col_arg.value;
    
    // BASIC typically uses 1-based coordinates, convert to 0-based
    row = max(0, min(24, row - 1));
    col = max(0, min(39, col - 1));
    
    // Store cursor position in globals for PRINT to use
    global.mode1_cursor_x = col;
    global.mode1_cursor_y = row;
    
    dbg_log(DBG_FLOW, "LOCATE: Set cursor to (" + string(col) + "," + string(row) + ")");
}
