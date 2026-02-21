/// MODE 1 COMMAND
/// @function basic_cmd_fontset(arg)
/// @description FONTSET "<registry-key>"
function basic_cmd_fontset(arg) {
    if (global.current_mode < 1) {
        basic_print_system_message("FONTSET not implemented in MODE " + string(global.current_mode));
        return;
    }

    var key = string_upper(string_trim(arg));

    // Strip quotes if present
    if (string_length(key) >= 2) {
        var first = string_char_at(key, 1);
        var last  = string_char_at(key, string_length(key));
        if ((first == "\"" || first == "'") && first == last) {
            key = string_copy(key, 2, string_length(key) - 2);
            key = string_upper(key);
        }
    }

    // Ensure registry exists and the key is present
    if (!variable_global_exists("font_sheets")) {
        basic_print_system_message("FONTSET registry not initialized");
        return;
    }
    if (!ds_map_exists(global.font_sheets, key)) {
        basic_cmd_print("FONTSET: " + key + " not found", false);
        return;
    }

    // Lock the font so MODE/room init won't overwrite it
    global.active_font_name   = key;
    global.active_font_sprite = global.font_sheets[? key];
    global.font_locked        = true;

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("FONTSET -> " + key
            + "  sprite=" + string(global.active_font_sprite)
            + "  subimages=" + string(sprite_get_number(global.active_font_sprite)));
    }

    // Lightweight refresh: keep existing fg/bg; ensure spaces re-stamp under new atlas
    global.grid_refresh_needed = true;
    global.grid_refresh_char   = 32; // space
}
