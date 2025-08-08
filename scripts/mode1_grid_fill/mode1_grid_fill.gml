
/// @param char_index
/// @param fg_color
/// @param bg_color
function mode1_grid_fill(char_index, fg_color, bg_color) {
    for (var i = 0; i < array_length(grid); i++) {
        grid[i].char = char_index;
        grid[i].fg = fg_color;
        grid[i].bg = bg_color;
    }
}
