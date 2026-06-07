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
        room_goto(rm_basic_interpreter);
    }
    
    global.option_base = 1; // reset to default between runs

    // Clear any program execution state
    ds_stack_clear(global.gosub_stack);
    ds_stack_clear(global.for_stack);
    ds_stack_clear(global.while_stack);
	// Clear INKEY$ queue
    if (variable_global_exists("__inkey_queue") && ds_exists(global.__inkey_queue, ds_type_queue)) {
        ds_queue_clear(global.__inkey_queue);
        dbg_log(DBG_FLOW, "INKEY$ RESET: Cleared global.__inkey_queue");
    }
}
