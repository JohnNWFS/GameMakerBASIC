/// @script evaluate_postfix
/// @description Evaluate a postfix token array, with support for 1-D arrays.
/// Notes:
/// - Array tokens arrive as a single atom like "D(I)" because infix_to_postfix collapses NAME(...).
/// - We defensively avoid treating built-in functions as arrays (e.g., "INT(5)").
/// - Comma tokens are ignored completely.
/// - Returns the TOP of the stack (last pushed), else 0.

function evaluate_postfix(postfix) {
    var stack = [];
    show_debug_message("Evaluating postfix: " + string(postfix));

    for (var i = 0; i < array_length(postfix); i++) {
        var token = postfix[i];
        show_debug_message("POSTFIX: Processing token [" + string(i) + "] → " + string(token));

        // Normalize once
        var trimmed     = string_trim(string(token));
        var token_upper = string_upper(trimmed);

        // -------------------------------------------------------
        // Ignore commas completely (arg separators, never values)
        // -------------------------------------------------------
        if (trimmed == ",") {
            show_debug_message("POSTFIX: Ignoring stray comma token");
            continue;
        }

        // -------------------------------------------------------
        // ARRAY READ SUPPORT (atom form: NAME(index_expr))
        // -------------------------------------------------------
        // Conditions:
        //   - contains '(' and ends with ')'
        //   - the NAME portion is NOT a known function
        var openPos = string_pos("(", token_upper);
        if (openPos > 0 && string_char_at(token_upper, string_length(token_upper)) == ")") {
            var arrNameU = string_copy(token_upper, 1, openPos - 1);
            var innerLen = string_length(token) - openPos - 1;    // count between '(' and ')'
            var idxTextRaw = string_copy(token, openPos + 1, innerLen); // keep RAW (original case/spaces)

            if (!is_function(arrNameU)) {
                var arrName = arrNameU; // arrays stored uppercase in helpers
                var idxText = string_trim(idxTextRaw);

                show_debug_message("POSTFIX[ARRAY]: Candidate '" + string(token) + "' → name='" + arrName + "', idxText='" + idxText + "'");

                var idxVal = basic_evaluate_expression_v2(idxText);
                if (!is_real(idxVal)) {
                    show_debug_message("POSTFIX[ARRAY] ERROR: Index non-numeric from '" + idxText + "' → '" + string(idxVal) + "'. Pushing 0.");
                    array_push(stack, 0);
                    continue;
                }

                var arrVal = basic_array_get(arrName, idxVal); // your 1-based getter
                show_debug_message("POSTFIX[ARRAY]: " + arrName + "(" + string(idxVal) + ") → " + string(arrVal));
                array_push(stack, arrVal);
                continue;
            }
        }

        // -------------------------------------------------------
        // Numeric literal
        // -------------------------------------------------------
        if (is_numeric_string(trimmed)) {
            var num = real(trimmed);
            array_push(stack, num);
            show_debug_message("POSTFIX: Pushed number → " + string(num));
            continue;
        }

        // -------------------------------------------------------
        // Quoted string literal
        // -------------------------------------------------------
        if (string_length(trimmed) >= 2
        &&  string_char_at(trimmed, 1) == "\""
        &&  string_char_at(trimmed, string_length(trimmed)) == "\"") {
            var str = string_copy(trimmed, 2, string_length(trimmed) - 2);
            array_push(stack, str);
            show_debug_message("POSTFIX: Pushed quoted string literal → " + str);
            continue;
        }

        // -------------------------------------------------------
        // Operators
        // -------------------------------------------------------
        if (is_operator(token_upper)) {
            if (array_length(stack) < 2) {
                show_debug_message("? POSTFIX ERROR: Not enough operands for operator " + token_upper);
                return 0;
            }
            var b = array_pop(stack);
            var a = array_pop(stack);
            var result = 0;

            switch (token_upper) {
                case "+":  result = (is_string(a) || is_string(b)) ? string(a) + string(b) : a + b; break;
                case "-":
                    if (is_string(a)) a = real(a);
                    if (is_string(b)) b = real(b);
                    result = a - b; break;
				case "=":
				    // Equality comparison: BASIC IF x=5 then ...
				    if (is_string(a)) a = real(a);
				    if (is_string(b)) b = real(b);
				    result = (a == b) ? 1 : 0;
				    break;
                case "*":
                    if (is_string(a)) a = real(a);
                    if (is_string(b)) b = real(b);
                    result = a * b; break;
                case "/":
                    if (is_string(a)) a = real(a);
                    if (is_string(b)) b = real(b);
                    result = (b != 0) ? a / b : 0; break;
                case "%":
                case "MOD":
                    if (is_string(a)) a = real(a);
                    if (is_string(b)) b = real(b);
                    result = a mod b; break;
                case "^":
                    if (is_string(a)) a = real(a);
                    if (is_string(b)) b = real(b);
                    result = power(a, b); break;
                default:
                    show_debug_message("? POSTFIX WARNING: Unknown operator = " + token_upper + " → 0");
                    result = 0; break;
            }

            array_push(stack, result);
            show_debug_message("POSTFIX: Operator result (" + token_upper + ") = " + string(result));
            continue;
        }

        // -------------------------------------------------------
        // Functions (numeric + string)
        // -------------------------------------------------------
        if (is_function(token_upper)) {
            // normalize again, just in case
            token_upper = string_upper(string_trim(token));
            show_debug_message("POSTFIX: Dispatching function → '" + token_upper + "'");

            switch (token_upper) {
                // ---- Random
                case "RND1": {
                    var n = safe_real_pop(stack);
                    if (n <= 0) n = 1;
                    var r1 = irandom(n - 1) + 1;
                    array_push(stack, r1);
                    show_debug_message("POSTFIX: RND1(" + string(n) + ") → " + string(r1));
                    break;
                }
                case "RND2": {
                    var max_val_raw = array_pop(stack);
                    var min_val_raw = array_pop(stack);

                    var min_val, max_val;

                    // --- Resolve min value ---
                    if (is_real(min_val_raw)) {
                        min_val = min_val_raw;
                    } else if (ds_map_exists(global.basic_variables, min_val_raw) && is_real(global.basic_variables[? min_val_raw])) {
                        min_val = global.basic_variables[? min_val_raw];
                    } else {
                        min_val = undefined;
                    }

                    // --- Resolve max value ---
                    if (is_real(max_val_raw)) {
                        max_val = max_val_raw;
                    } else if (ds_map_exists(global.basic_variables, max_val_raw) && is_real(global.basic_variables[? max_val_raw])) {
                        max_val = global.basic_variables[? max_val_raw];
                    } else {
                        max_val = undefined;
                    }

                    // --- Validate ---
                    if (!is_real(min_val) || !is_real(max_val)) {
                        // Show on screen without triggering tokenization
                        basic_system_message(
                            "ERROR: RND(min,max) requires numeric arguments — got '" 
                            + string(min_val_raw) + "', '" + string(max_val_raw) + "'"
                        );
                        array_push(stack, 0); // keep evaluation alive
                    } else {
                        var result = irandom_range(min_val, max_val);
                        array_push(stack, result);
                        show_debug_message("POSTFIX: RND2(" + string(min_val) + "," + string(max_val) + ") → " + string(result));
                    }
                    break;
                }

                // ---- Math
                case "ABS": array_push(stack, abs(safe_real_pop(stack))); break;
                case "EXP": array_push(stack, exp(safe_real_pop(stack))); break;

                // Preserving your prior semantics: LOG & LOG10 both as base-10
                case "LOG":
                case "LOG10": {
                    var v = safe_real_pop(stack);
                    array_push(stack, (ln(v) / ln(10)));
                    break;
                }

                case "SGN": {
                    var vsgn = safe_real_pop(stack);
                    var sgnv = (vsgn > 0) - (vsgn < 0);
                    array_push(stack, sgnv);
                    show_debug_message("POSTFIX: SGN(" + string(vsgn) + ") → " + string(sgnv));
                    break;
                }

                case "INT": array_push(stack, floor(safe_real_pop(stack))); break;
                case "SIN": array_push(stack, sin(safe_real_pop(stack)));   break;
                case "COS": array_push(stack, cos(safe_real_pop(stack)));   break;
                case "TAN": array_push(stack, tan(safe_real_pop(stack)));   break;

                // ---- String conversions
                case "STR$": {
                    var vstr = safe_real_pop(stack);
                    var s = string(vstr);
                    array_push(stack, s);
                    show_debug_message("POSTFIX: STR$ → " + s);
                    break;
                }
                case "CHR$": {
                    var cv = safe_real_pop(stack);
                    var c  = chr(cv);
                    array_push(stack, c);
                    show_debug_message("POSTFIX: CHR$ → " + c);
                    break;
                }

                // ---- String functions we added
                case "REPEAT$": {
                    // Stack top: n ; below: s$
                    var nrep = floor(safe_real_pop(stack));
                    var srep = string(array_pop(stack));
                    if (nrep < 0) nrep = 0;

                    var max_out = 65535;
                    var unit = max(1, string_length(srep));
                    if (unit * nrep > max_out) nrep = floor(max_out / unit);

                    var outrep = "";
                    repeat (nrep) outrep += srep;
                    array_push(stack, outrep);
                    show_debug_message("POSTFIX: REPEAT$('"+srep+"', "+string(nrep)+") → len="+string(string_length(outrep)));
                    break;
                }

                case "LEFT$": {
                    // Stack top: n ; below: s$
                    var nleft = floor(safe_real_pop(stack));
                    var sleft = string(array_pop(stack));
                    if (nleft < 0) nleft = 0;

                    var outleft = (nleft <= 0) ? "" : string_copy(sleft, 1, nleft);
                    array_push(stack, outleft);
                    show_debug_message("POSTFIX: LEFT$('"+sleft+"', "+string(nleft)+") → '"+outleft+"'");
                    break;
                }

                case "RIGHT$": {
                    // Stack top: n ; below: s$
                    var nright = floor(safe_real_pop(stack));
                    var sright = string(array_pop(stack));
                    if (nright < 0) nright = 0;

                    var lenr = string_length(sright);
                    var start = max(1, lenr - nright + 1);
                    var outright = (nright <= 0) ? "" : string_copy(sright, start, nright);
                    array_push(stack, outright);
                    show_debug_message("POSTFIX: RIGHT$('"+sright+"', "+string(nright)+") → '"+outright+"'");
                    break;
                }

                case "MID$": {
                    // Stack top: len ; below: start ; below: s$
                    // 1-based BASIC semantics
                    var lmid = floor(safe_real_pop(stack));
                    var smid = floor(safe_real_pop(stack));
                    var strm = string(array_pop(stack));

                    if (lmid < 0) lmid = 0;
                    if (smid < 1) smid = 1;

                    var outm = "";
                    if (lmid > 0 && smid <= string_length(strm)) {
                        outm = string_copy(strm, smid, lmid);
                    }
                    array_push(stack, outm);
                    show_debug_message("POSTFIX: MID$('"+strm+"', "+string(smid)+", "+string(lmid)+") → '"+outm+"'");
                    break;
                }

                default:
                    show_debug_message("? POSTFIX WARNING: Unknown function = " + token_upper + " — pushing last real as fallback");
                    array_push(stack, safe_real_pop(stack));
                    break;
            }

            continue;
        }

        // -------------------------------------------------------
        // Scalar variable fallback
        // -------------------------------------------------------
        if (ds_map_exists(global.basic_variables, token_upper)) {
            var vv = global.basic_variables[? token_upper];
            if (is_string(vv) && string_length(vv) == 0) vv = 0;
            array_push(stack, vv);
            show_debug_message("POSTFIX: Loaded variable " + token_upper + " = " + string(vv));
            continue;
        }

        // -------------------------------------------------------
        // Fallback: push as string literal (unknown token)
        // -------------------------------------------------------
        array_push(stack, trimmed);
        show_debug_message("POSTFIX: Pushed fallback string → " + trimmed);
    }

    // Return the TOP of the stack (final value), else 0
    return (array_length(stack) > 0) ? stack[array_length(stack) - 1] : 0;
}