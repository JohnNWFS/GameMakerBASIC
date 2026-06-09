/// MODE 1 COMMAND
/// @function basic_cmd_charat(arg)
/// @desc CHARAT x, y, charIndex [, fg [, bg]]
function basic_cmd_charat(arg) {
    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "CHARAT", 3, 5, "x,y,char[,fg[,bg]]")) return;

    // Evaluate coordinates (identifiers allowed)
    var x_arg = basic_eval_int_arg(args[0], "CHARAT", "x");
    var y_arg = basic_eval_int_arg(args[1], "CHARAT", "y");
    var ch_arg = basic_eval_int_arg(args[2], "CHARAT", "char");
    if (!x_arg.ok || !y_arg.ok || !ch_arg.ok) return;
    var _x = x_arg.value;
    var _y = y_arg.value;
    var char_index = ch_arg.value;

    // Optional colors (undefined => preserve existing cell colors)
    var fg = (array_length(args) > 3) ? basic_parse_color(string_trim(args[3])) : undefined;
    var bg = (array_length(args) > 4) ? basic_parse_color(string_trim(args[4])) : undefined;

    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) {
        dbg_log(DBG_FLOW, "CHARAT: grid not found");
        return;
    }

    var cols = grid_obj.grid_cols;
    var rows = grid_obj.grid_rows;
    if (_x < 0 || _x >= cols || _y < 0 || _y >= rows) {
        dbg_log(DBG_FLOW, "CHARAT: coordinates out of bounds (" + string(_x) + "," + string(_y) + ")");
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
