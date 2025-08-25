/// @function basic_cmd_font(arg)
/// @desc FONTSET "KEY" -> switch active font sprite by registry key
function basic_cmd_font(arg) {
    if (global.current_mode < 1) {
        basic_print_system_message("FONT not implemented in MODE " + string(global.current_mode));
        return;
    }

    var key = string_trim(arg);

    // Strip quotes if present
    if (string_length(key) >= 2) {
        var f = string_char_at(key,1);
        var l = string_char_at(key,string_length(key));
        if ((f == "\"" || f == "'") && f == l) key = string_copy(key,2,string_length(key)-2);
    }

    key = string_upper(key);

    if (!variable_global_exists("font_sheets")) {
        basic_print_system_message("FONT registry not initialized");
        return;
    }

    if (ds_map_exists(global.font_sheets, key)) {
        var spr = ds_map_find_value(global.font_sheets, key);
        global.active_font_name   = key;
        global.active_font_sprite = spr;

        // DEBUG: prove which sprite & how many subimages
        var n = sprite_get_number(spr);
        if (dbg_on(DBG_FLOW)) {
            show_debug_message("FONTSET: key=" + key
                + " spr_id=" + string(spr)
                + " subimages=" + string(n));
        }

        // Trigger a lightweight refresh (keeps existing fg/bg)
        global.grid_refresh_needed = true;
        global.grid_refresh_char   = 32; // space

    } else {
        basic_cmd_print("FONT " + key + " not found", false);
        if (dbg_on(DBG_FLOW)) show_debug_message("FONTSET: missing registry key '" + key + "'");
    }
}
