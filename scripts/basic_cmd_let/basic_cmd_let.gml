function basic_cmd_let(arg) {
    show_debug_message("LET: Raw input: '" + arg + "'");

    var eq_pos = string_pos("=", arg);
    if (eq_pos <= 0) {
        show_debug_message("LET ERROR: No '=' found in input: " + arg);
        return;
    }

    var varname = string_upper(string_trim(string_copy(arg, 1, eq_pos - 1)));
    var expr = string_trim(string_copy(arg, eq_pos + 1, string_length(arg)));

    show_debug_message("LET: Parsed variable name: '" + varname + "'");
    show_debug_message("LET: Parsed expression: '" + expr + "'");

    // Check for empty variable name or expression
    if (string_length(varname) == 0) {
        show_debug_message("LET ERROR: Variable name is empty.");
        return;
    }
    if (string_length(expr) == 0) {
        show_debug_message("LET ERROR: Expression is empty.");
        return;
    }

    // Handle string literal assignment
    if (string_length(expr) >= 2 && string_char_at(expr, 1) == "\"" && string_char_at(expr, string_length(expr)) == "\"") {
        var str_val = string_copy(expr, 2, string_length(expr) - 2);
        global.basic_variables[? varname] = str_val;
        show_debug_message("LET: Assigned string value: '" + str_val + "' to '" + varname + "'");
        return;
    }

	// Evaluate numeric or expression assignment
	var result = basic_evaluate_expression_v2(expr);

	// Type-check before storing
	if (is_string(result)) {
	    global.basic_variables[? varname] = result;
	    show_debug_message("LET: Assigned string value: '" + result + "' to '" + varname + "'");
	} else {
	    global.basic_variables[? varname] = result;
	    show_debug_message("LET: Assigned numeric value: " + string(result) + " to '" + varname + "'");
	}

}
