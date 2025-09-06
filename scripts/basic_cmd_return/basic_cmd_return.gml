/// @file scripts/basic_cmd_return/basic_cmd_return.gml
function basic_cmd_return() {
    if (ds_stack_empty(global.gosub_stack)) {
        basic_syntax_error("RETURN without matching GOSUB",
            global.current_line_number, global.interpreter_current_stmt_index, "GOSUB_MISMATCH");
        return;
    }

    var frame = ds_stack_pop(global.gosub_stack);

    // Backward-compat: older frames were numeric line indexes
    if (is_real(frame)) {
        global.interpreter_next_line = frame;
        return;
    }

    // === CHANGE: statement-level resume ===
    if (is_struct(frame) && frame.kind == "stmt") {
        global.interpreter_use_stmt_jump = true;
        global.interpreter_target_line  = frame.line_index;
        global.interpreter_target_stmt  = max(0, frame.stmt_index);
        return;
    }

    // Fallback: if unknown, behave like legacy
    global.interpreter_next_line = is_real(frame) ? frame : (line_index + 1);
}
