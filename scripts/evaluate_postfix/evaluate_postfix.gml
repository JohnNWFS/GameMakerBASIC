/// @script evaluate_postfix
/// @description Evaluate a postfix token array, with support for 1-D arrays.
/// Notes:
/// - Array tokens arrive as a single atom like "D(I)" because infix_to_postfix collapses NAME(...).
/// - We defensively avoid treating built-in functions as arrays (e.g., "INT(5)").
/// - Comma tokens are ignored completely.
/// - Returns the TOP of the stack (last pushed), else 0.

function evaluate_postfix(postfix) {
    var stack = [];
    dbg_log(DBG_PARSE, "Evaluating postfix: " + string(postfix));

    for (var i = 0; i < array_length(postfix); i++) {
        var token = postfix[i];
        dbg_log(DBG_PARSE, "POSTFIX: Processing token [" + string(i) + "] → " + string(token));

        // Normalize once
        var trimmed     = string_trim(string(token));
        var token_upper = string_upper(trimmed);

        // -------------------------------------------------------
        // Ignore commas completely (arg separators, never values)
        // -------------------------------------------------------
        if (trimmed == ",") {
            dbg_log(DBG_PARSE, "POSTFIX: Ignoring stray comma token");
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

            // MINIMAL CHANGE: also skip STRING$ here even if is_function() doesn't know it
            if (!is_function(arrNameU) && arrNameU != "STRING$") {
                var arrName = arrNameU; // arrays stored uppercase in helpers
                var idxText = string_trim(idxTextRaw);

                dbg_log(DBG_PARSE, "POSTFIX[ARRAY]: Candidate '" + string(token) + "' → name='" + arrName + "', idxText='" + idxText + "'");

                // Check for multi-dimensional index (top-level commas in idxText)
                var _has_top_comma = false;
                {
                    var _dl = 0; var _dq = false;
                    for (var _ci = 1; _ci <= string_length(idxText); _ci++) {
                        var _cc = string_char_at(idxText, _ci);
                        if (_cc == "\"") _dq = !_dq;
                        if (!_dq) {
                            if (_cc == "(") _dl++;
                            else if (_cc == ")") _dl = max(0, _dl - 1);
                            else if (_cc == "," && _dl == 0) { _has_top_comma = true; break; }
                        }
                    }
                }

                if (_has_top_comma) {
                    // Multi-dim: evaluate each index expression, join with ","
                    var _idx_parts = basic_split_top_commas(idxText);
                    var _idx_joined = "";
                    var _ok = true;
                    for (var _di = 0; _di < array_length(_idx_parts); _di++) {
                        var _iv = basic_evaluate_expression_v2(_idx_parts[_di]);
                        if (!basic_is_number_val(_iv)) { _ok = false; break; }
                        if (_di > 0) _idx_joined += ",";
                        _idx_joined += string(floor(real(_iv)));
                    }
                    if (!_ok) {
                        array_push(stack, 0);
                        continue;
                    }
                    var arrVal = basic_array_get(arrName, _idx_joined);
                    dbg_log(DBG_PARSE, "POSTFIX[ARRAY multi-dim]: " + arrName + "(" + _idx_joined + ") → " + string(arrVal));
                    array_push(stack, arrVal);
                    continue;
                }

                var idxVal = basic_evaluate_expression_v2(idxText);
                if (!basic_is_number_val(idxVal)) {
                    dbg_log(DBG_PARSE, "POSTFIX[ARRAY] ERROR: Index non-numeric from '" + idxText + "' → '" + string(idxVal) + "'. Pushing 0.");
                    array_push(stack, 0);
                    continue;
                }

                var arrVal = basic_array_get(arrName, idxVal); // 1-based getter
                dbg_log(DBG_PARSE, "POSTFIX[ARRAY]: " + arrName + "(" + string(idxVal) + ") → " + string(arrVal));
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
            dbg_log(DBG_PARSE, "POSTFIX: Pushed number → " + string(num));
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
            if (dbg_on(DBG_FLOW)) dbg_log(DBG_PARSE, "POSTFIX: Pushed quoted string literal → " + str);
            continue;
        }

		// -------------------------------------------------------
		// Operators
		// -------------------------------------------------------
		if (is_operator(token_upper)) {
		    // NOT is unary — pops one operand only
		    if (token_upper == "NOT") {
		        if (array_length(stack) < 1) { dbg_log(DBG_PARSE, "? POSTFIX ERROR: NOT with empty stack"); array_push(stack, 0); continue; }
		        var _operand = array_pop(stack);
		        var _truthy  = is_real(_operand) ? (_operand != 0) : (string_length(string(_operand)) > 0);
		        array_push(stack, _truthy ? 0 : 1);
		        dbg_log(DBG_PARSE, "POSTFIX: NOT " + string(_operand) + " → " + string(_truthy ? 0 : 1));
		        continue;
		    }
		    if (array_length(stack) < 2) {
		        dbg_log(DBG_PARSE, "? POSTFIX ERROR: Not enough operands for operator " + token_upper);
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
		            result = a - b;
		            break;

case "=": {
    var an = basic_is_number_val(a) || (is_string(a) && string_length(a) > 0 && is_numeric_string(a));
    var bn = basic_is_number_val(b) || (is_string(b) && string_length(b) > 0 && is_numeric_string(b));

    if (an && bn) {
        result = (basic_coerce_number(a) == basic_coerce_number(b)) ? 1 : 0;
    } else {
        result = (string(a) == string(b)) ? 1 : 0;
    }
    break;
}

		        // NEW: all other comparisons must live here (not in the function switch)
		        case "<>": {
		            // numeric compare if both are numbers; otherwise string compare
		            if (is_real(a) && is_real(b)) result = (a != b) ? 1 : 0;
		            else                          result = (string(a) != string(b)) ? 1 : 0;
		            break;
		        }
		        case "<": {
		            if (is_string(a)) a = real(a);
		            if (is_string(b)) b = real(b);
		            result = (a < b) ? 1 : 0;
		            break;
		        }
		        case ">": {
		            if (is_string(a)) a = real(a);
		            if (is_string(b)) b = real(b);
		            result = (a > b) ? 1 : 0;
		            break;
		        }
		        case "<=": {
		            if (is_string(a)) a = real(a);
		            if (is_string(b)) b = real(b);
		            result = (a <= b) ? 1 : 0;
		            break;
		        }
		        case ">=": {
		            if (is_string(a)) a = real(a);
		            if (is_string(b)) b = real(b);
		            result = (a >= b) ? 1 : 0;
		            break;
		        }

		        case "*":
		            if (is_string(a)) a = real(a);
		            if (is_string(b)) b = real(b);
		            result = a * b;
		            break;

		        case "/":
		            if (is_string(a)) a = real(a);
		            if (is_string(b)) b = real(b);
		            result = (b != 0) ? a / b : 0;
		            break;

		        case "\\": { // integer division → truncate toward ZERO
		            if (is_string(a) && is_numeric_string(a)) a = real(a);
		            if (is_string(b) && is_numeric_string(b)) b = real(b);

		            if (!is_real(a) || !is_real(b)) {
		                basic_syntax_error("Integer division '\\' expects numbers; got a=" + string(a) + ", b=" + string(b),
		                    global.current_line_number, global.interpreter_current_stmt_index, "TYPE_MISMATCH");
		                result = 0; break;
		            }
		            if (b == 0) {
		                basic_syntax_error("Division by zero in '\\'",
		                    global.current_line_number, global.interpreter_current_stmt_index, "DIV_ZERO");
		                result = 0; break;
		            }

		            var q = a / b;
		            q = (q >= 0) ? floor(q) : ceil(q); // trunc-to-zero
		            result = q;
		            break;
		        }

		        case "%":
		        case "MOD":
		            if (is_string(a)) a = real(a);
		            if (is_string(b)) b = real(b);
		            result = a mod b;
		            break;

		        case "^":
		            if (is_string(a)) a = real(a);
		            if (is_string(b)) b = real(b);
		            result = power(a, b);
		            break;

case "AND": {
    // Don't pop again - use the a,b already popped above
    var tb = is_real(b) ? (b != 0) : (string_length(string(b)) > 0);
    var ta = is_real(a) ? (a != 0) : (string_length(string(a)) > 0);
    
    result = (ta && tb) ? 1 : 0;
    break;
}
case "OR": {
    // Don't pop again - use the a,b already popped above  
    var tb = is_real(b) ? (b != 0) : (string_length(string(b)) > 0);
    var ta = is_real(a) ? (a != 0) : (string_length(string(a)) > 0);
    
    result = (ta || tb) ? 1 : 0;
    break;
}

		        default:
		            dbg_log(DBG_PARSE, "? POSTFIX WARNING: Unknown operator = " + token_upper + " → 0");
		            result = 0;
		            break;
		    }

		    array_push(stack, result);
		    dbg_log(DBG_PARSE, "POSTFIX: Operator result (" + token_upper + ") = " + string(result));
		    continue;
		}


        // -------------------------------------------------------
        // Functions (numeric + string)
        // -------------------------------------------------------
        if (is_function(token_upper) || token_upper == "STRING$") {
            token_upper = string_upper(string_trim(token));
            dbg_log(DBG_PARSE, "POSTFIX: Dispatching function → '" + token_upper + "'");

            switch (token_upper) {

                // ---- Random
                case "RND1": {
                    var n = safe_real_pop(stack);
                    if (n <= 0) n = 1;
                    var r1;
                    if (n == 1) {
                        // Classic BASIC: RND(1) returns 0.0 to 0.999...
                        r1 = random(1);
                    } else {
                        // Integer range: RND(6) returns 1-6
                        r1 = irandom(n - 1) + 1;
                    }
                    array_push(stack, r1);
                    dbg_log(DBG_PARSE, "POSTFIX: RND1(" + string(n) + ") → " + string(r1));
                    break;
                }

                case "RND2": {
                    var max_val_raw = array_pop(stack);
                    var min_val_raw = array_pop(stack);
                    var min_val, max_val;

                    if (is_real(min_val_raw)) {
                        min_val = min_val_raw;
                    } else if (basic_var_exists(min_val_raw) && is_real(basic_var_get(min_val_raw))) {
                        min_val = basic_var_get(min_val_raw);
                    } else {
                        min_val = undefined;
                    }

                    if (is_real(max_val_raw)) {
                        max_val = max_val_raw;
                    } else if (basic_var_exists(max_val_raw) && is_real(basic_var_get(max_val_raw))) {
                        max_val = basic_var_get(max_val_raw);
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
                        dbg_log(DBG_PARSE, "POSTFIX: RND2(" + string(min_val) + "," + string(max_val) + ") → " + string(result));
                    }
                    break;
                }

                // ---- NEW: Zero-arg time/keyboard functions ----
                case "TIMER": {
                    var secs = floor(current_time / 1000); // ms → seconds since game start
                    array_push(stack, secs);
                    dbg_log(DBG_PARSE, "FUNC: TIMER → " + string(secs));
                    break;
                }
				
				case "LEN": {
				    var s = string(array_pop(stack));
				    array_push(stack, string_length(s));
				    dbg_log(DBG_PARSE, "POSTFIX: LEN('" + s + "') → " + string(string_length(s)));
				    break;
				}
				
                case "TIME$": {
                    var dt  = date_current_datetime();
                    var hh  = date_get_hour(dt);
                    var mm  = date_get_minute(dt);
                    var ss  = date_get_second(dt);
                    var hhs = (hh < 10 ? "0" : "") + string(hh);
                    var mms = (mm < 10 ? "0" : "") + string(mm);
                    var sss = (ss < 10 ? "0" : "") + string(ss);
                    var out = hhs + ":" + mms + ":" + sss;
                    array_push(stack, out);
                    dbg_log(DBG_PARSE, "FUNC: TIME$ → " + out);
                    break;
                }
                case "DATE$": {
                    var dt2 = date_current_datetime();
                    var yy  = date_get_year(dt2);
                    var mo  = date_get_month(dt2);
                    var dd  = date_get_day(dt2);
                    var mos = (mo < 10 ? "0" : "") + string(mo);
                    var dds = (dd < 10 ? "0" : "") + string(dd);
                    var out2 = string(yy) + "-" + mos + "-" + dds;
                    array_push(stack, out2);
                    dbg_log(DBG_PARSE, "FUNC: DATE$ → " + out2);
                    break;
                }

                case "INKEY$": {
                    dbg_log(DBG_PARSE, "INKEY$ function: Processing INKEY$ token");

                    if (!variable_global_exists("__inkey_queue") || !ds_exists(global.__inkey_queue, ds_type_queue)) {
                        dbg_log(DBG_PARSE, "INKEY$ function: creating global.__inkey_queue");
                        global.__inkey_queue = ds_queue_create();
                    }

                    var _res = "";
                    if (ds_queue_size(global.__inkey_queue) > 0) {
                        var _ch = ds_queue_dequeue(global.__inkey_queue);
                        if (is_real(_ch)) _ch = chr(_ch);
                        _res = string(_ch);
                        if (dbg_on(DBG_PARSE)) show_debug_message(
                            "INKEY$ function: Dequeued '" + _res + "', queue size now = " + string(ds_queue_size(global.__inkey_queue))
                        );
                    } else {
                        dbg_log(DBG_PARSE, "INKEY$ function: Queue empty → returning empty string");
                    }

                    if (dbg_on(DBG_PARSE)) {
                        var _len = string_length(_res);
                        var _a1  = (_len >= 1) ? ord(string_char_at(_res, 1)) : -1;
                        var _a2  = (_len >= 2) ? ord(string_char_at(_res, 2)) : -1;
                        if (dbg_on(DBG_FLOW)) show_debug_message("##INK## LEN=" + string(_len)
                            + " A1=" + string(_a1)
                            + " A2=" + string(_a2)
                            + " K$='" + _res + "'");
                    }

                    array_push(stack, _res);
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
                    dbg_log(DBG_PARSE, "POSTFIX: SGN(" + string(vsgn) + ") → " + string(sgnv));
                    break;
                }

                case "INT": array_push(stack, floor(safe_real_pop(stack))); break;
                case "SIN": array_push(stack, sin(safe_real_pop(stack)));   break;
                case "COS": array_push(stack, cos(safe_real_pop(stack)));   break;
                case "TAN": array_push(stack, tan(safe_real_pop(stack)));   break;
                case "SQR": array_push(stack, sqrt(safe_real_pop(stack)));  break;
                case "ATN": array_push(stack, arctan(safe_real_pop(stack))); break;

                case "SPACE$": {
                    var nsp = max(0, floor(safe_real_pop(stack)));
                    array_push(stack, string_repeat(" ", nsp));
                    break;
                }
                case "UCASE$": array_push(stack, string_upper(string(array_pop(stack)))); break;
                case "LCASE$": array_push(stack, string_lower(string(array_pop(stack)))); break;
                case "LTRIM$": {
                    var _s = string(array_pop(stack));
                    var _i = 1;
                    while (_i <= string_length(_s) && string_char_at(_s, _i) == " ") _i++;
                    array_push(stack, string_copy(_s, _i, string_length(_s) - _i + 1));
                    break;
                }
                case "RTRIM$": {
                    var _s = string(array_pop(stack));
                    var _i = string_length(_s);
                    while (_i >= 1 && string_char_at(_s, _i) == " ") _i--;
                    array_push(stack, string_copy(_s, 1, _i));
                    break;
                }

                case "INSTR": {
                    var needle   = string(array_pop(stack));
                    var haystack = string(array_pop(stack));
                    var pos = string_pos(needle, haystack);
                    array_push(stack, pos);
                    break;
                }

                case "GETMODE":
                case "SCREEN": array_push(stack, global.current_mode); break;

                case "POINT": {
                    var _py = floor(safe_real_pop(stack));
                    var _px = floor(safe_real_pop(stack));
                    var _col = -1;
                    if (variable_global_exists("mode2_surface") && surface_exists(global.mode2_surface)) {
                        _col = surface_getpixel(global.mode2_surface, _px, _py);
                    }
                    array_push(stack, _col);
                    dbg_log(DBG_PARSE, "POSTFIX: POINT(" + string(_px) + "," + string(_py) + ") → " + string(_col));
                    break;
                }

                case "EOF": {
                    var _eof_chan = floor(safe_real_pop(stack));
                    var _is_eof  = true;
                    if (variable_global_exists("basic_file_handles")
                        && ds_exists(global.basic_file_handles, ds_type_map)
                        && ds_map_exists(global.basic_file_handles, _eof_chan)) {
                        _is_eof = file_text_eof(global.basic_file_handles[? _eof_chan]);
                    }
                    array_push(stack, _is_eof ? -1 : 0);  // BASIC: -1 = TRUE, 0 = FALSE
                    dbg_log(DBG_PARSE, "POSTFIX: EOF(" + string(_eof_chan) + ") → " + string(_is_eof));
                    break;
                }

                // ---- String conversions
                case "STR$": {
                    var vstr = safe_real_pop(stack);
                    var s = string(vstr);
                    array_push(stack, s);
                    dbg_log(DBG_PARSE, "POSTFIX: STR$ → " + s);
                    break;
                }
				
                case "CHR$": {
                    var cv = safe_real_pop(stack);
                    var c  = chr(cv);
                    array_push(stack, c);
                    dbg_log(DBG_PARSE, "POSTFIX: CHR$ → " + c);
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
                    dbg_log(DBG_PARSE, "POSTFIX: REPEAT$('"+srep+"', "+string(nrep)+") → len="+string(string_length(outrep)));
                    break;
                }

                case "LEFT$": {
                    var nleft = floor(safe_real_pop(stack));
                    var sleft = string(array_pop(stack));
                    if (nleft < 0) nleft = 0;

                    var outleft = (nleft <= 0) ? "" : string_copy(sleft, 1, nleft);
                    array_push(stack, outleft);
                    dbg_log(DBG_PARSE, "POSTFIX: LEFT$('"+sleft+"', "+string(nleft)+") → '"+outleft+"'");
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
                    dbg_log(DBG_PARSE, "POSTFIX: RIGHT$('"+sright+"', "+string(nright)+") → '"+outright+"'");
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
                    dbg_log(DBG_PARSE, "POSTFIX: MID$('"+strm+"', "+string(smid)+", "+string(lmid)+") → '"+outm+"'");
                    break;
                }

                case "ASC": {
                    var s = string(array_pop(stack));            // ensure string
                    var r = (string_length(s) >= 1) ? ord(string_char_at(s, 1)) : 0;
                    array_push(stack, r);
                    dbg_log(DBG_PARSE, "POSTFIX: ASC('" + s + "') → " + string(r));
                    break;
                }

                case "VAL": {
                    var raw_val = string_trim(string(array_pop(stack)));
                    var num_text = "";
                    var saw_digit = false;
                    var saw_dot = false;

                    for (var vi = 1; vi <= string_length(raw_val); vi++) {
                        var vc = string_char_at(raw_val, vi);
                        var vo = ord(vc);
                        if (vi == 1 && (vc == "+" || vc == "-")) {
                            num_text += vc;
                        } else if (vo >= 48 && vo <= 57) {
                            num_text += vc;
                            saw_digit = true;
                        } else if (vc == "." && !saw_dot) {
                            num_text += vc;
                            saw_dot = true;
                        } else {
                            break;
                        }
                    }

                    var val_result = saw_digit ? real(num_text) : 0;
                    array_push(stack, val_result);
                    dbg_log(DBG_PARSE, "POSTFIX: VAL('" + raw_val + "') → " + string(val_result));
                    break;
                }

                case "MODE1_GET_CHAR": {
                    var row = safe_real_pop(stack);
                    var col = safe_real_pop(stack);
                    var chv = mode1_get_char(col, row);
                    array_push(stack, chv);
                    dbg_log(DBG_PARSE, "POSTFIX: MODE1_GET_CHAR(" + string(col) + "," + string(row) + ") → " + string(chv));
                    break;
                }

                case "TILECHAR": {
                    var tile_row = safe_real_pop(stack);
                    var tile_col = safe_real_pop(stack);
                    var tile_ch = mode1_get_char(tile_col, tile_row);
                    array_push(stack, tile_ch);
                    dbg_log(DBG_PARSE, "POSTFIX: TILECHAR(" + string(tile_col) + "," + string(tile_row) + ") → " + string(tile_ch));
                    break;
                }

                case "MODE1_GET_COLOR": {
                    var rowc = safe_real_pop(stack);
                    var colc = safe_real_pop(stack);
                    var cvm = mode1_get_color(colc, rowc);
                    array_push(stack, cvm);
                    dbg_log(DBG_PARSE, "POSTFIX: MODE1_GET_COLOR(" + string(colc) + "," + string(rowc) + ") → " + string(cvm));
                    break;
                }

                case "TILECOLOR": {
                    var tile_rowc = safe_real_pop(stack);
                    var tile_colc = safe_real_pop(stack);
                    var tile_c = mode1_get_color(tile_colc, tile_rowc);
                    array_push(stack, tile_c);
                    dbg_log(DBG_PARSE, "POSTFIX: TILECOLOR(" + string(tile_colc) + "," + string(tile_rowc) + ") → " + string(tile_c));
                    break;
                }

                case "TILEBIT": {
                    var bit_y = safe_real_pop(stack);
                    var bit_x = safe_real_pop(stack);
                    var bit_code = safe_real_pop(stack);
                    var bit_val = custom_tile_get_bit(bit_code, bit_x, bit_y);
                    array_push(stack, bit_val);
                    dbg_log(DBG_PARSE, "POSTFIX: TILEBIT(" + string(bit_code) + "," + string(bit_x) + "," + string(bit_y) + ") → " + string(bit_val));
                    break;
                }

                case "MODE1_COLOR_NAME": {
                    var color_value = safe_real_pop(stack);
                    var cname = mode1_color_name(color_value);
                    array_push(stack, cname);
                    dbg_log(DBG_PARSE, "POSTFIX: MODE1_COLOR_NAME(" + string(color_value) + ") → " + cname);
                    break;
                }

                case "TILENAME$": {
                    var tile_color_value = safe_real_pop(stack);
                    var tile_cname = mode1_color_name(tile_color_value);
                    array_push(stack, tile_cname);
                    dbg_log(DBG_PARSE, "POSTFIX: TILENAME$(" + string(tile_color_value) + ") → " + tile_cname);
                    break;
                }

                // ---- NEW: STRING$(x, n) ----
                case "STRING$": {
                    // Postfix order from infix handler: push x, push n, then STRING$
                    var n = array_pop(stack);
                    var _x = array_pop(stack);

                    // normalize n
                    var count = max(0, floor(is_real(n) ? n : real(n)));

                    // determine a single character from _x
                    var ch;
                    if (is_string(_x)) {
                        ch = (string_length(_x) > 0) ? string_copy(_x, 1, 1) : " ";
                    } else {
                        var code = clamp(floor(real(_x)), 0, 255);
                        ch = chr(code);
                    }

                    var out = "";
                    repeat (count) out += ch;

                    array_push(stack, out);
                    dbg_log(DBG_PARSE, "POSTFIX: STRING$(" + string(_x) + "," + string(count) + ") → len=" + string(string_length(out)));
                    break;
                }

			


                // ── Sprite query functions ─────────────────────────────────
                case "SPRITEX": {
                    var _sn = safe_real_pop(stack);
                    array_push(stack, bas_sprite_fn_x(_sn));
                    break;
                }
                case "SPRITEY": {
                    var _sn = safe_real_pop(stack);
                    array_push(stack, bas_sprite_fn_y(_sn));
                    break;
                }
                case "SPRITEHIT": {
                    var _sm = safe_real_pop(stack);
                    var _sn = safe_real_pop(stack);
                    array_push(stack, bas_sprite_fn_hit(_sn, _sm));
                    break;
                }

                default:
                    dbg_log(DBG_PARSE, "? POSTFIX WARNING: Unknown function = " + token_upper + " — pushing last real as fallback");
                    array_push(stack, safe_real_pop(stack));
                    break;
            }

            continue;
        }

			// -------------------------------------------------------
			// Scalar variable load (string vars stay strings; numeric vars coerce)
			// -------------------------------------------------------
			if (basic_var_exists(token_upper)) {
			    var vv = basic_var_get(token_upper);

			    var is_string_var = (string_char_at(token_upper, string_length(token_upper)) == "$");

			    if (is_string_var) {
			        // String variables ALWAYS behave as strings (QBASIC semantics)
			        if (is_undefined(vv)) vv = "";
			        vv = string(vv); // ensure string; do not numeric-coerce
			    } else {
			        vv = basic_coerce_number(vv, 0);
			    }

			    array_push(stack, vv);

			    if (dbg_on(DBG_PARSE)) {
			        var _tag = is_string_var ? "[S]" : "[N]";
			        show_debug_message("POSTFIX: Loaded variable " + token_upper + " " + _tag + " = " + string(vv));
			    }
			    continue;
			}


       // -------------------------------------------------------
		// Fallback: IDENT or literal
		// -------------------------------------------------------
		var ident = trimmed;

		// If this looks like an identifier (A..Z start) and it’s not in the map,
		// treat it as an undeclared numeric variable (default 0).
		var first = string_upper(string_char_at(ident, 1));
		var oc = ord(first);
		var looks_ident = (oc >= 65 && oc <= 90); // A..Z

		if (looks_ident) {
		    var key = string_upper(ident);
		    if (!basic_var_exists(key)) {
		        // Check color name constants before creating as 0
		        var _named_col = basic_color_named_get(key);
		        if (!is_undefined(_named_col)) {
		            array_push(stack, _named_col);
		            dbg_log(DBG_PARSE, "POSTFIX: Color constant '" + key + "' = " + string(_named_col));
		            continue;
		        }
		        basic_var_set(key, 0);
		        dbg_log(DBG_PARSE, "POSTFIX: Implicit numeric var created '" + key + "' = 0");
		    }
		    var vv = basic_var_get(key);

		    // coerce type by suffix: $ means string var
		    if (string_char_at(key, string_length(key)) == "$") {
		        if (is_undefined(vv)) vv = "";
		        if (!is_string(vv))  vv = string(vv);
		    } else {
		        vv = basic_coerce_number(vv, 0);
		    }
		    array_push(stack, vv);
		    dbg_log(DBG_PARSE, "POSTFIX: Loaded/created ident " + key + " = " + string(vv));
		} else {
		    var _lit_col = basic_parse_color(trimmed, noone);
		    if (_lit_col != noone) {
		        array_push(stack, _lit_col);
		        dbg_log(DBG_PARSE, "POSTFIX: Color literal '" + trimmed + "' = " + string(_lit_col));
		    } else {
		        array_push(stack, trimmed);
		        dbg_log(DBG_PARSE, "POSTFIX: Pushed fallback string → " + trimmed);
		    }
		}

    }

    return (array_length(stack) > 0) ? stack[array_length(stack) - 1] : 0;
}
