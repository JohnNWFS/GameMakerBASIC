/// MODE 1 COMMAND
/// @function basic_cmd_pset(arg)
/// @desc PSET x, y, char, fg, bg
function basic_cmd_pset(arg) {
    var args = string_split(arg, ",");
    if (array_length(args) < 5) {
        if (dbg_on(DBG_FLOW)) show_debug_message("PSET requires 5 arguments: x, y, char, fg, bg");
        return;
    }

    // Evaluate expressions for x, y, and char
    var x_val      = floor(real(basic_evaluate_expression_v2(string_trim(args[0]))));
    var y_val      = floor(real(basic_evaluate_expression_v2(string_trim(args[1]))));
    var char_index = floor(real(basic_evaluate_expression_v2(string_trim(args[2]))));

    // Colors
    var fg_str   = string_upper(string_trim(args[3]));
    var bg_str   = string_upper(string_trim(args[4]));
    var fg_color = ds_map_exists(global.colors, fg_str) ? global.colors[? fg_str] : c_white;
    var bg_color = ds_map_exists(global.colors, bg_str) ? global.colors[? bg_str] : c_black;

    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("PSET: No grid object found");
        return;
    }

    // Bounds check
    var cols = grid_obj.grid_cols;
    var rows = grid_obj.grid_rows;
    if (x_val < 0 || x_val >= cols || y_val < 0 || y_val >= rows) {
        if (dbg_on(DBG_FLOW)) show_debug_message("PSET: coordinates out of bounds: (" + string(x_val) + "," + string(y_val) + ")");
        return;
    }

    // Update cell
    mode1_grid_set(x_val, y_val, char_index, fg_color, bg_color);
    if (dbg_on(DBG_FLOW)) show_debug_message("PSET: Set (" + string(x_val) + "," + string(y_val) + ") → char=" + string(char_index) + " fg=" + string(fg_color) + " bg=" + string(bg_color));
}
