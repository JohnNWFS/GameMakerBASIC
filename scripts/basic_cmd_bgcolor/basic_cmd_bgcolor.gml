function basic_cmd_bgcolor(arg) {
    var colstr = string_trim(arg);
    dbg_log(DBG_FLOW, "BGCOLOR: Raw argument: '" + arg + "'");

    var bg_color = basic_parse_color(colstr, noone);
    if (bg_color == noone) {
        dbg_log(DBG_FLOW, "BGCOLOR: No matching color for '" + colstr + "', keeping black");
        bg_color = c_black;
    }

    global.background_draw_color = bg_color;
    global.background_draw_enabled = (bg_color != c_black);
    global.mode1_bg_color = bg_color;

    dbg_log(DBG_FLOW, "BGCOLOR: Final color set to " + string(bg_color) + ", background_draw_enabled: " + string(global.background_draw_enabled));
}