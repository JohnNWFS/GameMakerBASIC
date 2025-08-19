/// @function basic_cmd_scroll(arg)
/// @description SCROLL direction, amount - scroll screen contents
function basic_cmd_scroll(arg) {
    if (global.current_mode < 1) {
        if (dbg_on(DBG_FLOW)) show_debug_message("SCROLL: Not implemented in text mode");
        return;
    }
    
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("SCROLL: No grid object found");
        return;
    }
    
    // Parse direction and amount
    var _direction = "UP";
    var amount = 1;
    
    if (string_trim(arg) != "") {
        var args = basic_parse_csv_args(arg);
        if (array_length(args) >= 1) {
            _direction = string_upper(string_trim(args[0]));
            // Remove quotes if present
            if (string_length(_direction) >= 2 && string_char_at(_direction, 1) == "\"") {
                _direction = string_copy(_direction, 2, string_length(_direction) - 2);
            }
        }
        if (array_length(args) >= 2) {
            amount = max(1, real(basic_evaluate_expression_v2(string_trim(args[1]))));
        }
    }
    
    // FIXED: Pass grid_obj as first parameter, then direction, then amount
    mode1_scroll_grid(grid_obj, _direction, amount);
    
    if (dbg_on(DBG_FLOW)) show_debug_message("SCROLL: " + _direction + " by " + string(amount));
}