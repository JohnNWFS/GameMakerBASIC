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

	// --- NEW: also treat commas as PRINT argument separators ---
	// Flatten: for each semicolon part, split by unquoted commas and append
	var _flat = [];
	for (var _i = 0; _i < array_length(parts); _i++) {
	    var _seg = string_trim(parts[_i]);
	    if (_seg == "") continue;

	    var _comma_parts = split_on_unquoted_commas(_seg);
	    if (array_length(_comma_parts) <= 1) {
	        _flat[array_length(_flat)] = _seg;
	    } else {
	        if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: semicolon part[" + string(_i) + "] split into " + string(array_length(_comma_parts)) + " comma-args");
	        for (var _j = 0; _j < array_length(_comma_parts); _j++) {
	            var _sub = string_trim(_comma_parts[_j]);
	            if (_sub != "") _flat[array_length(_flat)] = _sub;
	        }
	    }
	}
	// Replace parts with flattened list so the loop below processes each comma arg
	parts = _flat;
	// Compact numbers when PRINT has multiple args (no fixed-width padding)
	var _print_compact = (array_length(parts) > 1);

	if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: flattened args count = " + string(array_length(parts)));


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
			    var _inner = string_copy(part, 2, string_length(part) - 2);
			    _inner = string_replace_all(_inner, "\"\"", "\""); // unescape doubled quotes "" → "
			    output += _inner;
			    if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: Part " + string(i) + " is string literal → " + _inner);
			} else {
            show_debug_message("PRINT: Part " + string(i) + " is expression → " + part);
            var tokens = basic_tokenize_expression_v2(part);
            show_debug_message("PRINT: Tokens = " + string(tokens));

            var postfix = infix_to_postfix(tokens);
            show_debug_message("PRINT: Postfix = " + string(postfix));

            var result = evaluate_postfix(postfix);
            show_debug_message("PRINT: Evaluated result = " + string(result));

		if (is_real(result)) {
	    var _text_value;
	    if (_print_compact) {
	        // NEW: when multiple PRINT args, don’t pad → prevents mid-number wraps
	        _text_value = string(result);
	        if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: numeric (compact) → '" + _text_value + "'");
	    } else {
	        // ORIGINAL single-expr formatting (keep your look & feel)
	        if (frac(result) == 0) {
	            _text_value = string(round(result)); // whole number → no decimal
	        } else {
	            _text_value = string_format(result, 12, 8); // your existing padded decimal format
	        }
	        if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: numeric (padded) → '" + _text_value + "'");
	    }
	    output += _text_value;
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
