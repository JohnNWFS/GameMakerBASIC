/// @script evaluate_postfix
/// @description Evaluate a postfix token array, with support for 1-D arrays.
/// Notes:
/// - Array tokens arrive as a single atom like "D(I)" because infix_to_postfix collapses NAME(...).
/// - We defensively avoid treating built-in functions as arrays (e.g., "INT(5)").
/// - Comma tokens are ignored completely.
/// - Returns the TOP of the stack (last pushed), else 0.

function evaluate_postfix(postfix) {
    var stack = [];
    if (dbg_on(DBG_PARSE)) show_debug_message("Evaluating postfix: " + string(postfix));

    for (var i = 0; i < array_length(postfix); i++) {
        var token = postfix[i];
        if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: Processing token [" + string(i) + "] → " + string(token));

        // Normalize once
        var trimmed     = string_trim(string(token));
        var token_upper = string_upper(trimmed);

        // -------------------------------------------------------
        // Ignore commas completely (arg separators, never values)
        // -------------------------------------------------------
        if (trimmed == ",") {
            if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: Ignoring stray comma token");
            continue;
        }

        // -------------------------------------------------------
        // ARRAY READ SUPPORT (atom form: NAME(index_expr))
        // -------------------------------------------------------
        var openPos = string_pos("(", token_upper);
        if (openPos > 0 && string_char_at(token_upper, string_length(token_upper)) == ")") {
            var arrNameU   = string_copy(token_upper, 1, openPos - 1);
            var innerLen   = string_length(token) - openPos - 1;
            var idxTextRaw = string_copy(token, openPos + 1, innerLen);

            if (!is_function(arrNameU)) {
                var arrName = arrNameU; // arrays stored uppercase in helpers
                var idxText = string_trim(idxTextRaw);

                if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX[ARRAY]: Candidate '" + string(token) + "' → name='" + arrName + "', idxText='" + idxText + "'");

                var idxVal = basic_evaluate_expression_v2(idxText);
                if (!is_real(idxVal)) {
                    if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX[ARRAY] ERROR: Index non-numeric from '" + idxText + "' → '" + string(idxVal) + "'. Pushing 0.");
                    array_push(stack, 0);
                    continue;
                }

                var arrVal = basic_array_get(arrName, idxVal); // your 1-based getter
                if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX[ARRAY]: " + arrName + "(" + string(idxVal) + ") → " + string(arrVal));
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
            if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: Pushed number → " + string(num));
            continue;
        }

        // -------------------------------------------------------
        // Quoted string literal
        // -------------------------------------------------------
        if (string_length(trimmed) >= 2
        &&  string_char_at(trimmed, 1) == "\""
        &&  string_char_at(trimmed, string_length(trimmed)) == "\"")
        {
            var str = string_copy(trimmed, 2, string_length(trimmed) - 2);
            str = string_replace_all(str, "\"\"", "\"");  // unescape "" -> "
            array_push(stack, str);
            if (dbg_on(DBG_FLOW)) if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: Pushed quoted string literal → " + str);
            continue;
        }

        // -------------------------------------------------------
        // Operators
        // -------------------------------------------------------
        if (is_operator(token_upper)) {
            if (array_length(stack) < 2) {
                if (dbg_on(DBG_PARSE)) show_debug_message("? POSTFIX ERROR: Not enough operands for operator " + token_upper);
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
                    if (dbg_on(DBG_PARSE)) show_debug_message("? POSTFIX WARNING: Unknown operator = " + token_upper + " → 0");
                    result = 0; break;
            }

            array_push(stack, result);
            if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: Operator result (" + token_upper + ") = " + string(result));
            continue;
        }

        // -------------------------------------------------------
        // Functions (numeric + string)
        // -------------------------------------------------------
        if (is_function(token_upper)) {
            token_upper = string_upper(string_trim(token));
            if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: Dispatching function → '" + token_upper + "'");

            switch (token_upper) {
                // ---- Random
                case "RND1": {
                    var n = safe_real_pop(stack);
                    if (n <= 0) n = 1;
                    var r1 = irandom(n - 1) + 1;
                    array_push(stack, r1);
                    if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: RND1(" + string(n) + ") → " + string(r1));
                    break;
                }
                case "RND2": {
                    var max_val_raw = array_pop(stack);
                    var min_val_raw = array_pop(stack);
                    var min_val, max_val;

                    if (is_real(min_val_raw)) {
                        min_val = min_val_raw;
                    } else if (ds_map_exists(global.basic_variables, min_val_raw) && is_real(global.basic_variables[? min_val_raw])) {
                        min_val = global.basic_variables[? min_val_raw];
                    } else {
                        min_val = undefined;
                    }

                    if (is_real(max_val_raw)) {
                        max_val = max_val_raw;
                    } else if (ds_map_exists(global.basic_variables, max_val_raw) && is_real(global.basic_variables[? max_val_raw])) {
                        max_val = global.basic_variables[? max_val_raw];
                    } else {
                        max_val = undefined;
                    }

                    if (!is_real(min_val) || !is_real(max_val)) {
                        basic_system_message("ERROR: RND(min,max) requires numeric arguments — got '" 
                            + string(min_val_raw) + "', '" + string(max_val_raw) + "'");
                        array_push(stack, 0);
                    } else {
                        var result = irandom_range(min_val, max_val);
                        array_push(stack, result);
                        if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: RND2(" + string(min_val) + "," + string(max_val) + ") → " + string(result));
                    }
                    break;
                }

                // ---- NEW: Zero-arg time/keyboard functions ----
                case "TIMER": {
                    var secs = floor(current_time / 1000); // ms → seconds since game start
                    array_push(stack, secs);
                    if (dbg_on(DBG_PARSE)) show_debug_message("FUNC: TIMER → " + string(secs));
                    break;
                }
                case "TIME$": {
                    // Build "HH:MM:SS" from parts (no date_format_* in GML)
                    var dt  = date_current_datetime();
                    var hh  = date_get_hour(dt);
                    var mm  = date_get_minute(dt);
                    var ss  = date_get_second(dt);
                    var hhs = (hh < 10 ? "0" : "") + string(hh);
                    var mms = (mm < 10 ? "0" : "") + string(mm);
                    var sss = (ss < 10 ? "0" : "") + string(ss);
                    var out = hhs + ":" + mms + ":" + sss;
                    array_push(stack, out);
                    if (dbg_on(DBG_PARSE)) show_debug_message("FUNC: TIME$ → " + out);
                    break;
                }
                case "DATE$": {
                    // Build "YYYY-MM-DD" from parts
                    var dt2 = date_current_datetime();
                    var yy  = date_get_year(dt2);
                    var mo  = date_get_month(dt2);
                    var dd  = date_get_day(dt2);
                    var mos = (mo < 10 ? "0" : "") + string(mo);
                    var dds = (dd < 10 ? "0" : "") + string(dd);
                    var out2 = string(yy) + "-" + mos + "-" + dds;
                    array_push(stack, out2);
                    if (dbg_on(DBG_PARSE)) show_debug_message("FUNC: DATE$ → " + out2);
                    break;
                }
				
				
// === 3. Modify your INKEY$ function case to just return the stored result ===
case "INKEY$": {
    var result = "";
    
    // Check if we have a stored result from the blocking input
    if (ds_map_exists(global.basic_variables, "__INKEY_RESULT")) {
        result = global.basic_variables[? "__INKEY_RESULT"];
        // Clear the result after reading it
        ds_map_delete(global.basic_variables, "__INKEY_RESULT");
        if (dbg_on(DBG_PARSE)) show_debug_message("INKEY$ function: Returning stored result '" + result + "'");
    } else {
        if (dbg_on(DBG_PARSE)) show_debug_message("INKEY$ function: No stored result, returning empty");
    }
    
    array_push(stack, result);
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
                    if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: SGN(" + string(vsgn) + ") → " + string(sgnv));
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
                    if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: STR$ → " + s);
                    break;
                }
                case "CHR$": {
                    var cv = safe_real_pop(stack);
                    var c  = chr(cv);
                    array_push(stack, c);
                    if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: CHR$ → " + c);
                    break;
                }

                // ---- String functions we added
                case "REPEAT$": {
                    var nrep = floor(safe_real_pop(stack));
                    var srep = string(array_pop(stack));
                    if (nrep < 0) nrep = 0;

                    var max_out = 65535;
                    var unit = max(1, string_length(srep));
                    if (unit * nrep > max_out) nrep = floor(max_out / unit);

                    var outrep = "";
                    repeat (nrep) outrep += srep;
                    array_push(stack, outrep);
                    if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: REPEAT$('"+srep+"', "+string(nrep)+") → len="+string(string_length(outrep)));
                    break;
                }

                case "LEFT$": {
                    var nleft = floor(safe_real_pop(stack));
                    var sleft = string(array_pop(stack));
                    if (nleft < 0) nleft = 0;

                    var outleft = (nleft <= 0) ? "" : string_copy(sleft, 1, nleft);
                    array_push(stack, outleft);
                    if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: LEFT$('"+sleft+"', "+string(nleft)+") → '"+outleft+"'");
                    break;
                }

                case "RIGHT$": {
                    var nright = floor(safe_real_pop(stack));
                    var sright = string(array_pop(stack));
                    if (nright < 0) nright = 0;

                    var lenr = string_length(sright);
                    var start = max(1, lenr - nright + 1);
                    var outright = (nright <= 0) ? "" : string_copy(sright, start, nright);
                    array_push(stack, outright);
                    if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: RIGHT$('"+sright+"', "+string(nright)+") → '"+outright+"'");
                    break;
                }

                case "MID$": {
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
                    if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: MID$('"+strm+"', "+string(smid)+", "+string(lmid)+") → '"+outm+"'");
                    break;
                }

                default:
                    if (dbg_on(DBG_PARSE)) show_debug_message("? POSTFIX WARNING: Unknown function = " + token_upper + " — pushing last real as fallback");
                    array_push(stack, safe_real_pop(stack));
                    break;
            }

            continue;
        }

        // -------------------------------------------------------
        // Scalar variable load (string vars keep "", numeric vars coerce)
        // -------------------------------------------------------
        if (ds_map_exists(global.basic_variables, token_upper)) {
            var vv = global.basic_variables[? token_upper];

            if (string_char_at(token_upper, string_length(token_upper)) == "$") {
                if (is_undefined(vv)) vv = "";
                if (!is_string(vv))  vv = string(vv);
            } else {
                if (is_string(vv)) {
                    vv = is_numeric_string(vv) ? real(vv) : 0;
                } else if (!is_real(vv)) {
                    vv = 0;
                }
            }

            array_push(stack, vv);
            if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: Loaded variable " + token_upper + " = " + string(vv));
            continue;
        }

        // -------------------------------------------------------
        // Fallback: push as string literal (unknown token)
        // -------------------------------------------------------
        array_push(stack, trimmed);
        if (dbg_on(DBG_PARSE)) show_debug_message("POSTFIX: Pushed fallback string → " + trimmed);
    }

    return (array_length(stack) > 0) ? stack[array_length(stack) - 1] : 0;
}
