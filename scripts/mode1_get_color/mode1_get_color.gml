/// @function mode1_get_color(col, row)
/// @description Get foreground color at grid position  
function mode1_get_color(col, row) {
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) return c_white;
    
    var cols = 40;
    var rows = 25;
    
    if (col < 0 || col >= cols || row < 0 || row >= rows) {
        return c_white; // Return white for out of bounds
    }
    
    var i = col + row * cols;
    return grid_obj.grid[i].fg;
}