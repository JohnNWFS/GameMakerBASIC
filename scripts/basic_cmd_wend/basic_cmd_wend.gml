function basic_cmd_wend() {
    show_debug_message("WEND: Entering handler...");

    if (!ds_exists(global.while_stack, ds_type_stack)) {
        show_debug_message("WEND: ERROR — while_stack does not exist");
        basic_show_message("WEND without matching WHILE");
        return;
    }

    if (ds_stack_empty(global.while_stack)) {
        show_debug_message("WEND: ERROR — while_stack is empty");
        basic_show_message("WEND without matching WHILE");
        return;
    }

    var while_line_index = ds_stack_top(global.while_stack); // Peek, do not pop yet
    show_debug_message("WEND: Top of while_stack is line index: " + string(while_line_index));

    var while_line_number = ds_list_find_value(global.line_list, while_line_index);
    var while_code = ds_map_find_value(global.program_map, while_line_number);
    show_debug_message("WEND: WHILE line " + string(while_line_number) + " code: '" + while_code + "'");

    var condition_str = string_trim(string_delete(while_code, 1, string_pos(" ", while_code)));
    show_debug_message("WEND: Extracted condition for re-evaluation: '" + condition_str + "'");

    var condition_value = basic_evaluate_condition(string_upper(condition_str));
    show_debug_message("WEND: Re-evaluated condition result: " + string(condition_value));

    if (condition_value) {
        show_debug_message("WEND: Condition is TRUE — setting line_index = " + string(while_line_index - 1));
        line_index = while_line_index - 1; // So next Step brings us back to WHILE
    } else {
        show_debug_message("WEND: Condition is FALSE — popping WHILE from stack");
        ds_stack_pop(global.while_stack);
    }
}
