/// MODE 1 COMMAND
/// @function mode1_get_char(col, row)
/// @description Get character at grid position
function mode1_get_char(col, row) {
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) return 32;
    
    var cols = grid_obj.grid_cols;
    var rows = grid_obj.grid_rows;
    
    if (col < 0 || col >= cols || row < 0 || row >= rows) {
        return 32; // Return space for out of bounds
    }
    
    var i = col + row * cols;
    return grid_obj.grid[i].char;
}
