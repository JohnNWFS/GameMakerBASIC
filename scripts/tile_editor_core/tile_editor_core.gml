/// Tile editor helpers — shared by obj_tile_editor and BASIC tile commands.

#macro TILE_EDITOR_DEFAULT_SIZE 16

function tile_editor_color_names() {
    return ["WHITE", "YELLOW", "CYAN", "GREEN", "RED", "MAGENTA", "BLUE", "ORANGE", "LIME", "BLACK"];
}

function tile_editor_color_at(_index) {
    basic_colors_ensure();
    var names = tile_editor_color_names();
    var idx = ((floor(_index) mod array_length(names)) + array_length(names)) mod array_length(names);
    var key = names[idx];
    if (variable_struct_exists(global.colors, key)) return global.colors[$ key];
    return c_white;
}

function tile_editor_color_name_at(_index) {
    var names = tile_editor_color_names();
    var idx = ((floor(_index) mod array_length(names)) + array_length(names)) mod array_length(names);
    return names[idx];
}

function tile_editor_prepare_code(_code, _w, _h) {
    var def = custom_tile_get_def(_code);
    if (is_undefined(def)) {
        custom_tile_define(_code, _w, _h);
    }
    return custom_tile_get_def(_code);
}

function tile_editor_flip_h(_code) {
    var def = custom_tile_get_def(_code);
    if (is_undefined(def)) return false;
    var out = "";
    for (var py = 0; py < def.h; py++) {
        for (var px = def.w - 1; px >= 0; px--) {
            var idx = px + py * def.w + 1;
            out += string_char_at(def.bits, idx);
        }
    }
    def.bits = out;
    global.custom_tile_defs[? string(floor(_code))] = def;
    return true;
}

function tile_editor_flip_v(_code) {
    var def = custom_tile_get_def(_code);
    if (is_undefined(def)) return false;
    var out = "";
    for (var py = def.h - 1; py >= 0; py--) {
        for (var px = 0; px < def.w; px++) {
            var idx = px + py * def.w + 1;
            out += string_char_at(def.bits, idx);
        }
    }
    def.bits = out;
    global.custom_tile_defs[? string(floor(_code))] = def;
    return true;
}

function tile_editor_list_nwtile_files() {
    var save_dir = get_save_directory();
    if (!is_string(save_dir) || string_length(save_dir) == 0) save_dir = working_directory;
    if (!directory_exists(save_dir)) directory_create(save_dir);

    var listing = [];
    var mask = save_dir + "*.nwtile";
    var fname = file_find_first(mask, 0);
    while (fname != "") {
        array_push(listing, fname);
        fname = file_find_next();
    }
    file_find_close();
    return listing;
}

function tile_editor_snapshot_bits(_code) {
    var def = custom_tile_get_def(_code);
    if (is_undefined(def)) return { ok: false, w: 0, h: 0, bits: "" };
    return { ok: true, w: def.w, h: def.h, bits: def.bits };
}

function tile_editor_apply_bits(_code, _w, _h, _bits) {
    __custom_tile_ensure_map();
    var key = string(floor(_code));
    var expected = _w * _h;
    var bits = _bits;
    while (string_length(bits) < expected) bits += "0";
    if (string_length(bits) > expected) bits = string_copy(bits, 1, expected);
    global.custom_tile_defs[? key] = { w: _w, h: _h, bits: bits };
    return true;
}

function tile_editor_filter_filename_chars(_new_chars) {
    var filtered = "";
    for (var i = 1; i <= string_length(_new_chars); i++) {
        var ch = string_char_at(_new_chars, i);
        var cc = ord(ch);
        if ((cc >= 48 && cc <= 57) || (cc >= 65 && cc <= 90) || (cc >= 97 && cc <= 122)
         || ch == "_" || ch == "-" || ch == ".") {
            filtered += ch;
        }
    }
    return filtered;
}

function tile_editor_nwtile_stem(_fname) {
    var s = string_trim(_fname);
    var dot = string_pos(".", s);
    if (dot > 1) s = string_copy(s, 1, dot - 1);
    return s;
}

function tile_editor_grid_layout(_tile_w, _tile_h, _margin) {
    var header_h = 36;
    var avail_w = room_width - _margin * 2 - 220;
    var avail_h = room_height - _margin * 2 - header_h - 80;
    var zoom = floor(min(avail_w / _tile_w, avail_h / _tile_h));
    zoom = clamp(zoom, 8, 32);
    var grid_top = _margin + header_h;
    return {
        margin: _margin,
        header_h: header_h,
        grid_top: grid_top,
        zoom: zoom,
        grid_w: _tile_w * zoom,
        grid_h: _tile_h * zoom,
        preview_x: _margin + _tile_w * zoom + 32,
        preview_y: grid_top,
        preview_cell: max(16, min(64, zoom * 2))
    };
}