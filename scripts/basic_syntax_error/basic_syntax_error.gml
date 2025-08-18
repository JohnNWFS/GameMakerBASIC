/// @script basic_syntax_error
/// Print a visible error line and stop the interpreter gracefully.
/// @param msg        string message explaining the error
/// @param line_no    (optional) line number; defaults to current
/// @param stmt_idx   (optional) colon-slot index; defaults to current
/// @param hint_key   (optional) short key for contextual hints, e.g. "INKEY_MISUSE"
function basic_syntax_error(msg, line_no, stmt_idx, hint_key) {
    if (is_undefined(line_no))  line_no  = global.current_line_number;
    if (is_undefined(stmt_idx)) stmt_idx = global.interpreter_current_stmt_index;

    // Flush any buffered PRINT so error doesn't glue to prior text
    if (is_string(global.print_line_buffer) && string_length(global.print_line_buffer) > 0) {
        basic_wrap_and_commit(global.print_line_buffer, global.current_draw_color);
        global.print_line_buffer = "";
    }

    var prev_col = global.current_draw_color;

    // Header + reason
    global.current_draw_color = c_red;
    basic_wrap_and_commit("SYNTAX ERROR at " + string(line_no) + ":", global.current_draw_color);
    basic_wrap_and_commit(string(msg), global.current_draw_color);

    // Compact hints
    if (ds_exists(global.config, ds_type_map) && global.config[? "show_error_hints"]) {
        var _h = basic_error_hint(hint_key);
        for (var i = 0; i < array_length(_h); i++) {
            if (_h[i] != "") basic_wrap_and_commit("  " + _h[i], global.current_draw_color);
        }
    }

    global.current_draw_color = prev_col;

    // Stop cleanly (no gates left engaged)
    global.pause_in_effect     = false;
    global.awaiting_input      = false;
    global.input_expected      = false;
    global.inkey_mode          = false;
    global.inkey_waiting       = false;

    global.interpreter_running = false;
    global.program_has_ended   = true;

    // Let run_program() know not to clear the screen immediately
    global._syntax_error_just_emitted = true;

    show_debug_message("SYNTAX: " + msg + " (line " + string(line_no) + ")");
}
