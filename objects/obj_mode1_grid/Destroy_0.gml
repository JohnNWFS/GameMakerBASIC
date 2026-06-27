/// @event obj_mode1_grid/Destroy
if (surface_exists(grid_surface)) {
    surface_free(grid_surface);
    grid_surface = -1;
}
reset_interpreter_state();
global.current_mode = 0;
show_message(" Unto the abyss I fall");