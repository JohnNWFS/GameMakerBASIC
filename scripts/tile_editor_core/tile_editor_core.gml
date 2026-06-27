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

function tile_editor_grid_layout(_tile_w, _tile_h, _margin) {
    var avail_w = room_width - _margin * 2 - 220;
    var avail_h = room_height - _margin * 2 - 96;
    var zoom = floor(min(avail_w / _tile_w, avail_h / _tile_h));
    zoom = clamp(zoom, 8, 32);
    return {
        margin: _margin,
        zoom: zoom,
        grid_w: _tile_w * zoom,
        grid_h: _tile_h * zoom,
        preview_x: _margin + _tile_w * zoom + 32,
        preview_y: _margin + 8,
        preview_cell: max(16, min(64, zoom * 2))
    };
}