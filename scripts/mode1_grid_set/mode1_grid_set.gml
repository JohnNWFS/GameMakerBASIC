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

    cell.char = mode1_ascii_fallback_code(_char);
    if (!is_undefined(_fg)) cell.fg = _fg;      // PRESERVE if undefined
    if (!is_undefined(_bg)) cell.bg = _bg;      // PRESERVE if undefined

    grid_obj.grid[idx] = cell;
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
