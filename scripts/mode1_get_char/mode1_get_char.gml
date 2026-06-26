/// MODE 1 COMMAND
/// @function mode1_get_char(col, row)
/// @description Get character at grid position
function mode1_get_char(col, row) {
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) return 32;
    if (!mode1_grid_in_bounds(grid_obj, col, row)) return 32;
    return grid_obj.grid[col][row].char;
}