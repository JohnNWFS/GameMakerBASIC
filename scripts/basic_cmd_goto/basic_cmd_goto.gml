/// @function basic_cmd_goto(arg)
/// @description Sets the program counter to a new line number if it exists.
function basic_cmd_goto(arg) {
    dbg_log(DBG_FLOW, "GOTO START — Raw arg: '" + arg + "'");

    var trimmed_arg = string_trim(arg);
    var target_arg = basic_eval_number_arg(trimmed_arg, "GOTO", "line");
    if (!target_arg.ok) return;
    var target_line = target_arg.value;

    dbg_log(DBG_FLOW, "GOTO: Parsed target line number: " + string(target_line));

    var index = basic_line_index_for(target_line);

    if (index >= 0) {
        global.interpreter_next_line = index;
        dbg_log(DBG_FLOW, "GOTO SUCCESS → Jumping to line " + string(target_line) + " (list index " + string(index) + ")");
    } else {
        dbg_log(DBG_FLOW, "?GOTO ERROR: Line number " + string(target_line) + " not found in global.line_list");
    }
}

/// ON ERROR GOTO line — install error handler (0 disables).
function basic_cmd_on_error_goto(arg) {
    var tgt_arg = basic_eval_number_arg(string_trim(arg), "ON ERROR GOTO", "line");
    if (!tgt_arg.ok) return;
    var tgt = floor(tgt_arg.value);
    global.on_error_goto_line = (tgt <= 0) ? 0 : tgt;
    dbg_log(DBG_FLOW, "ON ERROR GOTO " + string(global.on_error_goto_line));
}

/// Jump to ON ERROR handler instead of ending the program.
function basic_error_trap_dispatch(_line_no) {
    if (!variable_global_exists("on_error_goto_line") || global.on_error_goto_line <= 0) return false;
    if (variable_global_exists("error_trap_active") && global.error_trap_active) return false;

    var idx = basic_line_index_for(global.on_error_goto_line);
    if (idx < 0) return false;

    global.error_trap_active = true;
    global.err_last_line     = _line_no;
    global.program_has_ended   = false;
    global.interpreter_running = true;
    global.pause_in_effect     = false;
    global.awaiting_input      = false;
    global.inkey_waiting       = false;
    global._syntax_error_just_emitted = false;

    global.interpreter_next_line         = idx;
    global.interpreter_use_stmt_jump     = false;
    global.interpreter_target_line       = -1;
    global.interpreter_resume_stmt_index = 0;

    var _prev = global.current_draw_color;
    global.current_draw_color = c_red;
    basic_wrap_and_commit("ERROR at " + string(_line_no) + " — ON ERROR GOTO " + string(global.on_error_goto_line), global.current_draw_color);
    global.current_draw_color = _prev;

    dbg_log(DBG_FLOW, "ERROR TRAP: line " + string(_line_no) + " -> handler " + string(global.on_error_goto_line));
    return true;
}
