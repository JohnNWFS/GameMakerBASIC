/// MODE 1 COMMAND
/// @function basic_cmd_charat(arg)
/// @desc CHARAT x, y, charIndex [, fg [, bg]]
function basic_cmd_charat(arg) {
    var args = basic_parse_csv_args(arg);
    if (array_length(args) < 3) {
        if (dbg_on(DBG_FLOW)) show_debug_message("CHARAT requires 3 arguments: x, y, char");
        return;
    }

    // Evaluate coordinates (identifiers allowed)
    var _x = floor(real(basic_evaluate_expression_v2(string_trim(args[0]))));
    var _y = floor(real(basic_evaluate_expression_v2(string_trim(args[1]))));
    var char_index = floor(real(basic_evaluate_expression_v2(string_trim(args[2]))));

    // Optional colors (undefined => preserve existing cell colors)
    var fg = (array_length(args) > 3) ? basic_parse_color(string_trim(args[3])) : undefined;
    var bg = (array_length(args) > 4) ? basic_parse_color(string_trim(args[4])) : undefined;

    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("CHARAT: grid not found");
        return;
    }

    var cols = grid_obj.grid_cols;
    var rows = grid_obj.grid_rows;
    if (_x < 0 || _x >= cols || _y < 0 || _y >= rows) {
        if (dbg_on(DBG_FLOW)) show_debug_message("CHARAT: coordinates out of bounds (" + string(_x) + "," + string(_y) + ")");
        return;
    }

    // If fg/bg are undefined, mode1_grid_set keeps existing colors
    mode1_grid_set(_x, _y, char_index, fg, bg);

    if (dbg_on(DBG_FLOW)) {
        var msg = "CHARAT: set (" + string(_x) + "," + string(_y) + ")=" + string(char_index);
        if (!is_undefined(fg)) msg += " fg=" + string(fg);
        if (!is_undefined(bg)) msg += " bg=" + string(bg);
        show_debug_message(msg);
    }
}
