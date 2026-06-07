function basic_cmd_cls() {
    dbg_log(DBG_FLOW, "CLS: Called");
    dbg_log(DBG_FLOW, "CLS: Current color before clear: " + string(global.current_draw_color));

    // Are we in MODE 1? Prefer explicit mode flag; fall back to grid presence.
    var in_mode1 = (variable_global_exists("current_mode") && global.current_mode == 1)
                   || instance_exists(obj_mode1_grid);

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
