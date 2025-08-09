function infix_to_postfix(tokens) {
    show_debug_message("Converting to postfix: " + string(tokens));

    var output = [];
    var stack  = [];

    // Local helper: safe uppercase
    var _TOKU = function(_t) { return string_upper(string(_t)); };

    // Local helper: append array contents to another array
    var _push_all = function(_dst, _src) {
        for (var __i = 0; __i < array_length(_src); __i++) {
            array_push(_dst, _src[__i]);
        }
    };

    for (var i = 0; i < array_length(tokens); i++) {
        var t  = tokens[i];        // raw token
        // Ignore commas as separators — functions handle arg order explicitly
        if (t == ",") {
            show_debug_message("INFIX: Skipping comma token");
            continue;
        }

        var tu = _TOKU(t);         // uppercased string form

        // ==========================================================
        // 1) ARRAY READ COLLAPSE — NAME ( balanced stuff )  →  "NAME(...)"
        //    (skip if NAME is a known function)
        // ==========================================================
        if (is_string(t)) {
            var first = string_char_at(t, 1);
            var can_be_name = is_letter(first);

            if (can_be_name
            &&  i + 1 < array_length(tokens)
            &&  tokens[i + 1] == "("
            && !is_function(t)) // do not collapse functions
            {
                var _depth   = 0;
                var j       = i + 1;
                var inner   = "";
                var matched = false;

                show_debug_message("INFIX: Candidate for array collapse → '" + string(t) + "' followed by '('");

                while (j < array_length(tokens)) {
                    var tk = tokens[j];
                    if (tk == "(") {
                        _depth++;
                        if (_depth > 1) inner += tk;
                    } else if (tk == ")") {
                        _depth--;
                        if (_depth == 0) { matched = true; break; }
                        inner += tk;
                    } else {
                        inner += tk;
                    }
                    j++;
                }

                if (matched) {
                    var collapsed = string(t) + "(" + inner + ")";
                    array_push(output, collapsed);
                    show_debug_message("INFIX: Collapsed array read token → '" + collapsed + "' (consumed through index " + string(j) + ")");
                    i = j; // skip to ')'
                    continue;
                } else {
                    show_debug_message("INFIX: WARNING — unmatched '(' after '" + string(t) + "'. Not collapsing.");
                }
            }
        }

        // ==========================================================
        // 2) NUMERIC LITERAL
        // ==========================================================
        if (is_numeric_string(t)) {
            array_push(output, t);
            show_debug_message("Added number to output: " + string(t));
            continue;
        }

        // ==========================================================
        // 3) KNOWN VARIABLE (already in global.basic_variables)
        // ==========================================================
        if (ds_map_exists(global.basic_variables, tu)) {
            array_push(output, tu);
            show_debug_message("Added variable name to output: " + tu);
            continue;
        }

        // ==========================================================
        // 4) OPEN PAREN
        // ==========================================================
        if (t == "(") {
            array_push(stack, t);
            show_debug_message("Pushed '(' onto operator stack");
            continue;
        }

        // ==========================================================
        // 5) CLOSE PAREN
        // ==========================================================
        if (t == ")") {
            while (array_length(stack) > 0 && stack[array_length(stack) - 1] != "(") {
                var popped_close = array_pop(stack);
                array_push(output, popped_close);
                show_debug_message("Popped '" + string(popped_close) + "' from stack to output (closing ')')");
            }
            if (array_length(stack) > 0 && stack[array_length(stack) - 1] == "(") {
                array_pop(stack); // discard '('
                show_debug_message("Discarded matching '(' from stack");
            } else {
                show_debug_message("INFIX: WARNING — stray ')' with no matching '('");
            }
            continue;
        }

        // ==========================================================
        // 6) OPERATORS (+ - * / % MOD ^ etc.)
        // ==========================================================
        if (is_operator(t)) {
            show_debug_message("Found operator: " + string(t));

            while (array_length(stack) > 0) {
                var top = stack[array_length(stack) - 1];
                if (is_operator(top) && (
                    get_precedence(top) > get_precedence(t) ||
                    (get_precedence(top) == get_precedence(t) && !is_right_associative(t))
                )) {
                    var popped_op = array_pop(stack);
                    array_push(output, popped_op);
                    show_debug_message("Popped higher/equal precedence operator '" + string(popped_op) + "' to output");
                } else {
                    break;
                }
            }

            array_push(stack, t);
            show_debug_message("Pushed operator '" + string(t) + "' onto stack");
            continue;
        }

        // ==========================================================
        // 7) FUNCTIONS
        // ==========================================================
        if (is_function(t)) {
            var fn_name = tu;

            // ------------------------------------------------------
            // 7a) NEW: Balanced 1-arg function handler for non-RND
            //     Handles cases like INT( RND(1,6) ), ABS(A+B*C) etc.
            //     We scan for the matching ')' and recursively convert
            //     the inner tokens with THIS same function.
            // ------------------------------------------------------
            if (i + 1 < array_length(tokens) && tokens[i + 1] == "(" && fn_name != "RND") {
                var depthB  = 0;
                var jB      = i + 1;
                var matchedB = false;

                // Find matching ')'
                while (jB < array_length(tokens)) {
                    var tkB = tokens[jB];
                    if (tkB == "(") { depthB++; }
                    else if (tkB == ")") { depthB--; if (depthB == 0) { matchedB = true; break; } }
                    jB++;
                }

                if (matchedB) {
                    // Extract inner tokens (between the outermost '(' and ')')
                    var inner_tokens = [];
                    for (var kB = i + 2; kB <= jB - 1; kB++) {
                        array_push(inner_tokens, tokens[kB]);
                    }

                    // Convert inner expression to postfix and append
                    var inner_post = infix_to_postfix(inner_tokens);
                    _push_all(output, inner_post);

                    // Push the function itself
                    array_push(output, fn_name);
                    show_debug_message("Processed balanced 1-arg function: " + fn_name + "(...)");

                    i = jB; // consume up to ')'
                    continue;
                }
                // If we didn't match, fall through to existing logic below
            }

            // ------------------------------------------------------
            // 7b) RND(min, max) handling for complex arguments
            // ------------------------------------------------------
            if (fn_name == "RND") {
                if (i + 1 < array_length(tokens) && tokens[i + 1] == "(") {
                    var _depth = 0;
                    var j = i + 1;
                    var matched = false;
                    var arg_tokens = [[]]; // Array of token lists for each argument
                    var arg_index = 0;

                    // Collect tokens until matching ')'
                    while (j < array_length(tokens)) {
                        var tk = tokens[j];
                        if (tk == "(") {
                            _depth++;
                            if (_depth > 1) array_push(arg_tokens[arg_index], tk);
                        } else if (tk == ")") {
                            _depth--;
                            if (_depth == 0) { matched = true; break; }
                            array_push(arg_tokens[arg_index], tk);
                        } else if (tk == "," && _depth == 1) {
                            arg_index++;
                            array_push(arg_tokens, []);
                        } else {
                            array_push(arg_tokens[arg_index], tk);
                        }
                        j++;
                    }

                    if (matched) {
                        if (array_length(arg_tokens) == 1 && array_length(arg_tokens[0]) == 0) {
                            // Empty parens: RND()
                            array_push(output, "1");
                            array_push(output, "RND1");
                            show_debug_message("Processed empty RND() → default to RND(1)");
                            i = j;
                            continue;
                        } else if (array_length(arg_tokens) == 1) {
                            // One arg: RND(n)
                            var inner_post = infix_to_postfix(arg_tokens[0]);
                            _push_all(output, inner_post);
                            array_push(output, "RND1");
                            show_debug_message("Processed RND(n): " + string(arg_tokens[0]));
                            i = j;
                            continue;
                        } else if (array_length(arg_tokens) == 2) {
                            // Two args: RND(min, max)
                            var min_post = infix_to_postfix(arg_tokens[0]);
                            var max_post = infix_to_postfix(arg_tokens[1]);
                            _push_all(output, min_post);
                            _push_all(output, max_post);
                            array_push(output, "RND2");
                            show_debug_message("Processed RND(min,max): " + string(arg_tokens[0]) + ", " + string(arg_tokens[1]));
                            i = j;
                            continue;
                        }
                    }
                    // Malformed RND call
                    show_debug_message("Malformed RND call at token '" + string(t) + "' — passing through");
                    array_push(output, t);
                    i = j;
                    continue;
                } else {
                    // RND without parentheses
                    show_debug_message("? Function 'RND' used without parentheses. Defaulting to RND(1) behavior.");
                    array_push(output, "1");
                    array_push(output, "RND1");
                    continue;
                }
            }

            // ------------------------------------------------------
            // 7c) Existing special cases for other functions
            // ------------------------------------------------------
            // Function used WITHOUT parentheses → fallback behavior (fn(1))
            if (i + 1 >= array_length(tokens) || tokens[i + 1] != "(") {
                show_debug_message("? Function '" + string(t) + "' used without parentheses. Defaulting to " + fn_name + "(1) behavior.");
                array_push(output, "1");
                array_push(output, fn_name);
                continue;
            }

            // Empty parens like REPEAT$()
            if (i + 2 < array_length(tokens) && tokens[i + 1] == "(" && tokens[i + 2] == ")") {
                show_debug_message("Function " + fn_name + "() with no args not supported (non-RND) — passing token through");
                array_push(output, t);
                i += 2;
                continue;
            }

            // REPEAT$(s, n) — exactly 2 args (simple positional form)
            if (fn_name == "REPEAT$") {
                show_debug_message("REPEAT$ DEBUG: i=" + string(i) + ", total=" + string(array_length(tokens)));
                if (i + 5 < array_length(tokens)
                &&  tokens[i + 1] == "("
                &&  tokens[i + 3] == ","
                &&  tokens[i + 5] == ")")
                {
                    var rq1 = tokens[i + 2];
                    var rq2 = tokens[i + 4];
                    array_push(output, rq1);
                    array_push(output, rq2);
                    array_push(output, fn_name);
                    show_debug_message("Processed REPEAT$(s,n): args = " + string(rq1) + ", " + string(rq2));
                    i += 5;
                } else {
                    show_debug_message("Malformed REPEAT$ call starting at token '" + string(t) + "'");
                    array_push(output, t);
                }
                continue;
            }

            // MID$(s, start, len) — 3 args
            if (fn_name == "MID$") {
                show_debug_message("MID$ DEBUG: i=" + string(i) + ", total tokens=" + string(array_length(tokens)));
                if (i + 7 < array_length(tokens)
                &&  tokens[i + 1] == "("
                &&  tokens[i + 3] == ","
                &&  tokens[i + 5] == ","
                &&  tokens[i + 7] == ")")
                {
                    var ma1 = tokens[i + 2];
                    var ma2 = tokens[i + 4];
                    var ma3 = tokens[i + 6];
                    array_push(output, ma1);
                    array_push(output, ma2);
                    array_push(output, ma3);
                    array_push(output, fn_name);
                    show_debug_message("Processed MID$(s,start,len): " + string(ma1) + ", " + string(ma3));
                    i += 7;
                } else {
                    show_debug_message("Malformed MID$ call starting at token '" + string(t) + "'");
                    array_push(output, t);
                }
                continue;
            }

            // LEFT$/RIGHT$ (2 args)
            if ((fn_name == "LEFT$" || fn_name == "RIGHT$")
            &&  i + 5 < array_length(tokens)
            &&  tokens[i + 1] == "("
            &&  tokens[i + 3] == ","
            &&  tokens[i + 5] == ")")
            {
                var la1 = tokens[i + 2];
                var la2 = tokens[i + 4];
                array_push(output, la1);
                array_push(output, la2);
                array_push(output, fn_name);
                show_debug_message("Processed " + fn_name + "(arg1,arg2): " + string(la1) + ", " + string(la2));
                i += 5;
                continue;
            }

            // Fallback: malformed function call
            show_debug_message("Malformed function call: " + string(t));
            array_push(output, t);
            continue;
        }

        // ==========================================================
        // 8) UNKNOWN TOKEN — pass through (evaluator often tolerates)
        // ==========================================================
        show_debug_message("Unknown token, adding to output: " + string(t));
        array_push(output, t);
    }

    // ==========================================================
    // Drain operator stack
    // ==========================================================
    while (array_length(stack) > 0) {
        var tail = array_pop(stack);
        array_push(output, tail);
        show_debug_message("Drained operator stack → appended '" + string(tail) + "'");
    }

    show_debug_message("Final postfix: " + string(output));
    return output;
}