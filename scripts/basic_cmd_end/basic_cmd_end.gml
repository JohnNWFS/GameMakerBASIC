function basic_cmd_end() {
    dbg_log(DBG_FLOW, "END: Program termination requested");
    global.stop_breakpoint_active = false;
    global.program_has_ended = true;
    global.interpreter_running = false;
	 global.current_mode = 0;
    basic_output_transcript_finalize();
    dbg_log(DBG_FLOW, "END: interpreter_running set to false");
}

/// STOP — breakpoint: preserve variables and resume on next RUN.
function basic_cmd_stop() {
    dbg_log(DBG_FLOW, "STOP: breakpoint at line " + string(global.current_line_number));

    if (is_string(global.print_line_buffer) && string_length(global.print_line_buffer) > 0) {
        basic_wrap_and_commit(global.print_line_buffer, global.current_draw_color);
        global.print_line_buffer = "";
    }

    global.stop_breakpoint_active   = true;
    global.stop_resume_line_index   = global.interpreter_current_line_index;
    global.stop_resume_stmt_index   = global.interpreter_current_stmt_index;

    global.pause_in_effect     = false;
    global.awaiting_input      = false;
    global.inkey_waiting       = false;
    global.interpreter_running = false;
    global.program_has_ended   = false;

    var _prev = global.current_draw_color;
    global.current_draw_color = c_yellow;
    basic_wrap_and_commit("STOP at line " + string(global.current_line_number) + " — RUN to continue", global.current_draw_color);
    global.current_draw_color = _prev;

    global.current_mode = 0;
    room_goto(global.editor_return_room);
}
