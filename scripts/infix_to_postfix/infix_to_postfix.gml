/// @script infix_to_postfix
// === BEGIN: infix_to_postfix ===
function infix_to_postfix(tokens) {
    dbg_log(DBG_PARSE, "Converting to postfix: " + string(tokens));

    var output = [];
    var stack  = [];

    var _TOKU = function(_t) { return string_upper(string(_t)); };

    var _push_all = function(_dst, _src) {
        for (var __i = 0; __i < array_length(_src); __i++) array_push(_dst, _src[__i]);
    };

    var _is_zero_arg_fn = function(_name) {
        var n = string_upper(_name);
        return (n == "TIMER" || n == "TIME$" || n == "DATE$" || n == "INKEY$");
    };

    var _is_STRING_fn = function(_name) {
        return string_upper(string(_name)) == "STRING$";
    };

    // pass tokens explicitly so we don't rely on closure capture
    var _read_paren_payload = function(_tokens, _start) {
        var _depth = 0, j = _start, inner = "", matched = false;
        while (j < array_length(_tokens)) {
            var tk = _tokens[j];
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
        return [matched, inner, j];
    };

    for (var i = 0; i < array_length(tokens); i++) {
        var t  = tokens[i];

        if (t == ",") { dbg_log(DBG_PARSE, "INFIX: Skipping comma token"); continue; }

        var tu = _TOKU(t);

        // 1) ARRAY READ COLLAPSE
        if (is_string(t)) {
            var first = string_char_at(t, 1);
            var can_be_name = is_letter(first);

            if (can_be_name && i + 1 < array_length(tokens) && tokens[i + 1] == "("
            && !(is_function(t) || _is_STRING_fn(t))) {
                dbg_log(DBG_PARSE, "INFIX: Candidate for array collapse → '" + string(t) + "' followed by '('");
                var arr_info = _read_paren_payload(tokens, i + 1);
                var matched  = arr_info[0];
                var inner    = arr_info[1];
                var j        = arr_info[2];

                if (matched) {
                    var collapsed = string(t) + "(" + inner + ")";
                    array_push(output, collapsed);
                    dbg_log(DBG_PARSE, "INFIX: Collapsed array read token → '" + collapsed + "' (consumed through index " + string(j) + ")");
                    i = j;
                    continue;
                } else {
                    dbg_log(DBG_PARSE, "INFIX: WARNING — unmatched '(' after '" + string(t) + "'. Not collapsing.");
                }
            }
        }

        // 2) NUMERIC LITERAL
        if (is_numeric_string(t)) { array_push(output, t); dbg_log(DBG_PARSE, "Added number to output: " + string(t)); continue; }

        // 3) KNOWN VARIABLE
        if (basic_var_exists(tu)) { array_push(output, tu); dbg_log(DBG_PARSE, "Added variable name to output: " + tu); continue; }

        // 4) OPEN PAREN
        if (t == "(") { array_push(stack, t); dbg_log(DBG_PARSE, "Pushed '(' onto operator stack"); continue; }

        // 5) CLOSE PAREN
        if (t == ")") {
            while (array_length(stack) > 0 && stack[array_length(stack) - 1] != "(") {
                var popped_close = array_pop(stack);
                array_push(output, popped_close);
                dbg_log(DBG_PARSE, "Popped '" + string(popped_close) + "' from stack to output (closing ')')");
            }
            if (array_length(stack) > 0 && stack[array_length(stack) - 1] == "(") {
                array_pop(stack);
                dbg_log(DBG_PARSE, "Discarded matching '(' from stack");
            } else {
                dbg_log(DBG_PARSE, "INFIX: WARNING — stray ')' with no matching '('");
            }
            continue;
        }

        // 6) OPERATORS
        if (is_operator(t)) {
            dbg_log(DBG_PARSE, "Found operator: " + string(t));
            while (array_length(stack) > 0) {
                var top = stack[array_length(stack) - 1];
                if (is_operator(top) && (get_precedence(top) > get_precedence(t)
                || (get_precedence(top) == get_precedence(t) && !is_right_associative(t)))) {
                    var popped_op = array_pop(stack);
                    array_push(output, popped_op);
                    dbg_log(DBG_PARSE, "Popped higher/equal precedence operator '" + string(popped_op) + "' to output");
                } else break;
            }
            array_push(stack, t);
            dbg_log(DBG_PARSE, "Pushed operator '" + string(t) + "' onto stack");
            continue;
        }

        // 7) FUNCTIONS
        if (is_function(t) || _is_STRING_fn(t)) {
            var fn_name = tu;

            // Zero-arg functions emit directly
            if (_is_zero_arg_fn(fn_name)) {
                array_push(output, fn_name);
                dbg_log(DBG_PARSE, "Processed zero-arg function: " + fn_name);
                continue;
            }

            // Must be followed by '('
            if (!(i + 1 < array_length(tokens) && tokens[i + 1] == "(")) {
                array_push(output, fn_name);
                dbg_log(DBG_PARSE, "Function without '(': passing through → " + fn_name);
                continue;
            }

            // Read (...): pass tokens explicitly
            var f_info  = _read_paren_payload(tokens, i + 1);
            var f_ok    = f_info[0];
            var f_inner = f_info[1];
            var f_end   = f_info[2];

            if (!f_ok) {
                array_push(output, fn_name);
                dbg_log(DBG_PARSE, "WARNING: unmatched '(' for function " + fn_name + " — passing through");
                continue;
            }

            // ---------- SPECIAL: STRING$(x, n) ----------
            if (fn_name == "STRING$") {
                var lvl = 0, part = "", parts = [];
                for (var ci = 1; ci <= string_length(f_inner); ci++) {
                    var ch = string_char_at(f_inner, ci);
                    if (ch == "(") { lvl++; part += ch; }
                    else if (ch == ")") { lvl--; part += ch; }
                    else if (ch == "," && lvl == 0) { array_push(parts, string_trim(part)); part = ""; }
                    else { part += ch; }
                }
                array_push(parts, string_trim(part));

                if (array_length(parts) == 2) {
                    var t1 = basic_tokenize_expression_v2(parts[0]);
                    var t2 = basic_tokenize_expression_v2(parts[1]);
                    var p1 = infix_to_postfix(t1);
                    var p2 = infix_to_postfix(t2);
                    _push_all(output, p1);
                    _push_all(output, p2);
                    array_push(output, fn_name);
                    dbg_log(DBG_PARSE, "Processed STRING$(x,n): args = [" + parts[0] + "], [" + parts[1] + "]");
                    i = f_end;
                    continue;
                }
                // fall through to generic handling if malformed
            }

            // ---------- SPECIAL: 2-arg graphics helpers ----------
            if (fn_name == "MODE1_GET_CHAR" || fn_name == "MODE1_GET_COLOR" || fn_name == "TILECHAR" || fn_name == "TILECOLOR" || fn_name == "POINT") {
                var lvlM = 0, partM = "", partsM = [];
                for (var cmi = 1; cmi <= string_length(f_inner); cmi++) {
                    var chM = string_char_at(f_inner, cmi);
                    if (chM == "(") { lvlM++; partM += chM; }
                    else if (chM == ")") { lvlM--; partM += chM; }
                    else if (chM == "," && lvlM == 0) { array_push(partsM, string_trim(partM)); partM = ""; }
                    else { partM += chM; }
                }
                array_push(partsM, string_trim(partM));

                if (array_length(partsM) == 2) {
                    var tM1 = basic_tokenize_expression_v2(partsM[0]);
                    var tM2 = basic_tokenize_expression_v2(partsM[1]);
                    var pM1 = infix_to_postfix(tM1);
                    var pM2 = infix_to_postfix(tM2);
                    _push_all(output, pM1);
                    _push_all(output, pM2);
                    array_push(output, fn_name);
                    dbg_log(DBG_PARSE, "Processed " + fn_name + "(" + partsM[0] + "," + partsM[1] + ")");
                    i = f_end;
                    continue;
                }
            }

            // ---------- SPECIAL: 3-arg tile bitmap helper ----------
            if (fn_name == "TILEBIT") {
                var lvlB = 0, partB = "", partsB = [];
                for (var cbi = 1; cbi <= string_length(f_inner); cbi++) {
                    var chB = string_char_at(f_inner, cbi);
                    if (chB == "(") { lvlB++; partB += chB; }
                    else if (chB == ")") { lvlB--; partB += chB; }
                    else if (chB == "," && lvlB == 0) { array_push(partsB, string_trim(partB)); partB = ""; }
                    else { partB += chB; }
                }
                array_push(partsB, string_trim(partB));

                if (array_length(partsB) == 3) {
                    var tB1 = basic_tokenize_expression_v2(partsB[0]);
                    var tB2 = basic_tokenize_expression_v2(partsB[1]);
                    var tB3 = basic_tokenize_expression_v2(partsB[2]);
                    var pB1 = infix_to_postfix(tB1);
                    var pB2 = infix_to_postfix(tB2);
                    var pB3 = infix_to_postfix(tB3);
                    _push_all(output, pB1);
                    _push_all(output, pB2);
                    _push_all(output, pB3);
                    array_push(output, fn_name);
                    dbg_log(DBG_PARSE, "Processed TILEBIT(" + partsB[0] + "," + partsB[1] + "," + partsB[2] + ")");
                    i = f_end;
                    continue;
                }
            }

            // ---------- SPECIAL: LEFT$/RIGHT$/MID$ (multi-arg) ----------
            if (fn_name == "LEFT$" || fn_name == "RIGHT$" || fn_name == "MID$") {
                var lvl2 = 0, part2 = "", parts_lr = [];
                for (var ci2 = 1; ci2 <= string_length(f_inner); ci2++) {
                    var ch2 = string_char_at(f_inner, ci2);
                    if (ch2 == "(") { lvl2++; part2 += ch2; }
                    else if (ch2 == ")") { lvl2--; part2 += ch2; }
                    else if (ch2 == "," && lvl2 == 0) { array_push(parts_lr, string_trim(part2)); part2 = ""; }
                    else { part2 += ch2; }
                }
                array_push(parts_lr, string_trim(part2));

                // LEFT$/RIGHT$ expect exactly 2 args
                if ((fn_name == "LEFT$" || fn_name == "RIGHT$") && array_length(parts_lr) == 2) {
                    var tA1 = basic_tokenize_expression_v2(parts_lr[0]);
                    var tA2 = basic_tokenize_expression_v2(parts_lr[1]);
                    var pA1 = infix_to_postfix(tA1);
                    var pA2 = infix_to_postfix(tA2);
                    _push_all(output, pA1);
                    _push_all(output, pA2);
                    array_push(output, fn_name);
                    dbg_log(DBG_PARSE, "Processed " + fn_name + "(" + parts_lr[0] + "," + parts_lr[1] + ")");
                    i = f_end;
                    continue;
                }

                // MID$ supports 2 or 3 args
                if (fn_name == "MID$" && (array_length(parts_lr) == 2 || array_length(parts_lr) == 3)) {
                    for (var mi = 0; mi < array_length(parts_lr); mi++) {
                        var tMi = basic_tokenize_expression_v2(parts_lr[mi]);
                        var pMi = infix_to_postfix(tMi);
                        _push_all(output, pMi);
                    }
                    array_push(output, fn_name);
                    dbg_log(DBG_PARSE, "Processed MID$(" + string(parts_lr) + ")");
                    i = f_end;
                    continue;
                }
                // else fall through to generic one-arg below
            }

            // ---------- SPECIAL: RND (0/1/2-arg variants) ----------
            if (fn_name == "RND") {
                var inner_trim = string_trim(f_inner);

                // 0-arg: RND()
                if (string_length(inner_trim) == 0) {
                    array_push(output, "RND");
                    dbg_log(DBG_PARSE, "Processed RND()");
                    i = f_end;
                    continue;
                }

                // Split on top-level commas
                var lvlR = 0, partR = "", partsR = [];
                for (var ri = 1; ri <= string_length(f_inner); ri++) {
                    var chR = string_char_at(f_inner, ri);
                    if (chR == "(") { lvlR++; partR += chR; }
                    else if (chR == ")") { lvlR--; partR += chR; }
                    else if (chR == "," && lvlR == 0) { array_push(partsR, string_trim(partR)); partR = ""; }
                    else { partR += chR; }
                }
                array_push(partsR, string_trim(partR));

                if (array_length(partsR) == 1) {
                    var tN = basic_tokenize_expression_v2(partsR[0]);
                    var pN = infix_to_postfix(tN);
                    _push_all(output, pN);
                    array_push(output, "RND1");
                    dbg_log(DBG_PARSE, "Processed RND(" + partsR[0] + ") → RND1");
                    i = f_end;
                    continue;
                }

                if (array_length(partsR) == 2) {
                    var tA = basic_tokenize_expression_v2(partsR[0]);
                    var tB = basic_tokenize_expression_v2(partsR[1]);
                    var pA = infix_to_postfix(tA);
                    var pB = infix_to_postfix(tB);
                    _push_all(output, pA);
                    _push_all(output, pB);
                    array_push(output, "RND2");
                    dbg_log(DBG_PARSE, "Processed RND(" + partsR[0] + "," + partsR[1] + ") → RND2");
                    i = f_end;
                    continue;
                }
                // malformed → fall through to generic
            }

            // Generic one-arg function: <inner> <FN>
            var inner_tokens  = basic_tokenize_expression_v2(f_inner);
            var inner_postfix = infix_to_postfix(inner_tokens);
            _push_all(output, inner_postfix);
            array_push(output, fn_name);
            dbg_log(DBG_PARSE, "Processed 1-arg function " + fn_name + "(" + f_inner + ") → postfix emit <inner> " + fn_name);
            i = f_end;
            continue;
        }

        // 8) UNKNOWN TOKEN
        dbg_log(DBG_PARSE, "Unknown token, adding to output: " + string(t));
        array_push(output, t);
    }

    // Drain operator stack
    while (array_length(stack) > 0) {
        var tail = array_pop(stack);
        array_push(output, tail);
        dbg_log(DBG_PARSE, "Drained operator stack → appended '" + string(tail) + "'");
    }

    dbg_log(DBG_PARSE, "Final postfix: " + string(output));
    return output;
}
// === END: infix_to_postfix ===
