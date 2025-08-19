function basic_cmd_end() {
    if (dbg_on(DBG_FLOW)) show_debug_message("END: Program termination requested");
    global.program_has_ended = true;
    global.interpreter_running = false;
	 global.current_mode = 0;
    if (dbg_on(DBG_FLOW)) show_debug_message("END: interpreter_running set to false");
}
