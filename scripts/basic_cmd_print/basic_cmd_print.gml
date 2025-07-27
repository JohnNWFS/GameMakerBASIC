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

        // Quoted string
        if (string_length(part) >= 2 &&
            string_char_at(part, 1) == "\"" &&
            string_char_at(part, string_length(part)) == "\"") {
            part = string_copy(part, 2, string_length(part) - 2);
            output += part;
        }
        // Variable resolution from global.basic_variables
        else if (ds_map_exists(global.basic_variables, string_upper(part))) {
            output += string(global.basic_variables[? string_upper(part)]);
        }
        // Fallback literal (for debugging/malformed input)
        else {
            output += part;
        }
    }

    // Append to print line buffer
    global.print_line_buffer += output;

    // If newline is not suppressed, add line and current color to output lists
    if (!suppress_newline) {
        ds_list_add(output_lines, global.print_line_buffer);
        ds_list_add(global.output_colors, global.current_draw_color);
        global.print_line_buffer = "";
    }
}
