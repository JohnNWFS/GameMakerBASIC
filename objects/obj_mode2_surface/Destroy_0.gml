/// @event obj_mode2_surface/Destroy
if (variable_global_exists("mode2_surface") && surface_exists(global.mode2_surface)) {
    surface_free(global.mode2_surface);
}
global.mode2_surface = -1;
