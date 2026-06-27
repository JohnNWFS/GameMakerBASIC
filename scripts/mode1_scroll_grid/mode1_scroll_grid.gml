/// MODE 1 COMMAND
/// @function mode1_scroll_grid(grid_obj, direction, amount)
/// @description Scroll the grid contents in specified direction (viewport-aware).
function mode1_scroll_grid(grid_obj, direction, amount) {
    if (!instance_exists(grid_obj)) return;

    var cols = grid_obj.grid_cols;
    var rows = grid_obj.grid_rows;

    var vx = 0;
    var vy = 0;
    var vw = cols;
    var vh = rows;
    if (mode1_view_active()) {
        var v = global.mode2_view;
        vx = v.x;
        vy = v.y;
        vw = v.w;
        vh = v.h;
    }

    var amt_row = clamp(amount, 1, vh);
    var amt_col = clamp(amount, 1, vw);

    dbg_log(DBG_FLOW, "GRID SCROLL: " + string_upper(direction) + " by " + string(amount));

    with (grid_obj) {
        switch (string_upper(direction)) {
            case "UP":
                for (var row = vy; row < vy + vh - amt_row; row++) {
                    for (var col = vx; col < vx + vw; col++) {
                        var _s = grid[col][row + amt_row];
                        grid[col][row] = { char: _s.char, fg: _s.fg, bg: _s.bg };
                    }
                }
                for (var row = vy + vh - amt_row; row < vy + vh; row++) {
                    for (var col = vx; col < vx + vw; col++) {
                        mode1_grid_set(col, row, 32, undefined, undefined);
                    }
                }
                break;

            case "DOWN":
                for (var row = vy + vh - 1; row >= vy + amt_row; row--) {
                    for (var col = vx; col < vx + vw; col++) {
                        var _s = grid[col][row - amt_row];
                        grid[col][row] = { char: _s.char, fg: _s.fg, bg: _s.bg };
                    }
                }
                for (var row = vy; row < vy + amt_row; row++) {
                    for (var col = vx; col < vx + vw; col++) {
                        mode1_grid_set(col, row, 32, undefined, undefined);
                    }
                }
                break;

            case "LEFT":
                for (var row = vy; row < vy + vh; row++) {
                    for (var col = vx; col < vx + vw - amt_col; col++) {
                        var _s = grid[col + amt_col][row];
                        grid[col][row] = { char: _s.char, fg: _s.fg, bg: _s.bg };
                    }
                    for (var col = vx + vw - amt_col; col < vx + vw; col++) {
                        mode1_grid_set(col, row, 32, undefined, undefined);
                    }
                }
                break;

            case "RIGHT":
                for (var row = vy; row < vy + vh; row++) {
                    for (var col = vx + vw - 1; col >= vx + amt_col; col--) {
                        var _s = grid[col - amt_col][row];
                        grid[col][row] = { char: _s.char, fg: _s.fg, bg: _s.bg };
                    }
                    for (var col = vx; col < vx + amt_col; col++) {
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