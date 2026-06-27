/// Clear BASIC variables, arrays, control stacks, and open file handles for a fresh RUN.
function basic_runtime_reset_for_run() {
    global.basic_variables = {};

    if (!variable_global_exists("basic_arrays") || !ds_exists(global.basic_arrays, ds_type_map)) {
        global.basic_arrays = ds_map_create();
    } else {
        var _arr_keys = ds_map_keys_to_array(global.basic_arrays);
        for (var _aki = 0; _aki < array_length(_arr_keys); _aki++) {
            basic_array_release_storage(global.basic_arrays[? _arr_keys[_aki]]);
        }
        ds_map_clear(global.basic_arrays);
    }

    if (!variable_global_exists("basic_array_dims") || !ds_exists(global.basic_array_dims, ds_type_map)) {
        global.basic_array_dims = ds_map_create();
    } else {
        ds_map_clear(global.basic_array_dims);
    }

    if (!variable_global_exists("gosub_stack") || !ds_exists(global.gosub_stack, ds_type_stack)) {
        global.gosub_stack = ds_stack_create();
    } else {
        ds_stack_clear(global.gosub_stack);
    }
    if (!variable_global_exists("for_stack") || !ds_exists(global.for_stack, ds_type_stack)) {
        global.for_stack = ds_stack_create();
    } else {
        ds_stack_clear(global.for_stack);
    }
    if (!variable_global_exists("while_stack") || !ds_exists(global.while_stack, ds_type_stack)) {
        global.while_stack = ds_stack_create();
    } else {
        ds_stack_clear(global.while_stack);
    }
    if (!variable_global_exists("if_stack") || !ds_exists(global.if_stack, ds_type_stack)) {
        global.if_stack = ds_stack_create();
    } else {
        ds_stack_clear(global.if_stack);
    }

    if (variable_global_exists("basic_file_handles") && ds_exists(global.basic_file_handles, ds_type_map)) {
        var _fkeys = ds_map_keys_to_array(global.basic_file_handles);
        for (var _fi = 0; _fi < array_length(_fkeys); _fi++) {
            file_text_close(global.basic_file_handles[? _fkeys[_fi]]);
        }
        ds_map_clear(global.basic_file_handles);
        if (variable_global_exists("basic_file_modes") && ds_exists(global.basic_file_modes, ds_type_map)) {
            ds_map_clear(global.basic_file_modes);
        }
    }

    if (variable_global_exists("__inkey_queue") && ds_exists(global.__inkey_queue, ds_type_queue)) {
        ds_queue_clear(global.__inkey_queue);
    }

    global.option_base = 1;

    dbg_log(DBG_FLOW, "RUNTIME RESET: vars/arrays/stacks/files cleared for fresh RUN");
}

function reset_interpreter_state() {
    global.interpreter_running = false;
    global.program_has_ended = false;
    global.awaiting_input = false;
    global.pause_in_effect = false;
    global.pause_mode = false;
    global.input_expected = false;
    global.interpreter_input = "";
    global.interpreter_cursor_pos = 0;
    global.input_ignore_enter_until_release = false;
    global.input_guard_frames = 0;
    global.inkey_mode = false;
    global.inkey_waiting = false;
    global.inkey_captured = "";
    global.inkey_target_var = "";
    global.inkey_release_guard = false;
    global.inkey_flush_frames = 0;
    global.last_interpreter_string = "";
    keyboard_string = "";

    // Reset mode if needed
    if (global.current_mode != 0) {
        global.current_mode = 0;
        room_goto(ds_map_find_value(global.mode_rooms, 0));
    }

    basic_runtime_reset_for_run();
}