function mode2_surface_recreate() {
    if (variable_global_exists("mode2_surface") && surface_exists(global.mode2_surface)) {
        surface_free(global.mode2_surface);
    }

    global.mode2_surface = surface_create(room_width, room_height);
    surface_set_target(global.mode2_surface);
    draw_clear(c_black);
    surface_reset_target();
    dbg_log(DBG_FLOW, "MODE2: surface recreated " + string(room_width) + "x" + string(room_height));
}
