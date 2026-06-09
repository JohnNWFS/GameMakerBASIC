/// MODE 1 COMMAND
/// @function basic_cmd_pset(arg)
/// @desc PSET x, y, char, fg, bg
function basic_cmd_pset(arg) {
    var args = basic_parse_csv_args(arg);

    if (global.current_mode == 3) {
        if (!basic_require_arg_count(args, "PSET", 2, 3, "x,y[,color]")) return;

        var px_arg = basic_eval_int_arg(args[0], "PSET", "x");
        var py_arg = basic_eval_int_arg(args[1], "PSET", "y");
        if (!px_arg.ok || !py_arg.ok) return;
        var px = px_arg.value;
        var py = py_arg.value;
        var col = c_white;

        if (array_length(args) >= 3) {
            col = basic_parse_color(string_trim(args[2]));
        }

        if (!variable_global_exists("mode2_surface") || !surface_exists(global.mode2_surface)) {
            mode2_surface_recreate();
        }

        if (surface_exists(global.mode2_surface)) {
            surface_set_target(global.mode2_surface);
            draw_set_color(col);
            draw_point(px, py);
            surface_reset_target();
            dbg_log(DBG_FLOW, "PSET MODE3: (" + string(px) + "," + string(py) + ") color=" + string(col));
        }
        return;
    }

    if (!basic_require_arg_count(args, "PSET", 5, 5, "x,y,char,fg,bg")) return;

    // Evaluate expressions for x, y, and char
    var x_arg = basic_eval_int_arg(args[0], "PSET", "x");
    var y_arg = basic_eval_int_arg(args[1], "PSET", "y");
    var ch_arg = basic_eval_int_arg(args[2], "PSET", "char");
    if (!x_arg.ok || !y_arg.ok || !ch_arg.ok) return;
    var x_val      = x_arg.value;
    var y_val      = y_arg.value;
    var char_index = ch_arg.value;

    // Colors
    var fg_str   = string_upper(string_trim(args[3]));
    var bg_str   = string_upper(string_trim(args[4]));
    var fg_color = ds_map_exists(global.colors, fg_str) ? global.colors[? fg_str] : c_white;
    var bg_color = ds_map_exists(global.colors, bg_str) ? global.colors[? bg_str] : c_black;

    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) {
        dbg_log(DBG_FLOW, "PSET: No grid object found");
        return;
    }

    // Bounds check
    var cols = grid_obj.grid_cols;
    var rows = grid_obj.grid_rows;
    if (x_val < 0 || x_val >= cols || y_val < 0 || y_val >= rows) {
        dbg_log(DBG_FLOW, "PSET: coordinates out of bounds: (" + string(x_val) + "," + string(y_val) + ")");
        return;
    }

    // Update cell
    mode1_grid_set(x_val, y_val, char_index, fg_color, bg_color);
    dbg_log(DBG_FLOW, "PSET: Set (" + string(x_val) + "," + string(y_val) + ") → char=" + string(char_index) + " fg=" + string(fg_color) + " bg=" + string(bg_color));
}
