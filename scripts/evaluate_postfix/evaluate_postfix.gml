function evaluate_postfix(postfix) {
    var stack = [];

    for (var i = 0; i < array_length(postfix); i++) {
        var token = postfix[i];
        var token_upper = string_upper(token);

        show_debug_message("POSTFIX: Processing token → " + token);

        if (is_numeric_string(token)) {
            var num = real(token);
            array_push(stack, num);
            show_debug_message("POSTFIX: Pushed number → " + string(num));
        }

        else if (is_operator(token_upper)) {
            if (array_length(stack) < 2) {
                show_debug_message("? POSTFIX ERROR: Not enough operands for operator " + token_upper);
                return 0;
            }
            var b = array_pop(stack);
            var a = array_pop(stack);
            var result = 0;

            switch (token_upper) {
                case "+":
                    if (is_string(a) || is_string(b)) {
                        result = string(a) + string(b);
                    } else {
                        result = a + b;
                    }
                    break;
                case "-": result = a - b; break;
                case "*": result = a * b; break;
                case "/": result = (b != 0) ? a / b : 0; break;
                case "%":
                case "MOD": result = a mod b; break;
                case "^": result = power(a, b); break;
            }

            array_push(stack, result);
            show_debug_message("POSTFIX: Operator result (" + token_upper + ") = " + string(result));
        }

        else if (ds_map_exists(global.basic_variables, token_upper)) {
            var val = global.basic_variables[? token_upper];
            array_push(stack, val);
            show_debug_message("POSTFIX: Loaded variable " + token_upper + " = " + string(val));
        }

        else if (token_upper == "RND") {
            if (array_length(stack) < 1) return 0;
            var arg = array_pop(stack);
            var r = irandom(real(arg));
            array_push(stack, r);
            show_debug_message("POSTFIX: RND(" + string(arg) + ") = " + string(r));
        }

		 else if (token_upper == "ABS" && array_length(stack) >= 1) {
		    var arg = array_pop(stack);
		    array_push(stack, abs(real(arg)));
		}
		else if (token_upper == "EXP" && array_length(stack) >= 1) {
		    var arg = array_pop(stack);
		    array_push(stack, exp(real(arg)));
		}
		else if (token_upper == "LOG" && array_length(stack) >= 1) {
		    var arg = array_pop(stack);
		    array_push(stack, log(real(arg)));
		}
		else if (token_upper == "SGN" && array_length(stack) >= 1) {
		    var arg = array_pop(stack);
		    array_push(stack, (arg > 0) - (arg < 0));
		}
		else if (token_upper == "INT" && array_length(stack) >= 1) {
		    var arg = array_pop(stack);
		    array_push(stack, floor(real(arg)));
		}
		else if (token_upper == "SIN" && array_length(stack) >= 1) {
		    var arg = array_pop(stack);
		    array_push(stack, sin(real(arg)));
		}
		else if (token_upper == "COS" && array_length(stack) >= 1) {
		    var arg = array_pop(stack);
		    array_push(stack, cos(real(arg)));
		}
		else if (token_upper == "TAN" && array_length(stack) >= 1) {
		    var arg = array_pop(stack);
		    array_push(stack, tan(real(arg)));
		}

        else {
            show_debug_message("? POSTFIX ERROR: Unknown token '" + token + "'");
            array_push(stack, 0);
        }
    }

    return (array_length(stack) > 0) ? stack[0] : 0;
}
