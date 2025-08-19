function basic_cmd_cls() {
    if (dbg_on(DBG_FLOW))  show_debug_message("CLS: Called");
    if (dbg_on(DBG_FLOW))  show_debug_message("CLS: Current color before clear: " + string(global.current_draw_color));

    ds_list_clear(global.output_lines);
    ds_list_clear(global.output_colors);

    global.current_draw_color = global.basic_text_color;

    if (dbg_on(DBG_FLOW))  show_debug_message("CLS: Screen cleared");
    if (dbg_on(DBG_FLOW))  show_debug_message("CLS: Current color reset to default: " + string(global.current_draw_color));
}
