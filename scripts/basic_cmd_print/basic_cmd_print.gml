function basic_cmd_print(arg, line_number) {
    var suppress_newline = false;

    // Check for and remove trailing semicolon
    if (string_length(arg) > 0 && string_char_at(arg, string_length(arg)) == ";") {
        suppress_newline = true;
        arg = string_copy(arg, 1, string_length(arg) - 1);
        show_debug_message("PRINT: Trailing semicolon detected; suppressing newline");
    }

    arg = string_trim(arg);
    var output = "";

    // Split into parts by semicolon for multi-part print
    var parts = string_split(arg, ";");

    for (var i = 0; i < array_length(parts); i++) {
        var part = string_trim(parts[i]);

        if (part == "") continue;

        if (is_quoted_string(part)) {
            var literal = string_copy(part, 2, string_length(part) - 2);
            output += literal;
            show_debug_message("PRINT: Part " + string(i) + " is string literal → " + literal);
        } else {
            show_debug_message("PRINT: Part " + string(i) + " is expression → " + part);
            var tokens = basic_tokenize_expression_v2(part);
            show_debug_message("PRINT: Tokens = " + string(tokens));

            var postfix = infix_to_postfix(tokens);
            show_debug_message("PRINT: Postfix = " + string(postfix));

            var result = evaluate_postfix(postfix);
            show_debug_message("PRINT: Evaluated result = " + string(result));

            // Format numbers with higher precision
            if (is_real(result)) {
                output += string_format(result, 12, 8); // 8 decimal digits, up to 12 characters wide
            } else {
                output += string(result);
            }
        }
    }

    // Append to line buffer
    global.print_line_buffer += output;

    if (!suppress_newline) {
        ds_list_add(global.output_lines, global.print_line_buffer);
        ds_list_add(global.output_colors, global.current_draw_color);
        show_debug_message("PRINT: Line committed → " + global.print_line_buffer);
        global.print_line_buffer = "";
    } else {
        show_debug_message("PRINT: Output buffered without newline → " + global.print_line_buffer);
    }
}
