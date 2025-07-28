function basic_cmd_while(arg) {
    var condition = string_upper(arg);
    var value = basic_evaluate_condition(condition);

    if (!value) {
        // Skip ahead to corresponding WEND
        var _depth = 1;
        for (var i = line_index + 1; i < ds_list_size(global.line_list); i++) {
            var _ln = ds_list_find_value(global.line_list, i);
            var code = ds_map_find_value(global.program_map, ln);
            var cmd = string_upper(string_trim(string_copy(code, 1, string_pos(" ", code + " ") - 1)));

            if (cmd == "WHILE") _depth++;
            if (cmd == "WEND") _depth--;

            if (_depth == 0) {
                line_index = i; // move to matching WEND line
                return;
            }
        }
    } else {
        // Save position for WEND to return to
        if (!ds_exists(global.while_stack, ds_type_stack)) {
            global.while_stack = ds_stack_create();
        }
        ds_stack_push(global.while_stack, line_index);
    }
}
