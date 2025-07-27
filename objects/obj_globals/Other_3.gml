// Destroy global DS maps
if (ds_exists(global.basic_variables, ds_type_map)) {
    ds_map_destroy(global.basic_variables);
}
if (ds_exists(global.program_lines, ds_type_map)) {
    ds_map_destroy(global.program_lines);
}
if (ds_exists(global.basic_program, ds_type_map)) {
    ds_map_destroy(global.basic_program);
}

// Destroy global DS lists
if (ds_exists(global.line_numbers, ds_type_list)) {
    ds_list_destroy(global.line_numbers);
}
if (ds_exists(global.undo_stack, ds_type_list)) {
    ds_list_destroy(global.undo_stack);
}
if (ds_exists(global.output_lines, ds_type_list)) {
    ds_list_destroy(global.output_lines);
}
if (ds_exists(global.output_colors, ds_type_list)) {
    ds_list_destroy(global.output_colors);
}
if (ds_exists(global.input_history, ds_type_list)) {
    ds_list_destroy(global.input_history);
}
if (ds_exists(global.basic_line_numbers, ds_type_list)) {
    ds_list_destroy(global.basic_line_numbers);
}

// Clear buffer variables
if (variable_global_exists("print_line_buffer")) {
    global.print_line_buffer = "";
}

// Optional: reset color states (not strictly necessary)
if (variable_global_exists("basic_text_color")) {
    global.basic_text_color = c_white;
}
if (variable_global_exists("current_draw_color")) {
    global.current_draw_color = c_white;
}

// Optional: flag editor cleanup
global.editor_spawned = false;
