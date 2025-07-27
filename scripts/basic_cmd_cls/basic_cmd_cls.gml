function basic_cmd_cls() {
    show_debug_message("CLS called - current color was: " + string(global.current_draw_color));
    ds_list_clear(global.output_lines);
    ds_list_clear(global.output_colors);
    global.current_draw_color = global.basic_text_color;
    show_debug_message("CLS called - color now set to: " + string(global.current_draw_color));
}