/// MODE 1 COMMAND
/// @function mode1_get_color(col, row)
/// @description Get foreground color at grid position
function mode1_get_color(col, row) {
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) return c_white;
    if (!mode1_grid_in_bounds(grid_obj, col, row)) return c_white;
    return grid_obj.grid[col][row].fg;
}