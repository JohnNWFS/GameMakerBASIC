/// @script basic_cmd_gosub
function basic_cmd_gosub(arg) {
    var raw = string_trim(arg);
    var colonPos = string_pos(":", raw);
    if (colonPos > 0) raw = string_trim(string_copy(raw, 1, colonPos - 1));
    var target = real(raw);

    // Ensure gosub stack exists
    if (!ds_exists(global.gosub_stack, ds_type_stack)) {
        global.gosub_stack = ds_stack_create();
    }

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

    // Jump to target line
    global.interpreter_next_line = -1;
    var listSize = ds_list_size(global.line_list);
    for (var i = 0; i < listSize; i++) {
        if (ds_list_find_value(global.line_list, i) == target) {
            global.interpreter_next_line = i;
            break;
        }
    }
    if (global.interpreter_next_line == -1) {
        basic_syntax_error("GOSUB target line not found: " + string(target),
            global.current_line_number, global.interpreter_current_stmt_index, "GOSUB_TARGET");
        return;
    }
}
