/// MODE 1 COMMAND
/// @param char_index
function mode1_grid_clear(char_index) {
    for (var row = 0; row < grid_rows; row++) {
        for (var col = 0; col < grid_cols; col++) {
            grid[col][row].char = char_index;
            grid[col][row].fg = c_white;
            grid[col][row].bg = c_black;
        }
    }
}