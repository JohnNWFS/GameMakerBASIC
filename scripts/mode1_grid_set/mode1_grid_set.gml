// Also, let's fix the mode1_grid_set function to be more defensive
function mode1_grid_set(col, row, char_index, fg, bg) {
    // Convert all parameters to the right types
    col = real(col);
    row = real(row);
    char_index = real(char_index);
    
    if (dbg_on(DBG_FLOW)) show_debug_message("mode1_grid_set called with: col=" + string(col) + ", row=" + string(row) + ", char=" + string(char_index) + ", fg=" + string(fg) + ", bg=" + string(bg));
    
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("mode1_grid_set: No grid object found.");
        return;
    }

    var cols = 40;
    var rows = 25;

    if (col >= 0 && col < cols && row >= 0 && row < rows) {
        var index = col + row * cols;
        grid_obj.grid[index].char = char_index;
        grid_obj.grid[index].fg = fg;
        grid_obj.grid[index].bg = bg;
        if (dbg_on(DBG_FLOW)) show_debug_message("mode1_grid_set: Set (" + string(col) + "," + string(row) + ") = " + string(char_index));
    } else {
        if (dbg_on(DBG_FLOW)) show_debug_message("mode1_grid_set: Coordinates out of bounds (" + string(col) + "," + string(row) + ")");
    }
}