function basic_cmd_bgcolor(arg) {
    var colstr = string_upper(string_trim(arg));
    show_debug_message("BGCOLOR: Raw argument: '" + arg + "', Normalized: '" + colstr + "'");
    
    var bg_color = c_black;
    var matched = false;

    // Look up named color
    if (ds_map_exists(global.colors, colstr)) {
        bg_color = global.colors[? colstr];
        matched = true;
        show_debug_message("BGCOLOR: Matched named color → " + string(bg_color));
    }
    // RGB() syntax
    else if (string_pos("RGB(", colstr) == 1) {
        var inner = string_copy(colstr, 5, string_length(colstr) - 5);
        inner = string_replace_all(inner, ")", "");
        var parts = string_split(inner, ",");
        if (array_length(parts) == 3) {
            var r = real(parts[0]);
            var g = real(parts[1]);
            var b = real(parts[2]);
            bg_color = make_color_rgb(r, g, b);
            matched = true;
            show_debug_message("BGCOLOR: Parsed RGB → R: " + string(r) + ", G: " + string(g) + ", B: " + string(b));
        } else {
            show_debug_message("BGCOLOR: Invalid RGB syntax in '" + colstr + "'");
        }
    } else {
        show_debug_message("BGCOLOR: No matching named color or RGB format found for '" + colstr + "'");
    }

    global.background_draw_color = bg_color;
    global.background_draw_enabled = (bg_color != c_black);

    show_debug_message("BGCOLOR: Final color set to " + string(bg_color) + ", background_draw_enabled: " + string(global.background_draw_enabled));
}
