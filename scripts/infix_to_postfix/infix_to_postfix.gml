function infix_to_postfix(tokens) {
	    show_debug_message("Converting to postfix: " + string(tokens));  // Add this
    var output = [];
    var stack = [];

    for (var i = 0; i < array_length(tokens); i++) {
        var t = tokens[i];
		show_debug_message("Processing token: '" + t + "'");  // Add this
        if (is_numeric_string(t)) {
            array_push(output, t);
			show_debug_message("Added number to output: " + t);  // Add this
        }
        else if (ds_map_exists(global.basic_variables, string_upper(t))) {
           array_push(output, string_upper(t));
			show_debug_message("Added variable name to output: " + string_upper(t));
        }
        else if (t == "(") {
            array_push(stack, t);
        }
        else if (t == ")") {
            while (array_length(stack) > 0 && stack[array_length(stack) - 1] != "(") {
                array_push(output, array_pop(stack));
            }
            if (array_length(stack) > 0) {
                array_pop(stack); // Remove "("
            }
        }
        else if (is_operator(t)) {
			     show_debug_message("Found operator: " + t);  // Add this
            while (array_length(stack) > 0) {
                var top = stack[array_length(stack) - 1];
                if (is_operator(top) && (
                        get_precedence(top) > get_precedence(t) || 
                        (get_precedence(top) == get_precedence(t) && !is_right_associative(t))
                    )) {
                    array_push(output, array_pop(stack));
                } else {
                    break;
                }
            }
            array_push(stack, t);
        }
        else {
            // Assume function call or unknown token, push directly
			 show_debug_message("Unknown token, adding to output: " + t);  // Add this
            array_push(output, t);
        }
    }

    while (array_length(stack) > 0) {
        array_push(output, array_pop(stack));
    }
show_debug_message("Final postfix: " + string(output));  // Add this
    return output;
}
