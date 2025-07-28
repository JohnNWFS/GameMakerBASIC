function basic_cmd_gosub(arg) {
    var target = real(arg);

    // Push return point (next line index) onto stack
    ds_stack_push(global.gosub_stack, line_index + 1);

    // Set interpreter jump
    interpreter_next_line = -1;
    for (var i = 0; i < ds_list_size(global.line_list); i++) {
        if (ds_list_find_value(global.line_list, i) == target) {
            interpreter_next_line = i;
            break;
        }
    }

    if (interpreter_next_line == -1) {
        basic_show_error_message("GOSUB target line not found: " + string(target));
        global.interpreter_running = false;
    }
}
