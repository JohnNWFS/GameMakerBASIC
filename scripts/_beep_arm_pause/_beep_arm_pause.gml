/// @function _beep_arm_pause(ms)
/// @desc Arm a timed pause and schedule resume at the next colon segment.
function _beep_arm_pause(ms) {
    global.beep_waiting       = true;
    global.beep_release_time  = current_time + ms;

    // Pause interpreter and schedule stmt-level resume (p+1 on this line)
    global.pause_in_effect          = true;
    global.interpreter_use_stmt_jump = true;
    global.interpreter_target_line   = global.interpreter_current_line_index;
    global.interpreter_target_stmt   = global.interpreter_current_stmt_index + 1;

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("BEEP: armed wait " + string(ms) + "ms; resume at stmt " + string(global.interpreter_target_stmt));
    }
}
