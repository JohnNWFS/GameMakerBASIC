// SCRIPT: basic_stop_execution
function basic_stop_execution() {
    if (dbg_on(DBG_FLOW)) show_debug_message("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    if (dbg_on(DBG_FLOW)) show_debug_message("BASIC_STOP_EXECUTION CALLED!");
    if (dbg_on(DBG_FLOW)) show_debug_message("Call Stack:");
    if (dbg_on(DBG_FLOW)) show_debug_message(debug_get_callstack()); // THIS IS THE KEY!
    if (dbg_on(DBG_FLOW)) show_debug_message("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

    global.interpreter_running = false;
    global.awaiting_input = false;
    global.program_has_ended = true;

    // Clear input buffer if input was pending
    if (global.input_buffer != undefined && ds_list_exists(global.input_buffer, ds_type_list)) {
        ds_list_clear(global.input_buffer);
    }
}