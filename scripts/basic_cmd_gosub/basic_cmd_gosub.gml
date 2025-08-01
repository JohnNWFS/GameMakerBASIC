function basic_cmd_gosub(arg) {
    var target = real(arg);
    show_debug_message("GOSUB: Target line requested: " + string(target));

    // Push return point (next line index) onto stack
    var return_index = line_index + 1;
    ds_stack_push(global.gosub_stack, return_index);
    show_debug_message("GOSUB: Pushed return index: " + string(return_index));

    // Search for the target line in the program
    interpreter_next_line = -1;
    for (var i = 0; i < ds_list_size(global.line_list); i++) {
        if (ds_list_find_value(global.line_list, i) == target) {
            interpreter_next_line = i;
            show_debug_message("GOSUB: Found target line at index " + string(i));
            break;
        }
    }

    if (interpreter_next_line == -1) {
        show_debug_message("GOSUB: ERROR — Target line " + string(target) + " not found");
        basic_show_error_message("GOSUB target line not found: " + string(target));
        global.interpreter_running = false;
    }
}
