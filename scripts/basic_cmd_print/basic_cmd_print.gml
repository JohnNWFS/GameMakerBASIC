function basic_cmd_print(arg) {
    var suppress_newline = false;

    // Detect and remove trailing semicolon
    if (string_length(arg) > 0 && string_char_at(arg, string_length(arg)) == ";") {
        suppress_newline = true;
        arg = string_copy(arg, 1, string_length(arg) - 1);
    }

    var output = "";
    var token_list = string_split(arg, "+");

for (var i = 0; i < array_length(token_list); i++) {
    var part = string_trim(token_list[i]);

    if (is_quoted_string(part)) {
        // Remove quotes and treat as literal
        var literal = string_copy(part, 2, string_length(part) - 2);
        output += literal;
    } else {
        // Safe to evaluate
        var result = basic_evaluate_expression(part);
        output += string(result);
    }
}


    // Append to print line buffer
    global.print_line_buffer += output;

    if (!suppress_newline) {
        ds_list_add(global.output_lines, global.print_line_buffer);
        ds_list_add(global.output_colors, global.current_draw_color);
        global.print_line_buffer = "";
    }
}
