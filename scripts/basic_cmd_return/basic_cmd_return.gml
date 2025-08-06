function basic_cmd_return() {
    if (ds_stack_empty(global.gosub_stack)) {
        show_debug_message("RETURN: ERROR — gosub_stack is empty");
        basic_show_error_message("RETURN called with empty stack.");
        global.interpreter_running = false;
        return;
    }

    var return_index = ds_stack_pop(global.gosub_stack);
    global.interpreter_next_line = return_index;
    show_debug_message("RETURN: Popped return index from gosub_stack: " + string(return_index));
}
