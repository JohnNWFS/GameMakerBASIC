function basic_cmd_print(arg, line_number) {

if (!ds_exists(global.output_lines, ds_type_list))  global.output_lines  = ds_list_create();
if (!ds_exists(global.output_colors, ds_type_list)) global.output_colors = ds_list_create();





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
   var parts = split_on_unquoted_semicolons(arg);


    for (var i = 0; i < array_length(parts); i++) {
        var part = string_trim(parts[i]);

        if (part == "") continue;

        var treat_as_literal = false;

        if (is_quoted_string(part)) {
            var inner = string_copy(part, 2, string_length(part) - 2);
            if (!string_pos("+", inner) && !string_pos("-", inner) && !string_pos("*", inner) && !string_pos("/", inner)) {
                treat_as_literal = true;
            }
        }

        if (treat_as_literal) {
            output += string_copy(part, 2, string_length(part) - 2);
            show_debug_message("PRINT: Part " + string(i) + " is string literal → " + string_copy(part, 2, string_length(part) - 2));
        } else {
            show_debug_message("PRINT: Part " + string(i) + " is expression → " + part);
            var tokens = basic_tokenize_expression_v2(part);
            show_debug_message("PRINT: Tokens = " + string(tokens));

            var postfix = infix_to_postfix(tokens);
            show_debug_message("PRINT: Postfix = " + string(postfix));

            var result = evaluate_postfix(postfix);
            show_debug_message("PRINT: Evaluated result = " + string(result));

		if (is_real(result)) {
		    if (frac(result) == 0) {
		        output += string(round(result)); // whole number → no decimal
		    } else {
		        output += string_format(result, 12, 8); // retain full format for decimals
		    }
		} else {
		    output += string(result);
		}

        }
    }

    // Append to line buffer with wrap
    var wrap_width = 40;
    var full_line = global.print_line_buffer + output;

	while (string_length(full_line) > wrap_width) {
	    var line = string_copy(full_line, 1, wrap_width);
	    ds_list_add(global.output_lines, line);
	    ds_list_add(global.output_colors, global.current_draw_color);
	    full_line = string_copy(full_line, wrap_width + 1, string_length(full_line) - wrap_width);
	}


    global.print_line_buffer = full_line;

    if (!suppress_newline) {
		basic_wrap_and_commit(global.print_line_buffer, global.current_draw_color);
        show_debug_message("PRINT: Line committed → " + global.print_line_buffer);
        global.print_line_buffer = "";
    } else {
        show_debug_message("PRINT: Output buffered without newline → " + global.print_line_buffer);
    }
}
