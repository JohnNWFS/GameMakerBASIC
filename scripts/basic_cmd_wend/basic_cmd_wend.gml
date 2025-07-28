function basic_cmd_wend() {
    if (!ds_exists(global.while_stack, ds_type_stack) || ds_stack_empty(global.while_stack)) {
        basic_show_message("WEND without matching WHILE");
        return;
    }

    var while_line = ds_stack_pop(global.while_stack);
    var code = ds_map_find_value(global.program_map, ds_list_find_value(global.line_list, while_line));
    var condition = string_trim(string_delete(code, 1, string_pos(" ", code)));

    var value = basic_evaluate_condition(string_upper(condition));

    if (value) {
        line_index = while_line - 1; // will increment after this
    }
}
