/// @event obj_globals/Game_End
global.inkey_mode = false;
// ─────────────────────────────
// MAPS
// ─────────────────────────────
if (ds_exists(global.basic_variables, ds_type_map)) ds_map_destroy(global.basic_variables);
if (ds_exists(global.program_lines, ds_type_map)) ds_map_destroy(global.program_lines);
if (ds_exists(global.basic_program, ds_type_map)) ds_map_destroy(global.basic_program);
if (ds_exists(global.program_map, ds_type_map)) ds_map_destroy(global.program_map);
if (ds_exists(global.colors, ds_type_map)) ds_map_destroy(global.colors);
if (ds_exists(global.if_block_map, ds_type_map)) {
    var _key = ds_map_find_first(global.if_block_map);
    while (!is_undefined(_key)) {
        var _info = global.if_block_map[? _key];
        if (ds_exists(_info[? "elseifIndices"], ds_type_list)) ds_list_destroy(_info[? "elseifIndices"]);
        ds_map_destroy(_info);
        _key = ds_map_find_next(global.if_block_map, _key);
    }
    ds_map_destroy(global.if_block_map);
}
if (ds_exists(global.mode_rooms, ds_type_map)) ds_map_destroy(global.mode_rooms);
if (ds_exists(global.font_sheets, ds_type_map)) ds_map_destroy(global.font_sheets);
if (ds_exists(global.config, ds_type_map)) ds_map_destroy(global.config);
if (ds_exists(global.data_streams, ds_type_map)) {
    var _key = ds_map_find_first(global.data_streams);
    while (!is_undefined(_key)) {
        var _stream = global.data_streams[? _key];
        if (ds_exists(_stream.list, ds_type_list)) ds_list_destroy(_stream.list);
        _key = ds_map_find_next(global.data_streams, _key);
    }
    ds_map_destroy(global.data_streams);
}

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
if (ds_exists(global.basic_line_numbers, ds_type_list)) {
    ds_list_destroy(global.basic_line_numbers);
}

if (ds_exists(global.undo_stack, ds_type_list)) {
    while (!ds_list_empty(global.undo_stack)) {
        var _snapshot = ds_list_find_value(global.undo_stack, 0);
        if (ds_exists(_snapshot[? "global.program_lines"], ds_type_map)) ds_map_destroy(_snapshot[? "global.program_lines"]);
        if (ds_exists(_snapshot[? "global.line_numbers"], ds_type_list)) ds_list_destroy(_snapshot[? "global.line_numbers"]);
        ds_map_destroy(_snapshot);
        ds_list_delete(global.undo_stack, 0);
    }
    ds_list_destroy(global.undo_stack);
}
if (ds_exists(global.output_lines, ds_type_list)) ds_list_destroy(global.output_lines);
if (ds_exists(global.output_colors, ds_type_list)) ds_list_destroy(global.output_colors);
if (ds_exists(global.input_history, ds_type_list)) ds_list_destroy(global.input_history);

// ─────────────────────────────
// STACKS
// ─────────────────────────────
if (ds_exists(global.gosub_stack, ds_type_stack)) ds_stack_destroy(global.gosub_stack);
if (ds_exists(global.for_stack, ds_type_stack)) ds_stack_destroy(global.for_stack);
if (ds_exists(global.while_stack, ds_type_stack)) ds_stack_destroy(global.while_stack);
if (ds_exists(global.if_stack, ds_type_stack)) ds_stack_destroy(global.if_stack);

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
