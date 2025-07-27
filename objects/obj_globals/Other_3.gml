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

if (variable_global_exists("program_map")) {
	ds_map_destroy(global.program_map);
}

if (variable_global_exists("line_list")) {
	ds_list_destroy(global.line_list);
	}

if (variable_global_exists("output_lines")) {
	ds_list_destroy(global.output_lines);
	}

if (variable_global_exists("interpreter_current_program")) {
	ds_list_destroy(global.interpreter_current_program);
	}

// Optional: flag editor cleanup
global.editor_spawned = false;
