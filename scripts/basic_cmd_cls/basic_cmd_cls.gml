function basic_cmd_cls() {
    dbg_log(DBG_FLOW, "CLS: Called");
    dbg_log(DBG_FLOW, "CLS: Current color before clear: " + string(global.current_draw_color));

    var current_mode = variable_global_exists("current_mode") ? global.current_mode : 0;

    if (current_mode == 2) {
        if (ds_exists(global.output_lines, ds_type_list))  ds_list_clear(global.output_lines);
        if (ds_exists(global.output_colors, ds_type_list)) ds_list_clear(global.output_colors);
        global.print_line_buffer = "";

        if (!variable_global_exists("mode2_surface") || !surface_exists(global.mode2_surface)) {
            mode2_surface_recreate();
        } else {
            surface_set_target(global.mode2_surface);
            draw_clear(c_black);
            surface_reset_target();
        }

        global.current_draw_color = global.basic_text_color;
        dbg_log(DBG_FLOW, "CLS: Screen cleared (MODE 2)");
        return;
    }

    // Are we in MODE 1? Prefer explicit mode flag; fall back to grid presence.
    var in_mode1 = (current_mode == 1) || instance_exists(obj_mode1_grid);

    if (in_mode1) {
        // Route to MODE 1 version (auto-detects 8/16/32 and bg color)
        basic_cmd_cls_mode1();
        dbg_log(DBG_FLOW, "CLS: Routed to MODE 1 clear");
        return;
    }

    // --- MODE 0 (text console) clear ---
    if (ds_exists(global.output_lines, ds_type_list))  ds_list_clear(global.output_lines);
    if (ds_exists(global.output_colors, ds_type_list)) ds_list_clear(global.output_colors);

    // Reset draw color to default BASIC text color
    global.current_draw_color = global.basic_text_color;

    dbg_log(DBG_FLOW, "CLS: Screen cleared (MODE 0)");
    dbg_log(DBG_FLOW, "CLS: Current color reset to default: " + string(global.current_draw_color));
}
