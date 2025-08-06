function evaluate_postfix(postfix) {
    var stack = [];
    show_debug_message("Evaluating postfix: " + string(postfix));

    for (var i = 0; i < array_length(postfix); i++) {
        var token = postfix[i];
        // always safe-stringify even arrays
        show_debug_message("POSTFIX: Processing token [" + string(i) + "] -> " + string(token));

        var token_upper = string_upper(token);

        // Numeric literal
        if (is_numeric_string(token)) {
            var num = real(token);
            array_push(stack, num);
            show_debug_message("POSTFIX: Pushed number → " + string(num));
        }
        // Quoted string literal
        else if (string_length(token) >= 2
                 && string_char_at(token, 1) == "\""
                 && string_char_at(token, string_length(token)) == "\"") {
            var str = string_copy(token, 2, string_length(token) - 2);
            array_push(stack, str);
            show_debug_message("POSTFIX: Pushed quoted string literal → " + str);
        }
        // Operator
        else if (is_operator(token_upper)) {
            if (array_length(stack) < 2) {
                show_debug_message("? POSTFIX ERROR: Not enough operands for operator " + token_upper);
                return 0;
            }
            var b = array_pop(stack);
            var a = array_pop(stack);
            var result = 0;

            show_debug_message("POSTFIX: (pre trim) Dispatching token_upper → '" 
                              + token_upper 
                              + "' (len=" + string(string_length(token_upper)) + ")");
            token_upper = string_upper(string_trim(token));
            show_debug_message("POSTFIX: (post trim) Dispatching token_upper → '" 
                              + token_upper 
                              + "' (len=" + string(string_length(token_upper)) + ")");

            switch (token_upper) {
                case "+":
                    if (is_string(a) || is_string(b)) result = string(a) + string(b);
                    else result = a + b;
                    break;
					
				case "*":
				    // if either operand is still a string, turn it into a real
				    if (is_string(a)) a = real(a);
				    if (is_string(b)) b = real(b);
				    result = a * b;
				    break;
	
				case "/":
				    // if either operand is still a string, turn it into a real
				    if (is_string(a)) a = real(a);
				    if (is_string(b)) b = real(b);
				    result = (b != 0) ? a / b : 0;
				    break;

				case "%":
				case "MOD":
				    // if either operand is still a string, turn it into a real
				    if (is_string(a)) a = real(a);
				    if (is_string(b)) b = real(b);
				    result = a mod b;
				    break;

				case "^":
				    // if either operand is still a string, turn it into a real
				    if (is_string(a)) a = real(a);
				    if (is_string(b)) b = real(b);
				    result = power(a, b);
				    break;
                default:
                    show_debug_message("? POSTFIX WARNING: Unknown operator = " + token_upper);
                    result = 0;
                    break;
            }

            array_push(stack, result);
            show_debug_message("POSTFIX: Operator result (" + token_upper + ") = " + string(result));
        }
        // Multi-arg string functions (stubs – unchanged)
        else if (token_upper == "REPEAT$") {
            // … existing REPEAT$ code …
        }
        else if (token_upper == "LEFT$") {
            // … existing LEFT$ code …
        }
        else if (token_upper == "RIGHT$") {
            // … existing RIGHT$ code …
        }
        else if (token_upper == "MID$") {
            // … existing MID$ code …
        }
        // Single-arg and multi-arg numeric functions
        else if (is_function(token_upper)) {
            // debug
            show_debug_message("EVAL POSTFIX: raw token_upper = '" + token_upper + "'");
            token_upper = string_upper(string_trim(token));
            show_debug_message("POSTFIX: Dispatching token_upper → '" + token_upper + "'");

            switch (token_upper) {
                case "RND1": {
                    // pop one argument
                    var n = safe_real_pop(stack);
                    if (n <= 0) n = 1;
                    var r1 = irandom(n - 1) + 1;
                    array_push(stack, r1);
                    show_debug_message("POSTFIX: RND(" + string(n) + ") → " + string(r1));
                    break;
                }
                case "RND2": {
                    // pop two arguments (max then min)
                    var maxv = safe_real_pop(stack);
                    var minv = safe_real_pop(stack);
                    var r2 = irandom_range(minv, maxv);
                    array_push(stack, r2);
                    show_debug_message("POSTFIX: RND(" 
                                      + string(minv) 
                                      + "," 
                                      + string(maxv) 
                                      + ") → " 
                                      + string(r2));
                    break;
                }
                case "ABS": {
                    var v = safe_real_pop(stack);
                    array_push(stack, abs(v));
                    break;
                }
                case "EXP": {
                    var v = safe_real_pop(stack);
                    array_push(stack, exp(v));
                    break;
                }
                case "LOG":
                case "LOG10": {
                    var v = safe_real_pop(stack);
                    array_push(stack, (ln(v) / ln(10)));
                    break;
                }
                case "SGN": {
                    var v = safe_real_pop(stack);
                    array_push(stack, (v > 0) - (v < 0));
                    break;
                }
                case "INT": {
                    var v = safe_real_pop(stack);
                    array_push(stack, floor(v));
                    break;
                }
                case "SIN": {
                    var v = safe_real_pop(stack);
                    array_push(stack, sin(v));
                    break;
                }
                case "COS": {
                    var v = safe_real_pop(stack);
                    array_push(stack, cos(v));
                    break;
                }
                case "TAN": {
                    var v = safe_real_pop(stack);
                    array_push(stack, tan(v));
                    break;
                }
                case "STR$": {
                    var v = safe_real_pop(stack);
                    var s = string(v);
                    array_push(stack, s);
                    show_debug_message("POSTFIX: STR$ → " + s);
                    break;
                }
                case "CHR$": {
                    var v = safe_real_pop(stack);
                    var c = chr(v);
                    array_push(stack, c);
                    show_debug_message("POSTFIX: CHR$ → " + c);
                    break;
                }
                default:
                    show_debug_message("? POSTFIX WARNING: Unknown function token_upper = " + token_upper);
                    // safely pop one if we got here
                    array_push(stack, safe_real_pop(stack));
                    break;
            }
        }
        // Variable fallback
        else if (ds_map_exists(global.basic_variables, token_upper)) {
            var v = global.basic_variables[? token_upper];
			if (is_string(v) && string_length(v) == 0) v = 0;
            array_push(stack, v);
            show_debug_message("POSTFIX: Loaded variable " + token_upper + " = " + string(v));
        }
        // Fallback string literal
        else if (!is_operator(token_upper) && !is_function(token_upper)) {
            array_push(stack, token);
            show_debug_message("POSTFIX: Pushed fallback string → " + token);
        }
        // Unknown token
        else {
            show_debug_message("? POSTFIX ERROR: Unknown token '" + token + "'");
            array_push(stack, 0);
        }
    }

    return (array_length(stack) > 0) ? stack[0] : 0;
}
