function mode1_grid_set(col, row, char_index, fg, bg) {
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) {
        show_debug_message("mode1_grid_set: No grid object found.");
        return;
    }

    var cols = 40;
    var rows = 25;

    if (col >= 0 && col < cols && row >= 0 && row < rows) {
        var index = col + row * cols;
        grid_obj.grid[index].char = char_index;
        grid_obj.grid[index].fg = fg;
        grid_obj.grid[index].bg = bg;
        show_debug_message("mode1_grid_set: Set (" + string(col) + "," + string(row) + ") = " + string(char_index));
    } else {
        show_debug_message("mode1_grid_set: Coordinates out of bounds (" + string(col) + "," + string(row) + ")");
    }
}
