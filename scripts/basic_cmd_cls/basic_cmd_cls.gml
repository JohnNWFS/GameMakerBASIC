function basic_cmd_cls() {
    show_debug_message("CLS: Called");
    show_debug_message("CLS: Current color before clear: " + string(global.current_draw_color));

    ds_list_clear(global.output_lines);
    ds_list_clear(global.output_colors);

    global.current_draw_color = global.basic_text_color;

    show_debug_message("CLS: Screen cleared");
    show_debug_message("CLS: Current color reset to default: " + string(global.current_draw_color));
}
