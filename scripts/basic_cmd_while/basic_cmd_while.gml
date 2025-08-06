function basic_cmd_while(arg) {
    var condition = string_upper(arg);
    show_debug_message("WHILE: Raw condition string: '" + condition + "'");

    var value = basic_evaluate_condition(condition);

    show_debug_message("WHILE: Evaluated result of '" + condition + "' → " + string(value));

    if (!value) {
        show_debug_message("WHILE: Condition is FALSE — skipping ahead to matching WEND");
        var _depth = 1;

        for (var i = line_index + 1; i < ds_list_size(global.line_list); i++) {
            var _ln = ds_list_find_value(global.line_list, i);
            var code = ds_map_find_value(global.program_map, _ln);
            var cmd = string_upper(string_trim(string_copy(code, 1, string_pos(" ", code + " ") - 1)));

            show_debug_message("WHILE: Inspecting line " + string(_ln) + " → Command: " + cmd);

            if (cmd == "WHILE") _depth++;
            if (cmd == "WEND") _depth--;

            if (_depth == 0) {
                show_debug_message("WHILE: Found matching WEND at line index " + string(i) + ", line " + string(_ln));
                global.interpreter_next_line = i;
                return;
            }
        }

        show_debug_message("?WHILE ERROR: No matching WEND found — control flow may break");
    } else {
        show_debug_message("WHILE: Condition is TRUE — evaluating stack push logic");

        // Ensure stack exists
        if (!ds_exists(global.while_stack, ds_type_stack)) {
            global.while_stack = ds_stack_create();
            show_debug_message("WHILE: Created new while_stack");
        }

        // Only push if not already at top
        if (ds_stack_empty(global.while_stack) || ds_stack_top(global.while_stack) != line_index) {
            ds_stack_push(global.while_stack, line_index);
            show_debug_message("WHILE: Pushed line_index " + string(line_index) + " onto while_stack");
        } else {
            show_debug_message("WHILE: Stack already contains this line_index at top — skipping push");
        }

        // Ensure interpreter continues to next line
        global.interpreter_next_line = -1;
    }
}
