/// Allocate a 2D native GML grid of tile structs.
function mode1_grid_alloc(_cols, _rows, _char = 32, _fg = c_white, _bg = c_black) {
    var g = array_create(_cols, _rows);
    for (var col = 0; col < _cols; col++) {
        for (var row = 0; row < _rows; row++) {
            g[col][row] = { char: _char, fg: _fg, bg: _bg };
        }
    }
    return g;
}

function mode1_grid_in_bounds(_grid_obj, _x, _y) {
    return (_x >= 0 && _x < _grid_obj.grid_cols && _y >= 0 && _y < _grid_obj.grid_rows);
}

function mode1_grid_fill_all(_grid_obj, _char, _fg, _bg) {
    if (!instance_exists(_grid_obj)) return;
    with (_grid_obj) {
        for (var row = 0; row < grid_rows; row++) {
            for (var col = 0; col < grid_cols; col++) {
                grid[col][row].char = _char;
                grid[col][row].fg = _fg;
                grid[col][row].bg = _bg;
            }
        }
        needs_redraw = true;
    }
}

/// MODE 1 COMMAND
/// @function mode1_grid_set(x, y, ch, [fg], [bg])
/// @desc Update a grid cell; preserve fg/bg if the arg is undefined.
function mode1_grid_set(_x, _y, _char, _fg, _bg) {
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) return;
    if (!mode1_grid_in_bounds(grid_obj, _x, _y)) return;

    var cell = grid_obj.grid[_x][_y];
    cell.char = mode1_ascii_fallback_code(_char);
    if (!is_undefined(_fg)) cell.fg = _fg;
    if (!is_undefined(_bg)) cell.bg = _bg;
    grid_obj.grid[_x][_y] = cell;
    grid_obj.needs_redraw = true;
}

function mode1_ascii_fallback_text(_text) {
    var s = string(_text);

    s = string_replace_all(s, "—", "-");
    s = string_replace_all(s, "–", "-");
    s = string_replace_all(s, "―", "-");
    s = string_replace_all(s, "−", "-");

    s = string_replace_all(s, "“", "\"");
    s = string_replace_all(s, "”", "\"");
    s = string_replace_all(s, "„", "\"");
    s = string_replace_all(s, "‟", "\"");

    s = string_replace_all(s, "‘", "'");
    s = string_replace_all(s, "’", "'");
    s = string_replace_all(s, "‚", "'");
    s = string_replace_all(s, "‛", "'");

    s = string_replace_all(s, "…", "...");
    s = string_replace_all(s, "•", "*");
    s = string_replace_all(s, "·", ".");
    s = string_replace_all(s, " ", " ");

    s = string_replace_all(s, "©", "(c)");
    s = string_replace_all(s, "®", "(R)");
    s = string_replace_all(s, "™", "TM");

    return s;
}

function mode1_ascii_fallback_code(_char) {
    var code = _char;
    if (!is_real(code)) {
        var s = mode1_ascii_fallback_text(string(code));
        code = (string_length(s) > 0) ? ord(string_char_at(s, 1)) : 32;
    }

    switch (code) {
        case 8211: // en dash
        case 8212: // em dash
        case 8213: // horizontal bar
        case 8722: // minus sign
            return ord("-");

        case 8220: // left double quote
        case 8221: // right double quote
        case 8222: // low double quote
        case 8223: // reversed double quote
            return ord("\"");

        case 8216: // left single quote
        case 8217: // right single quote
        case 8218: // low single quote
        case 8219: // reversed single quote
            return ord("'");

        case 8230: return ord("."); // ellipsis; string path expands to "..."
        case 8226: return ord("*"); // bullet
        case 183:  return ord("."); // middle dot
        case 160:  return ord(" "); // non-breaking space
        case 169:  return ord("c"); // copyright; string path expands to "(c)"
        case 174:  return ord("R"); // registered; string path expands to "(R)"
        case 8482: return ord("T"); // trademark; string path expands to "TM"
    }

    if (code < 0 || code > 255) return ord("?");
    return code;
}
