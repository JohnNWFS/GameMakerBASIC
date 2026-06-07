/// @event obj_mode2_surface/Step
if (!variable_global_exists("mode2_surface") || !surface_exists(global.mode2_surface)) {
    mode2_surface_recreate();
}
