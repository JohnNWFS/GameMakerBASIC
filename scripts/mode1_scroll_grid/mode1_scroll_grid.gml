/// MODE 1 COMMAND
/// @function mode1_scroll_grid(grid_obj, direction, amount)
/// @description Scroll the grid contents in specified direction
function mode1_scroll_grid(grid_obj, direction, amount) {
    if (!instance_exists(grid_obj)) return;

    var cols = grid_obj.grid_cols;
    var rows = grid_obj.grid_rows;

    var amt_row = clamp(amount, 1, rows);
    var amt_col = clamp(amount, 1, cols);

    dbg_log(DBG_FLOW, "GRID SCROLL: " + string_upper(direction) + " by " + string(amount));

    with (grid_obj) {
        switch (string_upper(direction)) {
            case "UP":
                for (var row = 0; row < rows - amt_row; row++) {
                    for (var col = 0; col < cols; col++) {
                        var _s = grid[col][row + amt_row];
                        grid[col][row] = { char: _s.char, fg: _s.fg, bg: _s.bg };
                    }
                }
                for (var row = rows - amt_row; row < rows; row++) {
                    for (var col = 0; col < cols; col++) {
                        mode1_grid_set(col, row, 32, undefined, undefined);
                    }
                }
                break;

            case "DOWN":
                for (var row = rows - 1; row >= amt_row; row--) {
                    for (var col = 0; col < cols; col++) {
                        var _s = grid[col][row - amt_row];
                        grid[col][row] = { char: _s.char, fg: _s.fg, bg: _s.bg };
                    }
                }
                for (var row = 0; row < amt_row; row++) {
                    for (var col = 0; col < cols; col++) {
                        mode1_grid_set(col, row, 32, undefined, undefined);
                    }
                }
                break;

            case "LEFT":
                for (var row = 0; row < rows; row++) {
                    for (var col = 0; col < cols - amt_col; col++) {
                        var _s = grid[col + amt_col][row];
                        grid[col][row] = { char: _s.char, fg: _s.fg, bg: _s.bg };
                    }
                    for (var col = cols - amt_col; col < cols; col++) {
                        mode1_grid_set(col, row, 32, undefined, undefined);
                    }
                }
                break;

            case "RIGHT":
                for (var row = 0; row < rows; row++) {
                    for (var col = cols - 1; col >= amt_col; col--) {
                        var _s = grid[col - amt_col][row];
                        grid[col][row] = { char: _s.char, fg: _s.fg, bg: _s.bg };
                    }
                    for (var col = 0; col < amt_col; col++) {
                        mode1_grid_set(col, row, 32, undefined, undefined);
                    }
                }
                break;

            default:
                dbg_log(DBG_FLOW, "SCROLL: Unknown direction: " + string(direction));
                break;
        }

        needs_redraw = true;
    }
}