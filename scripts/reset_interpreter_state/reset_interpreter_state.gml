function reset_interpreter_state() {
    global.interpreter_running = false;
    global.program_has_ended = false;
    global.awaiting_input = false;
    global.pause_in_effect = false;
    global.pause_mode = false;
    global.input_expected = false;
    global.interpreter_input = "";
    global.interpreter_cursor_pos = 0;
    global.last_interpreter_string = "";
    
    // Reset mode if needed
    if (global.current_mode != 0) {
        global.current_mode = 0;
        room_goto(rm_basic_interpreter);
    }
    
    // Clear any program execution state
    ds_stack_clear(global.gosub_stack);
    ds_stack_clear(global.for_stack);
    ds_stack_clear(global.while_stack);
}