/// @description Cleanup all global DS structures at game end

// ─────────────────────────────
// MAPS
// ─────────────────────────────
if (ds_exists(global.basic_variables, ds_type_map)) ds_map_destroy(global.basic_variables);
if (ds_exists(global.program_lines, ds_type_map)) ds_map_destroy(global.program_lines);
if (ds_exists(global.basic_program, ds_type_map)) ds_map_destroy(global.basic_program);
if (ds_exists(global.program_map, ds_type_map)) ds_map_destroy(global.program_map);
if (ds_exists(global.colors, ds_type_map)) ds_map_destroy(global.colors);

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
