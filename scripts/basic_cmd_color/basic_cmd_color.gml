/// @script basic_cmd_color
/// @description Change text color (and optional background): COLOR fg[, bg]
function basic_cmd_color(arg) {
    var parts = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(parts, "COLOR", 1, 2, "fg[,bg]")) return;

    var fg_col = basic_parse_color(string_trim(parts[0]), noone);
    if (fg_col == noone) {
        dbg_log(DBG_FLOW, "?COLOR ERROR: Unknown foreground color '" + string_trim(parts[0]) + "'");
    } else {
        global.basic_text_color   = fg_col;
        global.current_draw_color = fg_col;
    }

    if (array_length(parts) > 1) {
        var bg_col = basic_parse_color(string_trim(parts[1]), noone);
        if (bg_col == noone) {
            dbg_log(DBG_FLOW, "?COLOR ERROR: Unknown background color '" + string_trim(parts[1]) + "'");
        } else {
            global.background_draw_color   = bg_col;
            global.background_draw_enabled = true;
        }
    }
}