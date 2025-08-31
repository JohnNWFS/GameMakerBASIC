function basic_cmd_return() {
	if (ds_stack_empty(global.gosub_stack)) {
	    basic_syntax_error("RETURN without matching GOSUB", 
	        global.current_line_number, global.interpreter_current_stmt_index, "GOSUB_MISMATCH");
	    return;
	}

    var return_index = ds_stack_pop(global.gosub_stack);
    global.interpreter_next_line = return_index;
    if (dbg_on(DBG_FLOW))  show_debug_message("RETURN: Popped return index from gosub_stack: " + string(return_index));
}
