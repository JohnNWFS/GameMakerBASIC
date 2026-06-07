function basic_cmd_end() {
    dbg_log(DBG_FLOW, "END: Program termination requested");
    global.program_has_ended = true;
    global.interpreter_running = false;
	 global.current_mode = 0;
    basic_output_transcript_finalize();
    dbg_log(DBG_FLOW, "END: interpreter_running set to false");
}
