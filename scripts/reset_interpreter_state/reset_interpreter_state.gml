/// Clear BASIC variables, arrays, control stacks, and open file handles for a fresh RUN.
function basic_runtime_reset_for_run() {
    basic_memory_runtime_reset();
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