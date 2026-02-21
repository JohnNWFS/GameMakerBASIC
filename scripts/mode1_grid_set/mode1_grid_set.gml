/// MODE 1 COMMAND
/// @function mode1_grid_set(x, y, ch, [fg], [bg])
/// @desc Update a grid cell; preserve fg/bg if the arg is undefined.
function mode1_grid_set(_x, _y, _char, _fg, _bg) {
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) return;

    var cols = grid_obj.grid_cols;
    var rows = grid_obj.grid_rows;
    if (_x < 0 || _x >= cols || _y < 0 || _y >= rows) return;

    var idx  = _x + _y * cols;
    var cell = grid_obj.grid[idx];

    cell.char = _char;
    if (!is_undefined(_fg)) cell.fg = _fg;      // PRESERVE if undefined
    if (!is_undefined(_bg)) cell.bg = _bg;      // PRESERVE if undefined

    grid_obj.grid[idx] = cell;
    grid_obj.needs_redraw = true;
}
