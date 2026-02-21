/// MODE 1 COMMAND
// FILE: scripts/mode1_grid_clear.gml
// FUNCTION: mode1_grid_clear(char_index)
// CHANGE: Remove 15x18 constants; iterate over actual grid

/// @param char_index
function mode1_grid_clear(char_index) {
    var cols = grid_cols;
    var rows = grid_rows;

    for (var row = 0; row < rows; row++) {
        for (var col = 0; col < cols; col++) {
            var i = row * cols + col;
            grid[i].char = char_index;
            grid[i].fg = c_white;
            grid[i].bg = c_black;
        }
    }
}
