/// @event obj_mode2_surface/Draw
if (variable_global_exists("mode2_surface") && surface_exists(global.mode2_surface)) {
    draw_surface(global.mode2_surface, 0, 0);
}
