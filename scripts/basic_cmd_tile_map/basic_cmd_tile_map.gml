/// MODE 2 tile map layer — large maps blitted to the display grid.

function __tile_map_ensure_store() {
    if (!variable_global_exists("tile_maps") || !ds_exists(global.tile_maps, ds_type_map)) {
        global.tile_maps = ds_map_create();
    }
    if (!variable_global_exists("active_tile_map_name")) {
        global.active_tile_map_name = "";
    }
}

function tile_map_resolve_path(_fname) {
    var fname = string_trim(_fname);
    if (string_length(fname) <= 0) fname = "map.nwmap";
    if (string_pos(".", fname) <= 0) fname += ".nwmap";
    return get_save_directory() + fname;
}

function tile_map_create(_name, _w, _h, _char, _fg, _bg) {
    __tile_map_ensure_store();
    _w = clamp(floor(_w), 1, 256);
    _h = clamp(floor(_h), 1, 256);
    _char = mode1_ascii_fallback_code(_char);

    var cells = array_create(_w, _h);
    for (var col = 0; col < _w; col++) {
        for (var row = 0; row < _h; row++) {
            cells[col][row] = { char: _char, fg: _fg, bg: _bg };
        }
    }

    var map = {
        name: _name,
        w: _w,
        h: _h,
        def_char: _char,
        def_fg: _fg,
        def_bg: _bg,
        cells: cells
    };
    global.tile_maps[? _name] = map;
    global.active_tile_map_name = _name;
    return map;
}

function tile_map_get(_name) {
    __tile_map_ensure_store();
    if (!ds_map_exists(global.tile_maps, _name)) return undefined;
    return global.tile_maps[? _name];
}

function tile_map_get_active() {
    __tile_map_ensure_store();
    if (global.active_tile_map_name == "") return undefined;
    return tile_map_get(global.active_tile_map_name);
}

function tile_map_set_cell(_name, _x, _y, _char, _fg, _bg) {
    var map = tile_map_get(_name);
    if (is_undefined(map)) return false;
    if (_x < 0 || _y < 0 || _x >= map.w || _y >= map.h) return false;

    var cell = map.cells[_x][_y];
    cell.char = mode1_ascii_fallback_code(_char);
    if (!is_undefined(_fg)) cell.fg = _fg;
    if (!is_undefined(_bg)) cell.bg = _bg;
    map.cells[_x][_y] = cell;
    global.tile_maps[? _name] = map;
    return true;
}

function tile_map_blit_to_grid(_name, _dest_col, _dest_row) {
    if (global.current_mode != 2) return false;
    var map = tile_map_get(_name);
    if (is_undefined(map)) return false;

    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) return false;

    with (grid_obj) {
        for (var my = 0; my < map.h; my++) {
            var gy = _dest_row + my;
            if (gy < 0 || gy >= grid_rows) continue;
            for (var mx = 0; mx < map.w; mx++) {
                var gx = _dest_col + mx;
                if (gx < 0 || gx >= grid_cols) continue;
                var src = map.cells[mx][my];
                grid[gx][gy] = { char: src.char, fg: src.fg, bg: src.bg };
            }
        }
        needs_redraw = true;
    }
    dbg_log(DBG_FLOW, "MAPDRAW: map=" + _name + " at (" + string(_dest_col) + "," + string(_dest_row)
        + ") size=" + string(map.w) + "x" + string(map.h));
    return true;
}

function tile_map_save_file(_fname, _name) {
    var map = tile_map_get(_name);
    if (is_undefined(map)) return false;

    var path = tile_map_resolve_path(_fname);
    var save_dir = get_save_directory();
    if (!directory_exists(save_dir)) directory_create(save_dir);

    var fh = file_text_open_write(path);
    if (fh < 0) return false;

    file_text_write_string(fh, "NWMAP1");
    file_text_writeln(fh);
    file_text_write_string(fh, "NAME," + map.name);
    file_text_writeln(fh);
    file_text_write_string(fh, "SIZE," + string(map.w) + "," + string(map.h));
    file_text_writeln(fh);
    file_text_write_string(fh, "DEF," + string(map.def_char) + "," + string(map.def_fg) + "," + string(map.def_bg));
    file_text_writeln(fh);

    for (var row = 0; row < map.h; row++) {
        var line = "ROW," + string(row);
        for (var col = 0; col < map.w; col++) {
            var cell = map.cells[col][row];
            line += "," + string(cell.char) + "," + string(cell.fg) + "," + string(cell.bg);
        }
        file_text_write_string(fh, line);
        file_text_writeln(fh);
    }

    file_text_write_string(fh, "END");
    file_text_writeln(fh);
    file_text_close(fh);
    dbg_log(DBG_FLOW, "MAPSAVE: " + path);
    return true;
}

