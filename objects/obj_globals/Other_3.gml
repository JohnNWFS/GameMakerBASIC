	/// @description Cleanup all global DS structures at game end
	global.inkey_mode = false;
	// ─────────────────────────────
	// MAPS
	// ─────────────────────────────
	if (ds_exists(global.basic_variables, ds_type_map)) ds_map_destroy(global.basic_variables);
	if (ds_exists(global.program_lines, ds_type_map)) ds_map_destroy(global.program_lines);
	if (ds_exists(global.basic_program, ds_type_map)) ds_map_destroy(global.basic_program);
	if (ds_exists(global.program_map, ds_type_map)) ds_map_destroy(global.program_map);
	if (ds_exists(global.colors, ds_type_map)) ds_map_destroy(global.colors);


	// ─────────────────────────────
	// ARRAYS
	// ─────────────────────────────
	if (ds_exists(global.basic_arrays, ds_type_map)) {
	    // Destroy each backing list…
	    var _key = ds_map_find_first(global.basic_arrays);
	    while (!is_undefined(_key)) {
	        var _lst = global.basic_arrays[? _key];
	        ds_list_destroy(_lst);
	        _key = ds_map_find_next(global.basic_arrays, _key);
	    }
	    // Then destroy the map itself
	    ds_map_destroy(global.basic_arrays);
	}


	// ─────────────────────────────
	// LISTS
	// ─────────────────────────────
	if (ds_exists(global.line_list, ds_type_list)) ds_list_destroy(global.line_list);
	if (ds_exists(global.line_numbers, ds_type_list)) ds_list_destroy(global.line_numbers);

	if (variable_global_exists("basic_line_numbers")) {
	    if (ds_exists(global.basic_line_numbers, ds_type_list)) {
	        ds_list_destroy(global.basic_line_numbers);
	    }
	}

	if (ds_exists(global.undo_stack, ds_type_list)) ds_list_destroy(global.undo_stack);
	if (ds_exists(global.output_lines, ds_type_list)) ds_list_destroy(global.output_lines);
	if (ds_exists(global.output_colors, ds_type_list)) ds_list_destroy(global.output_colors);
	if (ds_exists(global.input_history, ds_type_list)) ds_list_destroy(global.input_history);

	// ─────────────────────────────
	// STACKS
	// ─────────────────────────────
	if (ds_exists(global.gosub_stack, ds_type_stack)) ds_stack_destroy(global.gosub_stack);
	if (ds_exists(global.for_stack, ds_type_stack)) ds_stack_destroy(global.for_stack);
	if (ds_exists(global.while_stack, ds_type_stack)) ds_stack_destroy(global.while_stack);

	// ─────────────────────────────
	// TEMPORARY LIST (used in interpreter object)
	// ─────────────────────────────
	if (variable_global_exists("interpreter_current_program")) {
	    if (ds_exists(interpreter_current_program, ds_type_list)) {
	        ds_list_destroy(interpreter_current_program);
	    }
	}

	// ─────────────────────────────
	// Buffer & State Cleanup
	// ─────────────────────────────
	global.print_line_buffer = "";
	global.editor_spawned = false;

	   if (ds_exists(global.__inkey_queue, ds_type_queue)) {
	        ds_queue_destroy(global.__inkey_queue);
	    }
	
	// === 1. FIRST: Add this to your obj_globals Create event ===
	// Initialize the key input queue with debugging
	show_debug_message("INKEY$ INIT: Creating queue...");
	global.__inkey_queue = ds_queue_create();
	show_debug_message("INKEY$ INIT: Queue created, exists = " + string(ds_exists(global.__inkey_queue, ds_type_queue)));
