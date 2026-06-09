/// MODE 2 CUSTOM TILE COMMANDS
/// @desc Editable bitmap masks for tile codes. Standard font glyphs remain the fallback.

function __custom_tile_ensure_map() {
    if (!variable_global_exists("custom_tile_defs") || !ds_exists(global.custom_tile_defs, ds_type_map)) {
        global.custom_tile_defs = ds_map_create();
    }
}

function __custom_tile_blank_bits(tile_w, tile_h) {
    var bits = "";
    var count = max(0, tile_w * tile_h);
    for (var bi = 0; bi < count; bi++) bits += "0";
    return bits;
}

function __custom_tile_eval_filename(expr) {
    var fname = string(basic_evaluate_expression_v2(string_trim(expr)));
    if (string_length(fname) <= 0) fname = "tiles.nwtile";
    if (string_pos(".", fname) <= 0) fname += ".nwtile";
    return get_save_directory() + fname;
}

function custom_tile_get_def(tile_code) {
    __custom_tile_ensure_map();
    if (!is_real(tile_code) && !is_numeric_string(string_trim(string(tile_code)))) return undefined;
    var key = string(floor(is_real(tile_code) ? tile_code : real(string_trim(string(tile_code)))));
    if (!ds_map_exists(global.custom_tile_defs, key)) return undefined;
    return global.custom_tile_defs[? key];
}

function custom_tile_get_bit(tile_code, bit_x, bit_y) {
    var def = custom_tile_get_def(tile_code);
    if (is_undefined(def)) return 0;

    if (!is_real(bit_x) && !is_numeric_string(string_trim(string(bit_x)))) return 0;
    if (!is_real(bit_y) && !is_numeric_string(string_trim(string(bit_y)))) return 0;
    var tile_x = floor(is_real(bit_x) ? bit_x : real(string_trim(string(bit_x))));
    var tile_y = floor(is_real(bit_y) ? bit_y : real(string_trim(string(bit_y))));
    if (tile_x < 0 || tile_y < 0 || tile_x >= def.w || tile_y >= def.h) return 0;

    var idx = tile_x + tile_y * def.w + 1;
    return (string_char_at(def.bits, idx) == "1") ? 1 : 0;
}

function custom_tile_draw(tile_code, draw_x, draw_y, cell_w, cell_h, draw_color) {
    var def = custom_tile_get_def(tile_code);
    if (is_undefined(def)) return false;

    draw_set_color(draw_color);
    var sx = cell_w / def.w;
    var sy = cell_h / def.h;

    for (var py = 0; py < def.h; py++) {
        for (var px = 0; px < def.w; px++) {
            var idx = px + py * def.w + 1;
            if (string_char_at(def.bits, idx) == "1") {
                draw_rectangle(
                    draw_x + px * sx,
                    draw_y + py * sy,
                    draw_x + (px + 1) * sx,
                    draw_y + (py + 1) * sy,
                    false
                );
            }
        }
    }
    return true;
}

function basic_cmd_tiledef(arg) {
    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "TILEDEF", 1, 3, "code[,w[,h]]")) return;

    __custom_tile_ensure_map();
    var code_arg = basic_eval_int_arg(args[0], "TILEDEF", "code");
    if (!code_arg.ok) return;
    var tile_code = code_arg.value;
    var tile_w = global.mode1_cell_px;
    if (array_length(args) > 1) {
        var w_arg = basic_eval_int_arg(args[1], "TILEDEF", "w");
        if (!w_arg.ok) return;
        tile_w = w_arg.value;
    }
    var tile_h = tile_w;
    if (array_length(args) > 2) {
        var h_arg = basic_eval_int_arg(args[2], "TILEDEF", "h");
        if (!h_arg.ok) return;
        tile_h = h_arg.value;
    }

    tile_w = clamp(tile_w, 1, 64);
    tile_h = clamp(tile_h, 1, 64);

    var key = string(tile_code);
    global.custom_tile_defs[? key] = {
        w: tile_w,
        h: tile_h,
        bits: __custom_tile_blank_bits(tile_w, tile_h)
    };
    dbg_log(DBG_FLOW, "TILEDEF: code=" + key + " size=" + string(tile_w) + "x" + string(tile_h));
}

