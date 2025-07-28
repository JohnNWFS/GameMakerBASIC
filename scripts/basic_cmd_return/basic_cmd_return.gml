function basic_cmd_return() {
    if (ds_stack_empty(global.gosub_stack)) {
        basic_show_error_message("RETURN called with empty stack.");
        global.interpreter_running = false;
        return;
    }

    interpreter_next_line = ds_stack_pop(global.gosub_stack);
}
