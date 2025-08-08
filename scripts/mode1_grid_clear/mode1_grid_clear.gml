
/// @param char_index
function mode1_grid_clear(char_index) {
    var grid_cols = 15;
    var grid_rows = 18;

    for (var row = 0; row < grid_rows; row++) {
        for (var col = 0; col < grid_cols; col++) {
            var i = row * grid_cols + col;
            grid[i].char = char_index;
            grid[i].fg = c_white;
            grid[i].bg = c_black;
        }
    }
}