function tile_map_load_file(_fname) {
    var path = tile_map_resolve_path(_fname);
    if (!file_exists(path)) return false;

    var fh = file_text_open_read(path);
    if (fh < 0) return false;

    var name = "map";
    var mw = 0;
    var mh = 0;
    var def_char = 32;
    var def_fg = c_white;
    var def_bg = c_black;
    var cells = undefined;
    var got_size = false;

    while (!file_text_eof(fh)) {
        var line = string_trim(file_text_readln(fh));
        if (line == "" || line == "NWMAP1" || line == "END") continue;

        var parts = string_split(line, ",");
        var tag = string_upper(string_trim(parts[0]));

        if (tag == "NAME" && array_length(parts) >= 2) {
            name = string_trim(parts[1]);
        } else if (tag == "SIZE" && array_length(parts) >= 3) {
            if (is_numeric_string(string_trim(parts[1])) && is_numeric_string(string_trim(parts[2]))) {
                mw = clamp(floor(real(string_trim(parts[1]))), 1, 256);
                mh = clamp(floor(real(string_trim(parts[2]))), 1, 256);
                cells = array_create(mw, mh);
                for (var c0 = 0; c0 < mw; c0++) {
                    for (var r0 = 0; r0 < mh; r0++) {
                        cells[c0][r0] = { char: def_char, fg: def_fg, bg: def_bg };
                    }
                }
                got_size = true;
            }
        } else if (tag == "DEF" && array_length(parts) >= 4) {
            if (is_numeric_string(string_trim(parts[1]))) {
                def_char = floor(real(string_trim(parts[1])));
            }
            if (is_numeric_string(string_trim(parts[2]))) def_fg = floor(real(string_trim(parts[2])));
            else def_fg = basic_parse_color(string_trim(parts[2]), c_white);
            if (is_numeric_string(string_trim(parts[3]))) def_bg = floor(real(string_trim(parts[3])));
            else def_bg = basic_parse_color(string_trim(parts[3]), c_black);
        } else if (tag == "ROW" && got_size && array_length(parts) >= 2) {
            if (!is_numeric_string(string_trim(parts[1]))) continue;
            var row = floor(real(string_trim(parts[1])));
            if (row < 0 || row >= mh) continue;

            var idx = 2;
            while (idx + 2 < array_length(parts)) {
                var col = (idx - 2) div 3;
                if (col >= mw) break;
                if (!is_numeric_string(string_trim(parts[idx]))) break;
                var ch = floor(real(string_trim(parts[idx])));
                var fg = c_white;
                var bg = c_black;
                if (is_numeric_string(string_trim(parts[idx + 1]))) fg = floor(real(string_trim(parts[idx + 1])));
                else fg = basic_parse_color(string_trim(parts[idx + 1]), c_white);
                if (is_numeric_string(string_trim(parts[idx + 2]))) bg = floor(real(string_trim(parts[idx + 2])));
                else bg = basic_parse_color(string_trim(parts[idx + 2]), c_black);
                cells[col][row] = { char: ch, fg: fg, bg: bg };
                idx += 3;
            }
        }
    }

    file_text_close(fh);
    if (!got_size || is_undefined(cells)) return false;

    __tile_map_ensure_store();
    global.tile_maps[? name] = {
        name: name,
        w: mw,
        h: mh,
        def_char: def_char,
        def_fg: def_fg,
        def_bg: def_bg,
        cells: cells
    };
    global.active_tile_map_name = name;
    dbg_log(DBG_FLOW, "MAPLOAD: " + path + " (" + string(mw) + "x" + string(mh) + ")");
    return true;
}

