/// @script infix_to_postfix
// === BEGIN: infix_to_postfix ===
function infix_to_postfix(tokens) {
    if (dbg_on(DBG_PARSE)) show_debug_message("Converting to postfix: " + string(tokens));

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

        if (t == ",") { if (dbg_on(DBG_PARSE)) show_debug_message("INFIX: Skipping comma token"); continue; }

        var tu = _TOKU(t);

        // 1) ARRAY READ COLLAPSE
        if (is_string(t)) {
            var first = string_char_at(t, 1);
            var can_be_name = is_letter(first);

            if (can_be_name && i + 1 < array_length(tokens) && tokens[i + 1] == "("
            && !(is_function(t) || _is_STRING_fn(t))) {
                if (dbg_on(DBG_PARSE)) show_debug_message("INFIX: Candidate for array collapse → '" + string(t) + "' followed by '('");
                var arr_info = _read_paren_payload(tokens, i + 1);
                var matched  = arr_info[0];
                var inner    = arr_info[1];
                var j        = arr_info[2];

                if (matched) {
                    var collapsed = string(t) + "(" + inner + ")";
                    array_push(output, collapsed);
                    if (dbg_on(DBG_PARSE)) show_debug_message("INFIX: Collapsed array read token → '" + collapsed + "' (consumed through index " + string(j) + ")");
                    i = j;
                    continue;
                } else {
                    if (dbg_on(DBG_PARSE)) show_debug_message("INFIX: WARNING — unmatched '(' after '" + string(t) + "'. Not collapsing.");
                }
            }
        }

        // 2) NUMERIC LITERAL
        if (is_numeric_string(t)) { array_push(output, t); if (dbg_on(DBG_PARSE)) show_debug_message("Added number to output: " + string(t)); continue; }

        // 3) KNOWN VARIABLE
        if (ds_map_exists(global.basic_variables, tu)) { array_push(output, tu); if (dbg_on(DBG_PARSE)) show_debug_message("Added variable name to output: " + tu); continue; }

        // 4) OPEN PAREN
        if (t == "(") { array_push(stack, t); if (dbg_on(DBG_PARSE)) show_debug_message("Pushed '(' onto operator stack"); continue; }

        // 5) CLOSE PAREN
        if (t == ")") {
            while (array_length(stack) > 0 && stack[array_length(stack) - 1] != "(") {
                var popped_close = array_pop(stack);
                array_push(output, popped_close);
                if (dbg_on(DBG_PARSE)) show_debug_message("Popped '" + string(popped_close) + "' from stack to output (closing ')')");
            }
            if (array_length(stack) > 0 && stack[array_length(stack) - 1] == "(") {
                array_pop(stack);
                if (dbg_on(DBG_PARSE)) show_debug_message("Discarded matching '(' from stack");
            } else {
                if (dbg_on(DBG_PARSE)) show_debug_message("INFIX: WARNING — stray ')' with no matching '('");
            }
            continue;
        }

        // 6) OPERATORS
        if (is_operator(t)) {
            if (dbg_on(DBG_PARSE)) show_debug_message("Found operator: " + string(t));
            while (array_length(stack) > 0) {
                var top = stack[array_length(stack) - 1];
                if (is_operator(top) && (get_precedence(top) > get_precedence(t)
                || (get_precedence(top) == get_precedence(t) && !is_right_associative(t)))) {
                    var popped_op = array_pop(stack);
                    array_push(output, popped_op);
                    if (dbg_on(DBG_PARSE)) show_debug_message("Popped higher/equal precedence operator '" + string(popped_op) + "' to output");
                } else break;
            }
            array_push(stack, t);
            if (dbg_on(DBG_PARSE)) show_debug_message("Pushed operator '" + string(t) + "' onto stack");
            continue;
        }

        // 7) FUNCTIONS
        if (is_function(t) || _is_STRING_fn(t)) {
            var fn_name = tu;

            // Zero-arg functions emit directly
            if (_is_zero_arg_fn(fn_name)) {
                array_push(output, fn_name);
                if (dbg_on(DBG_PARSE)) show_debug_message("Processed zero-arg function: " + fn_name);
                continue;
            }

            // Must be followed by '('
            if (!(i + 1 < array_length(tokens) && tokens[i + 1] == "(")) {
                array_push(output, fn_name);
                if (dbg_on(DBG_PARSE)) show_debug_message("Function without '(': passing through → " + fn_name);
                continue;
            }

            // Read (...): pass tokens explicitly
            var f_info  = _read_paren_payload(tokens, i + 1);
            var f_ok    = f_info[0];
            var f_inner = f_info[1];
            var f_end   = f_info[2];

            if (!f_ok) {
                array_push(output, fn_name);
                if (dbg_on(DBG_PARSE)) show_debug_message("WARNING: unmatched '(' for function " + fn_name + " — passing through");
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
                    if (dbg_on(DBG_PARSE)) show_debug_message("Processed STRING$(x,n): args = [" + parts[0] + "], [" + parts[1] + "]");
                    i = f_end;
                    continue;
                }
                // fall through to generic handling if malformed
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
                    if (dbg_on(DBG_PARSE)) show_debug_message("Processed " + fn_name + "(" + parts_lr[0] + "," + parts_lr[1] + ")");
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
                    if (dbg_on(DBG_PARSE)) show_debug_message("Processed MID$(" + string(parts_lr) + ")");
                    i = f_end;
                    continue;
                }
                // else fall through to generic one-arg below
            }

            // Generic one-arg function: <inner> <FN>
            var inner_tokens  = basic_tokenize_expression_v2(f_inner);
            var inner_postfix = infix_to_postfix(inner_tokens);
            _push_all(output, inner_postfix);
            array_push(output, fn_name);
            if (dbg_on(DBG_PARSE)) show_debug_message("Processed 1-arg function " + fn_name + "(" + f_inner + ") → postfix emit <inner> " + fn_name);
            i = f_end;
            continue;
        }

        // 8) UNKNOWN TOKEN
        if (dbg_on(DBG_PARSE)) show_debug_message("Unknown token, adding to output: " + string(t));
        array_push(output, t);
    }

    // Drain operator stack
    while (array_length(stack) > 0) {
        var tail = array_pop(stack);
        array_push(output, tail);
        if (dbg_on(DBG_PARSE)) show_debug_message("Drained operator stack → appended '" + string(tail) + "'");
    }

    if (dbg_on(DBG_PARSE)) show_debug_message("Final postfix: " + string(output));
    return output;
}
// === END: infix_to_postfix ===
