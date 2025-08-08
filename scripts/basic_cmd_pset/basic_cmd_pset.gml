function basic_cmd_pset(arg) {
    var args = string_split(arg, ",");
    if (array_length(args) < 5) {
        show_debug_message("PSET requires 5 arguments: x, y, char, fg, bg");
        return;
    }
    
    // Evaluate expressions for x, y, and char (they might be variables or expressions)
    var x_val = real(basic_evaluate_expression_v2(string_trim(args[0])));
    var y_val = real(basic_evaluate_expression_v2(string_trim(args[1])));
    var char_index = real(basic_evaluate_expression_v2(string_trim(args[2])));
    
    var fg_str = string_upper(string_trim(args[3]));
    var bg_str = string_upper(string_trim(args[4]));
    
    var fg_color = ds_map_exists(global.colors, fg_str) ? global.colors[? fg_str] : c_white;
    var bg_color = ds_map_exists(global.colors, bg_str) ? global.colors[? bg_str] : c_black;
    
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (instance_exists(grid_obj)) {
        var cols = 40;
        var rows = 25;
        if (x_val >= 0 && x_val < cols && y_val >= 0 && y_val < rows) {
            var index = x_val + y_val * cols;
            grid_obj.grid[index].char = char_index;
            grid_obj.grid[index].fg = fg_color;
            grid_obj.grid[index].bg = bg_color;
            show_debug_message("PSET: Set tile at (" + string(x_val) + "," + string(y_val) + ") to char=" + string(char_index));
        } else {
            show_debug_message("PSET: coordinates out of bounds: (" + string(x_val) + "," + string(y_val) + ")");
        }
    } else {
        show_debug_message("PSET: No grid object found");
    }
}