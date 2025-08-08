function basic_cmd_font(arg) {
    if (global.current_mode < 1) {
        basic_print_system_message("FONT not implemented in MODE " + string(global.current_mode));
        return;
    }

    var fontname = string_upper(string_trim(arg));

    // Remove surrounding quotes if user used them
    if (string_length(fontname) >= 2) {
        var first = string_char_at(fontname, 1);
        var last  = string_char_at(fontname, string_length(fontname));
        if ((first == "\"" || first == "'") && first == last) {
            fontname = string_copy(fontname, 2, string_length(fontname) - 2);
        }
    }

    if (ds_map_exists(global.font_sheets, fontname)) {
        global.active_font_name = fontname;
        global.active_font_sprite = global.font_sheets[? fontname];
 
		show_debug_message("Font set to: " + fontname + " " + " global.active_font_sprite: " + string( global.active_font_sprite));

		global.grid_refresh_needed = true; // re-blank the screen using current font’s subimage 32
		show_debug_message("Cleared Screen after font change");
	} else {
        // Call with direct string, avoid expression parsing
        basic_cmd_print("FONT " + fontname + " not found", false);
    }
}
