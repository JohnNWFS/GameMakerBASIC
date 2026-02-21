/// MODE 1 COMMAND
/// @function mode1_scroll_grid(grid_obj, direction, amount)
/// @description Scroll the grid contents in specified direction
function mode1_scroll_grid(grid_obj, direction, amount) {
    if (!instance_exists(grid_obj)) return;

    // Use the grid's real dimensions (not fixed 40x25)
    var cols = grid_obj.grid_cols;
    var rows = grid_obj.grid_rows;

    // Clamp by axis to avoid over/underflow in loops
    var amt_row = clamp(amount, 1, rows);
    var amt_col = clamp(amount, 1, cols);

    if (dbg_on(DBG_FLOW)) show_debug_message("GRID SCROLL: " + string_upper(direction) + " by " + string(amount));

    with (grid_obj) {
        switch (string_upper(direction)) {
            case "UP":
                // Move all rows up, fill bottom with spaces (preserve fg/bg)
                for (var row = 0; row < rows - amt_row; row++) {
                    for (var col = 0; col < cols; col++) {
                        var src_i = col + (row + amt_row) * cols;
                        var dst_i = col + row * cols;
                        grid[dst_i] = grid[src_i];
                    }
                }
                // Clear bottom rows to spaces only (keep existing colors)
                for (var row = rows - amt_row; row < rows; row++) {
                    for (var col = 0; col < cols; col++) {
                        // set char=32, preserve fg/bg
                        mode1_grid_set(col, row, 32, undefined, undefined);
                    }
                }
                break;

            case "DOWN":
                // Move all rows down, fill top with spaces (preserve fg/bg)
                for (var row = rows - 1; row >= amt_row; row--) {
                    for (var col = 0; col < cols; col++) {
                        var src_i = col + (row - amt_row) * cols;
                        var dst_i = col + row * cols;
                        grid[dst_i] = grid[src_i];
                    }
                }
                // Clear top rows
                for (var row = 0; row < amt_row; row++) {
                    for (var col = 0; col < cols; col++) {
                        mode1_grid_set(col, row, 32, undefined, undefined);
                    }
                }
                break;

            case "LEFT":
                // Move all columns left, fill right with spaces (preserve fg/bg)
                for (var row = 0; row < rows; row++) {
                    for (var col = 0; col < cols - amt_col; col++) {
                        var src_i = (col + amt_col) + row * cols;
                        var dst_i = col + row * cols;
                        grid[dst_i] = grid[src_i];
                    }
                    // Clear right columns
                    for (var col = cols - amt_col; col < cols; col++) {
                        mode1_grid_set(col, row, 32, undefined, undefined);
                    }
                }
                break;

            case "RIGHT":
                // Move all columns right, fill left with spaces (preserve fg/bg)
                for (var row = 0; row < rows; row++) {
                    for (var col = cols - 1; col >= amt_col; col--) {
                        var src_i = (col - amt_col) + row * cols;
                        var dst_i = col + row * cols;
                        grid[dst_i] = grid[src_i];
                    }
                    // Clear left columns
                    for (var col = 0; col < amt_col; col++) {
                        mode1_grid_set(col, row, 32, undefined, undefined);
                    }
                }
                break;

            default:
                if (dbg_on(DBG_FLOW)) show_debug_message("SCROLL: Unknown direction: " + string(direction));
                break;
        }

        // Ensure a repaint after bulk copies
        needs_redraw = true;
    }
}
