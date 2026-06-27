/// @script basic_cmd_gosub
function basic_cmd_gosub(arg) {
    var raw = string_trim(arg);
    var colonPos = string_pos(":", raw);
    if (colonPos > 0) raw = string_trim(string_copy(raw, 1, colonPos - 1));
    var target_arg = basic_eval_number_arg(raw, "GOSUB", "line");
    if (!target_arg.ok) return;
    var target = target_arg.value;

    basic_memory_ensure_stack("gosub_stack");

    // === CHANGE: capture statement-level resume point on this same line ===
    var resume_stmt = 0;
    if (variable_global_exists("interpreter_current_stmt_index")) {
        resume_stmt = global.interpreter_current_stmt_index + 1;  // next stmt on this line
    }
    var frame = {
        kind: "stmt",                 // mark as statement-level resume
        line_index: line_index,       // current line index
        stmt_index: resume_stmt       // next statement to run on return
    };
    ds_stack_push(global.gosub_stack, frame);

    global.interpreter_next_line = basic_line_index_for(target);
    if (global.interpreter_next_line < 0) {
        basic_syntax_error("GOSUB target line not found: " + string(target),
            global.current_line_number, global.interpreter_current_stmt_index, "GOSUB_TARGET");
        return;
    }
}
