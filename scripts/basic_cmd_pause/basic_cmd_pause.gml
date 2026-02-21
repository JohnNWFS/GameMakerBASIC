function basic_cmd_pause(arg1) {
    // Defensive: ensure arg1 is always a string for debug concat
    if (is_undefined(arg1)) arg1 = "";

    if (dbg_on(DBG_FLOW)) show_debug_message("PAUSE: Execution paused. Waiting for user to press ENTER... Reason: " + arg1);

    // Arm pause and reuse the INPUT pathway in Step (pause branch)
    global.pause_in_effect  = true;
    global.awaiting_input   = true;   // enables the Step's INPUT/pause branch
    global.pause_mode       = true;   // tells Draw/Step we're in PAUSE, not normal INPUT
    global.input_expected   = false;  // no variable to store
    global.input_target_var = "";     // ensure empty

    // IMPORTANT: Do NOT schedule interpreter_use_stmt_jump here.
    // The Step event (pause branch) will set interpreter_resume_stmt_index = stmt+1
    // when the user presses ENTER/ESC, which resumes at the next colon segment.
    return;
}
