// SCRIPT: basic_stop_execution
function basic_stop_execution() {
    show_debug_message("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    show_debug_message("BASIC_STOP_EXECUTION CALLED!");
    show_debug_message("Call Stack:");
    show_debug_message(debug_get_callstack()); // THIS IS THE KEY!
    show_debug_message("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

    global.interpreter_running = false;
    global.awaiting_input = false;
    global.program_has_ended = true;

    // Clear input buffer if input was pending
    if (global.input_buffer != undefined && ds_list_exists(global.input_buffer, ds_type_list)) {
        ds_list_clear(global.input_buffer);
    }
}