function basic_cmd_mapnew(arg) {
    if (global.current_mode != 2) {
        dbg_log(DBG_FLOW, "MAPNEW: only available in MODE 2 tile graphics");
        return;
    }

    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "MAPNEW", 2, 3, "w,h[,name]")) return;

    var w_arg = basic_eval_int_arg(args[0], "MAPNEW", "w");
    var h_arg = basic_eval_int_arg(args[1], "MAPNEW", "h");
    if (!w_arg.ok || !h_arg.ok) return;

    var name = "map";
    if (array_length(args) >= 3) {
        name = string_trim(string(basic_evaluate_expression_v2(string_trim(args[2]))));
        if (string_length(name) <= 0) name = "map";
    }

    tile_map_create(name, w_arg.value, h_arg.value, 32, c_white, c_black);
}

function basic_cmd_mapload(arg) {
    if (global.current_mode != 2) {
        dbg_log(DBG_FLOW, "MAPLOAD: only available in MODE 2 tile graphics");
        return;
    }

    var fname = string(basic_evaluate_expression_v2(string_trim(arg)));
    if (!tile_map_load_file(fname)) {
        basic_syntax_error("MAPLOAD missing file", global.current_line_number, 0, "MAPLOAD_MISSING");
    }
}

function basic_cmd_mapsave(arg) {
    if (global.current_mode != 2) {
        dbg_log(DBG_FLOW, "MAPSAVE: only available in MODE 2 tile graphics");
        return;
    }

    var fname = string(basic_evaluate_expression_v2(string_trim(arg)));
    var name = global.active_tile_map_name;
    if (name == "") {
        basic_syntax_error("MAPSAVE: no active map", global.current_line_number, 0, "MAPSAVE_NOMAP");
        return;
    }
    if (!tile_map_save_file(fname, name)) {
        basic_syntax_error("MAPSAVE failed", global.current_line_number, 0, "MAPSAVE_FAILED");
    }
}

function basic_cmd_mapset(arg) {
    if (global.current_mode != 2) {
        dbg_log(DBG_FLOW, "MAPSET: only available in MODE 2 tile graphics");
        return;
    }

    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "MAPSET", 3, 5, "x,y,code[,fg[,bg]]")) return;

    var x_arg = basic_eval_int_arg(args[0], "MAPSET", "x");
    var y_arg = basic_eval_int_arg(args[1], "MAPSET", "y");
    var ch_arg = basic_eval_int_arg(args[2], "MAPSET", "code");
    if (!x_arg.ok || !y_arg.ok || !ch_arg.ok) return;

    var fg = (array_length(args) > 3) ? basic_parse_color(string_trim(args[3])) : undefined;
    var bg = (array_length(args) > 4) ? basic_parse_color(string_trim(args[4])) : undefined;

    var name = global.active_tile_map_name;
    if (name == "") {
        basic_syntax_error("MAPSET: no active map (use MAPNEW or MAPLOAD)", global.current_line_number, 0, "MAPSET_NOMAP");
        return;
    }
    tile_map_set_cell(name, x_arg.value, y_arg.value, ch_arg.value, fg, bg);
}

function basic_cmd_mapdraw(arg) {
    if (global.current_mode != 2) {
        dbg_log(DBG_FLOW, "MAPDRAW: only available in MODE 2 tile graphics");
        return;
    }

    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "MAPDRAW", 0, 3, "[col,row[,name]]")) return;

    var dest_col = 0;
    var dest_row = 0;
    var name = global.active_tile_map_name;

    if (array_length(args) >= 1) {
        var cx_arg = basic_eval_int_arg(args[0], "MAPDRAW", "col");
        if (!cx_arg.ok) return;
        dest_col = cx_arg.value;
    }
    if (array_length(args) >= 2) {
        var cy_arg = basic_eval_int_arg(args[1], "MAPDRAW", "row");
        if (!cy_arg.ok) return;
        dest_row = cy_arg.value;
    }
    if (array_length(args) >= 3) {
        name = string_trim(string(basic_evaluate_expression_v2(string_trim(args[2]))));
    }

    if (name == "" || is_undefined(tile_map_get(name))) {
        basic_syntax_error("MAPDRAW: map not found", global.current_line_number, 0, "MAPDRAW_NOMAP");
        return;
    }
    if (!tile_map_blit_to_grid(name, dest_col, dest_row)) {
        basic_syntax_error("MAPDRAW failed", global.current_line_number, 0, "MAPDRAW_FAILED");
    }
}