/// MODE 1 COMMAND
/// @function basic_cmd_pset(arg)
/// @desc PSET x, y, char, fg, bg
function basic_cmd_pset(arg) {
    var args = basic_parse_csv_args(arg);

    if (global.current_mode == 2) {
        if (array_length(args) < 2) {
            dbg_log(DBG_FLOW, "PSET MODE2 requires at least x,y");
            return;
        }

        var px = floor(real(basic_evaluate_expression_v2(string_trim(args[0]))));
        var py = floor(real(basic_evaluate_expression_v2(string_trim(args[1]))));
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
            dbg_log(DBG_FLOW, "PSET MODE2: (" + string(px) + "," + string(py) + ") color=" + string(col));
        }
        return;
    }

    if (array_length(args) < 5) {
        dbg_log(DBG_FLOW, "PSET requires 5 arguments: x, y, char, fg, bg");
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
