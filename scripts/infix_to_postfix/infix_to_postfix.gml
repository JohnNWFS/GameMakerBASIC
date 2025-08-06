function infix_to_postfix(tokens) {
    show_debug_message("Converting to postfix: " + string(tokens));
    var output = [];
    var stack = [];

    for (var i = 0; i < array_length(tokens); i++) {
        var t = tokens[i];
        show_debug_message("Processing token: '" + t + "'");
		if (t == ",") {
	    show_debug_message("Skipping comma token");
	    continue;
	}
        // Handle numbers
        if (is_numeric_string(t)) {
            array_push(output, t);
            show_debug_message("Added number to output: " + t);
        }

        // Handle known variable names
        else if (ds_map_exists(global.basic_variables, string_upper(t))) {
            array_push(output, string_upper(t));
            show_debug_message("Added variable name to output: " + string_upper(t));
        }

        // Handle opening parenthesis
        else if (t == "(") {
            array_push(stack, t);
        }

        // Handle closing parenthesis
        else if (t == ")") {
            while (array_length(stack) > 0 && stack[array_length(stack) - 1] != "(") {
                array_push(output, array_pop(stack));
            }
            if (array_length(stack) > 0) {
                array_pop(stack); // Pop the "("
            }
        }

        // Handle operators
        else if (is_operator(t)) {
            show_debug_message("Found operator: " + t);
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

		// Handle functions
		else if (is_function(t)) {
		    var fn_name = string_upper(t);

		    // Fallback for function name without parentheses
		    if (i + 1 >= array_length(tokens) || tokens[i+1] != "(") {
		        show_debug_message("? Function '" + t + "' used without parentheses. Defaulting to " + fn_name + "(1) behavior.");
		        array_push(output, "1");
		        array_push(output, fn_name);
		        continue;
		    }

		    // Handle functions with empty parentheses like RND()
		    if (i + 2 < array_length(tokens) && tokens[i+1] == "(" && tokens[i+2] == ")") {
		        if (fn_name == "RND") {
		            array_push(output, "1");  // Default argument
		            array_push(output, fn_name);
		            show_debug_message("Processed empty " + fn_name + "() - defaulting to " + fn_name + "(1)");
		            i += 2;
		            continue;
		        }
		    }


            // Special case: REPEAT$ expects 2 arguments
            if (fn_name == "REPEAT$") {
                show_debug_message("REPEAT$ DEBUG: i=" + string(i) + ", array_length=" + string(array_length(tokens)));
                show_debug_message("REPEAT$ DEBUG: Checking bounds: " + string(i + 5) + " < " + string(array_length(tokens)) + " = " + string(i + 5 < array_length(tokens)));
                if (i + 1 < array_length(tokens)) show_debug_message("tokens[i+1] = " + tokens[i+1]);
                if (i + 3 < array_length(tokens)) show_debug_message("tokens[i+3] = " + tokens[i+3]);
                if (i + 5 < array_length(tokens)) show_debug_message("tokens[i+5] = " + tokens[i+5]);

                if (i + 5 < array_length(tokens) &&
                    tokens[i+1] == "(" &&
                    tokens[i+3] == "," &&
                    tokens[i+5] == ")")  {

                    var arg1 = tokens[i+2];
                    var arg2 = tokens[i+4];

                    array_push(output, arg1);
                    array_push(output, arg2);
                    array_push(output, fn_name);
                    show_debug_message("Processed REPEAT$ function: args = " + arg1 + ", " + arg2);
                    i += 5;
                } else {
                    show_debug_message("Malformed REPEAT$ function call: " + t);
                    array_push(output, t);
                }
            }

			// RND(min,max) = 2 args
			else if (fn_name == "RND" &&
			         i + 5 < array_length(tokens) &&
			         tokens[i+1] == "(" &&
			         tokens[i+3] == "," &&
			         tokens[i+5] == ")") {

			    var arg1 = tokens[i+2];
			    var arg2 = tokens[i+4];

			    array_push(output, arg1);
			    array_push(output, arg2);
			    array_push(output, "RND2");  // <<< CHANGED HERE
			    show_debug_message("Processed RND(min,max): args = " + arg1 + ", " + arg2);
			    i += 5;
			}

		// RND(n) = 1 arg
		else if (i + 3 < array_length(tokens) && tokens[i+1] == "(" && tokens[i+3] == ")") {
			var arg_token = tokens[i+2];
			array_push(output, arg_token);
			if (fn_name == "RND") {
			    array_push(output, "RND1"); // <<< CHANGED HERE
			    show_debug_message("Processed RND(n): " + arg_token);
			} else {
			    array_push(output, fn_name);
			}
			i += 3;
		}

			// Handle empty RND() → treat as RND(1)
			else if (fn_name == "RND" &&
			         i + 2 < array_length(tokens) &&
			         tokens[i+1] == "(" &&
			         tokens[i+2] == ")") {
			    array_push(output, "1");
			    array_push(output, "RND:1");
			    show_debug_message("Processed empty RND() - defaulting to RND(1)");
			    i += 2;
			}


            // LEFT$ and RIGHT$ (2 args)
            else if ((fn_name == "LEFT$" || fn_name == "RIGHT$") &&
                     i + 5 < array_length(tokens) &&
                     tokens[i+1] == "(" &&
                     tokens[i+3] == "," &&
                     tokens[i+5] == ")") {

                var arg1 = tokens[i+2];
                var arg2 = tokens[i+4];

                array_push(output, arg1);
                array_push(output, arg2);
                array_push(output, fn_name);
                show_debug_message("Processed " + fn_name + " function: args = " + arg1 + ", " + arg2);
                i += 5;
            }


			 // MID$ (3 args)
			else if (fn_name == "MID$") {
			    show_debug_message("MID$ DEBUG: i=" + string(i) + ", total tokens=" + string(array_length(tokens)));
			    if (i + 1 < array_length(tokens)) show_debug_message("tokens[i+1] = " + tokens[i+1]);
			    if (i + 3 < array_length(tokens)) show_debug_message("tokens[i+3] = " + tokens[i+3]);
			    if (i + 5 < array_length(tokens)) show_debug_message("tokens[i+5] = " + tokens[i+5]);
			    if (i + 7 < array_length(tokens)) show_debug_message("tokens[i+7] = " + tokens[i+7]);

			    if (i + 7 < array_length(tokens) &&
			        tokens[i+1] == "(" &&
			        tokens[i+3] == "," &&
			        tokens[i+5] == "," &&
			        tokens[i+7] == ")") {

			        var arg1 = tokens[i+2];
			        var arg2 = tokens[i+4];
			        var arg3 = tokens[i+6];

			        array_push(output, arg1);
			        array_push(output, arg2);
			        array_push(output, arg3);
			        array_push(output, fn_name);
			        show_debug_message("Processed MID$ function: args = " + arg1 + ", " + arg2 + ", " + arg3);
			        i += 7;
			    } else {
			        show_debug_message("Malformed MID$ function call: " + t);
			        array_push(output, t);
			    }
			}

			// Handle functions with empty parentheses like RND()
			else if (i + 2 < array_length(tokens) && tokens[i+1] == "(" && tokens[i+2] == ")") {
			    // For RND(), default to RND(1)
			    if (fn_name == "RND") {
			        array_push(output, "1");  // Default argument
			        array_push(output, fn_name);
			        show_debug_message("Processed empty " + fn_name + "() - defaulting to " + fn_name + "(1)");
			        i += 2;
			    }
			    else {
			        show_debug_message("Function " + fn_name + "() with no arguments not supported");
			        array_push(output, t);
			    }
			}


            // Generic 1-arg functions
            else if (i + 3 < array_length(tokens) && tokens[i+1] == "(" && tokens[i+3] == ")") {
                var arg_token = tokens[i+2];
                array_push(output, arg_token);
                array_push(output, fn_name);
                show_debug_message("Processed 1-arg function call: " + fn_name + "(" + arg_token + ")");
                i += 3;
            }

            // Fallback: malformed
            else {
                show_debug_message("Malformed function call: " + t);
                array_push(output, t);
            }
        }

        // Unknown token
        else {
            show_debug_message("Unknown token, adding to output: " + t);
            array_push(output, t);
        }
    }

    while (array_length(stack) > 0) {
        array_push(output, array_pop(stack));
    }

    show_debug_message("Final postfix: " + string(output));
    return output;
}