function basic_cmd_tilepx(arg) {
    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "TILEPX", 3, 4, "code,x,y[,on]")) return;

    __custom_tile_ensure_map();
    var code_arg = basic_eval_int_arg(args[0], "TILEPX", "code");
    var x_arg = basic_eval_int_arg(args[1], "TILEPX", "x");
    var y_arg = basic_eval_int_arg(args[2], "TILEPX", "y");
    if (!code_arg.ok || !x_arg.ok || !y_arg.ok) return;
    var tile_code = code_arg.value;
    var tile_x = x_arg.value;
    var tile_y = y_arg.value;
    var on = true;
    if (array_length(args) > 3) {
        var on_arg = basic_eval_bool_arg(args[3], "TILEPX", "on");
        if (!on_arg.ok) return;
        on = on_arg.value;
    }

    var key = string(tile_code);
    if (!ds_map_exists(global.custom_tile_defs, key)) {
        global.custom_tile_defs[? key] = {
            w: global.mode1_cell_px,
            h: global.mode1_cell_px,
            bits: __custom_tile_blank_bits(global.mode1_cell_px, global.mode1_cell_px)
        };
    }

    var def = global.custom_tile_defs[? key];
    if (tile_x < 0 || tile_y < 0 || tile_x >= def.w || tile_y >= def.h) return;

    var idx = tile_x + tile_y * def.w + 1;
    var left = string_copy(def.bits, 1, idx - 1);
    var right = string_copy(def.bits, idx + 1, string_length(def.bits) - idx);
    def.bits = left + (on ? "1" : "0") + right;
    global.custom_tile_defs[? key] = def;
}

function basic_cmd_tileclear(arg) {
    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "TILECLEAR", 1, 1, "code")) return;

    __custom_tile_ensure_map();
    var code_arg = basic_eval_int_arg(args[0], "TILECLEAR", "code");
    if (!code_arg.ok) return;
    var tile_code = code_arg.value;
    var key = string(tile_code);
    if (!ds_map_exists(global.custom_tile_defs, key)) return;

    var def = global.custom_tile_defs[? key];
    def.bits = __custom_tile_blank_bits(def.w, def.h);
    global.custom_tile_defs[? key] = def;
}

function basic_cmd_tilerestore(arg) {
    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "TILERESTORE", 1, 1, "code")) return;

    __custom_tile_ensure_map();
    var code_arg = basic_eval_int_arg(args[0], "TILERESTORE", "code");
    if (!code_arg.ok) return;
    var tile_code = code_arg.value;
    var key = string(tile_code);
    if (ds_map_exists(global.custom_tile_defs, key)) {
        ds_map_delete(global.custom_tile_defs, key);
    }
    dbg_log(DBG_FLOW, "TILERESTORE: code=" + key);
}

function basic_cmd_tilesave(arg) {
    var path = __custom_tile_eval_filename(arg);
    __custom_tile_ensure_map();

    var fh = file_text_open_write(path);
    if (fh < 0) {
        basic_syntax_error("TILESAVE failed", global.current_line_number, 0, "TILESAVE_FAILED");
        return;
    }

    file_text_write_string(fh, "NWBTILE1");
    file_text_writeln(fh);

    var key = ds_map_find_first(global.custom_tile_defs);
    while (!is_undefined(key)) {
        var def = global.custom_tile_defs[? key];
        file_text_write_string(fh, "TILE," + key + "," + string(def.w) + "," + string(def.h) + "," + def.bits);
        file_text_writeln(fh);
        key = ds_map_find_next(global.custom_tile_defs, key);
    }

    file_text_write_string(fh, "END");
    file_text_writeln(fh);
    file_text_close(fh);
    dbg_log(DBG_FLOW, "TILESAVE: " + path);
}

function basic_cmd_tileload(arg) {
    var path = __custom_tile_eval_filename(arg);
    if (!file_exists(path)) {
        basic_syntax_error("TILELOAD missing file", global.current_line_number, 0, "TILELOAD_MISSING");
        return;
    }

    __custom_tile_ensure_map();
    var fh = file_text_open_read(path);
    if (fh < 0) {
        basic_syntax_error("TILELOAD failed", global.current_line_number, 0, "TILELOAD_FAILED");
        return;
    }

    while (!file_text_eof(fh)) {
        var line = string_trim(file_text_readln(fh));
        if (line == "" || line == "NWBTILE1" || line == "END") continue;

        var parts = string_split(line, ",");
        if (array_length(parts) >= 5 && string_upper(parts[0]) == "TILE") {
            var key = string_trim(parts[1]);
            if (!is_numeric_string(string_trim(parts[2])) || !is_numeric_string(string_trim(parts[3]))) continue;
            var tile_w = clamp(floor(real(string_trim(parts[2]))), 1, 64);
            var tile_h = clamp(floor(real(string_trim(parts[3]))), 1, 64);
            var bits = string_trim(parts[4]);
            var expected = tile_w * tile_h;
            while (string_length(bits) < expected) bits += "0";
            if (string_length(bits) > expected) bits = string_copy(bits, 1, expected);

            global.custom_tile_defs[? key] = {
                w: tile_w,
                h: tile_h,
                bits: bits
            };
        }
    }

    file_text_close(fh);
    dbg_log(DBG_FLOW, "TILELOAD: " + path);
}
