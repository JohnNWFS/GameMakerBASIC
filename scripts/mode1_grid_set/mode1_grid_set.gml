/// @function mode1_grid_set(x, y, ch, fg, bg)
/// @desc Update a grid cell with char + optional fg/bg colors
function mode1_grid_set(_x, _y, _char, _fg, _bg) {
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) return;

    var cols = grid_obj.grid_cols;
    var rows = grid_obj.grid_rows;
    if (_x < 0 || _x >= cols || _y < 0 || _y >= rows) return;

    var idx = _x + _y * cols;
    var cell = grid_obj.grid[idx];

    // Always set the glyph
    cell.char = _char;

    // Only change colors if the caller supplied them
    if (_fg != undefined) cell.fg = _fg;
    if (_bg != undefined) cell.bg = _bg;

    grid_obj.grid[idx] = cell;
}
