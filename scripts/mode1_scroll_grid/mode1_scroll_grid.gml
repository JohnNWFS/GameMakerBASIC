/// @function mode1_scroll_grid(grid_obj, direction, amount)
/// @description Scroll the grid contents in specified direction
function mode1_scroll_grid(grid_obj, direction, amount) {
    if (!instance_exists(grid_obj)) return;
    
    var cols = 40;
    var rows = 25;
    amount = clamp(amount, 1, rows);
    
    if (dbg_on(DBG_FLOW)) show_debug_message("GRID SCROLL: " + direction + " by " + string(amount));
    
    with (grid_obj) {
        switch (string_upper(direction)) {
            case "UP":
                // Move all rows up, fill bottom with spaces
                for (var row = 0; row < rows - amount; row++) {
                    for (var col = 0; col < cols; col++) {
                        var src_i = col + (row + amount) * cols;
                        var dst_i = col + row * cols;
                        grid[dst_i] = grid[src_i];
                    }
                }
                // Clear bottom rows
                for (var row = rows - amount; row < rows; row++) {
                    for (var col = 0; col < cols; col++) {
                        var i = col + row * cols;
                        grid[i] = { char: 32, fg: c_white, bg: c_black };
                    }
                }
                break;
                
            case "DOWN":
                // Move all rows down, fill top with spaces
                for (var row = rows - 1; row >= amount; row--) {
                    for (var col = 0; col < cols; col++) {
                        var src_i = col + (row - amount) * cols;
                        var dst_i = col + row * cols;
                        grid[dst_i] = grid[src_i];
                    }
                }
                // Clear top rows
                for (var row = 0; row < amount; row++) {
                    for (var col = 0; col < cols; col++) {
                        var i = col + row * cols;
                        grid[i] = { char: 32, fg: c_white, bg: c_black };
                    }
                }
                break;
                
            case "LEFT":
                // Move all columns left, fill right with spaces
                for (var row = 0; row < rows; row++) {
                    for (var col = 0; col < cols - amount; col++) {
                        var src_i = (col + amount) + row * cols;
                        var dst_i = col + row * cols;
                        grid[dst_i] = grid[src_i];
                    }
                    // Clear right columns
                    for (var col = cols - amount; col < cols; col++) {
                        var i = col + row * cols;
                        grid[i] = { char: 32, fg: c_white, bg: c_black };
                    }
                }
                break;
                
            case "RIGHT":
                // Move all columns right, fill left with spaces
                for (var row = 0; row < rows; row++) {
                    for (var col = cols - 1; col >= amount; col--) {
                        var src_i = (col - amount) + row * cols;
                        var dst_i = col + row * cols;
                        grid[dst_i] = grid[src_i];
                    }
                    // Clear left columns
                    for (var col = 0; col < amount; col++) {
                        var i = col + row * cols;
                        grid[i] = { char: 32, fg: c_white, bg: c_black };
                    }
                }
                break;
                
            default:
                if (dbg_on(DBG_FLOW)) show_debug_message("SCROLL: Unknown direction: " + direction);
                break;
        }
    }
}