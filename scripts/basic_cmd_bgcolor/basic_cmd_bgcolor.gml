function basic_cmd_bgcolor(arg) {
    var colstr = string_upper(string_trim(arg));
    if (dbg_on(DBG_FLOW))  show_debug_message("BGCOLOR: Raw argument: '" + arg + "', Normalized: '" + colstr + "'");
    
    var bg_color = c_black;
    var matched = false;

    // Look up named color
    if (ds_map_exists(global.colors, colstr)) {
        bg_color = global.colors[? colstr];
        matched = true;
        if (dbg_on(DBG_FLOW))  show_debug_message("BGCOLOR: Matched named color → " + string(bg_color));
    }
    // RGB() syntax
   else if (string_pos("RGB(", colstr) == 1) {
    var l = string_pos("(", colstr), r = string_last_pos(")", colstr);
    if (r > l) {
        var inner = string_copy(colstr, l + 1, r - l - 1);
        var parts = []; var buf = ""; var _depth = 0;
        for (var i = 1; i <= string_length(inner); i++) {
            var ch = string_char_at(inner, i);
            if (ch == "(") _depth++; else if (ch == ")") _depth--;
            if (ch == "," && _depth == 0) { array_push(parts, buf); buf = ""; } else buf += ch;
        }
        array_push(parts, buf);
        if (array_length(parts) == 3) {
            var rV = clamp(floor(basic_evaluate_expression_v2(string_trim(parts[0]))), 0, 255);
            var gV = clamp(floor(basic_evaluate_expression_v2(string_trim(parts[1]))), 0, 255);
            var bV = clamp(floor(basic_evaluate_expression_v2(string_trim(parts[2]))), 0, 255);
            bg_color = make_color_rgb(rV, gV, bV); matched = true;
        } else if (dbg_on(DBG_FLOW))  {show_debug_message("BGCOLOR: Invalid RGB arg count in '" + inner + "'");}
    } else if (dbg_on(DBG_FLOW))  {show_debug_message("BGCOLOR: Missing ) in '" + colstr + "'");}
}
 else {
        if (dbg_on(DBG_FLOW))  show_debug_message("BGCOLOR: No matching named color or RGB format found for '" + colstr + "'");
    }

    global.background_draw_color = bg_color;
    global.background_draw_enabled = (bg_color != c_black);

    if (dbg_on(DBG_FLOW))  show_debug_message("BGCOLOR: Final color set to " + string(bg_color) + ", background_draw_enabled: " + string(global.background_draw_enabled));
}
