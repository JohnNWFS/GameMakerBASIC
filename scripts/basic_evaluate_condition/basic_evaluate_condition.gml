function basic_evaluate_condition(expr) {
    var s = string_trim(expr);
    show_debug_message("COND: Begin evaluate_condition → '" + s + "'");

    // ===== NEW: handle top-level OR / AND first (depth-aware, quote-safe) =====
    // We split on OR first (lower precedence), then AND (higher precedence).
    // This matches typical boolean precedence: AND binds tighter than OR.
    {
        var su = string_upper(s);
        var L  = string_length(su);
        var _depth = 0;
        var in_q  = false;

        // ---- Top-level OR ----
        for (var i = 1; i <= L - 1; i++) {
            var ch = string_char_at(su, i);
            if (ch == "\"") { in_q = !in_q; continue; }
            if (in_q) continue;

            if (ch == "(") { _depth++; continue; }
            if (ch == ")") { _depth = max(0, _depth - 1); continue; }
            if (_depth != 0) continue;

            if (string_copy(su, i, 2) == "OR") {
                // Require space boundaries to avoid matching inside identifiers like "COLOR"
                var prev = (i == 1) ? " " : string_char_at(su, i - 1);
                var next = (i + 2 <= L) ? string_char_at(su, i + 2) : " ";
                if (prev == " " && next == " ") {
                    var left  = string_trim(string_copy(s, 1, i - 1));
                    var right = string_trim(string_copy(s, i + 2, L - (i + 2) + 1));
                    show_debug_message("COND: top-level OR split → LHS='" + left + "'  ||  RHS='" + right + "'");

                    var lres = basic_evaluate_condition(left);
                    show_debug_message("COND: OR left result = " + string(lres));
                    if (lres) { show_debug_message("COND: OR short-circuit TRUE"); return true; }

                    var rres = basic_evaluate_condition(right);
                    var ores = (lres || rres);
                    show_debug_message("COND: OR final = " + string(ores));
                    return ores;
                }
            }
        }

        // ---- Top-level AND ----
        depth = 0; in_q = false;
        for (var j = 1; j <= L - 2; j++) {
            var ch2 = string_char_at(su, j);
            if (ch2 == "\"") { in_q = !in_q; continue; }
            if (in_q) continue;

            if (ch2 == "(") { depth++; continue; }
            if (ch2 == ")") { depth = max(0, depth - 1); continue; }
            if (depth != 0) continue;

            if (string_copy(su, j, 3) == "AND") {
                // Require space boundaries to avoid matching inside identifiers
                var prev2 = (j == 1) ? " " : string_char_at(su, j - 1);
                var next2 = (j + 3 <= L) ? string_char_at(su, j + 3) : " ";
                if (prev2 == " " && next2 == " ") {
                    var left2  = string_trim(string_copy(s, 1, j - 1));
                    var right2 = string_trim(string_copy(s, j + 3, L - (j + 3) + 1));
                    show_debug_message("COND: top-level AND split → LHS='" + left2 + "'  &&  RHS='" + right2 + "'");

                    var lres2 = basic_evaluate_condition(left2);
                    show_debug_message("COND: AND left result = " + string(lres2));
                    if (!lres2) { show_debug_message("COND: AND short-circuit FALSE"); return false; }

                    var rres2 = basic_evaluate_condition(right2);
                    var andres = (lres2 && rres2);
                    show_debug_message("Combined condition (AND): " + string(lres2) + " AND " + string(rres2) + " = " + string(andres));
                    return andres;
                }
            }
        }
    }
    // ===== END NEW boolean handling =====

    // --- Original comparator search (kept) ---
    // Find a top-level comparison operator without requiring spaces.
    // Check multi-char ops first to avoid splitting on the '=' of "<=" etc.
    var ops = ["<>", "<=", ">=", "=", "<", ">"];
    var found_op = "";
    var op_pos = 0;
    var _depth = 0;

    // Scan once, track parentheses depth; choose first matching op at depth 0
    for (var i2 = 1; i2 <= string_length(s); i2++) {
        var ch3 = string_char_at(s, i2);
        if (ch3 == "(") { _depth++; continue; }
        if (ch3 == ")") { _depth--; continue; }
        if (_depth != 0) continue;

        // try 2-char ops
        if (i2 < string_length(s)) {
            var two = string_copy(s, i2, 2);
            if (two == "<>" || two == "<=" || two == ">=") {
                found_op = two; op_pos = i2;
                show_debug_message("COND: Found 2-char op '" + found_op + "' at pos " + string(op_pos));
                break;
            }
        }
        // try 1-char ops
        if (ch3 == "=" || ch3 == "<" || ch3 == ">") {
            found_op = ch3; op_pos = i2;
            show_debug_message("COND: Found 1-char op '" + found_op + "' at pos " + string(op_pos));
            break;
        }
    }

    // If we found an operator at top level, split and evaluate both sides fully
    if (found_op != "") {
        var lhs = string_trim(string_copy(s, 1, op_pos - 1));
        var rhs = string_trim(string_copy(s, op_pos + string_length(found_op), string_length(s) - (op_pos + string_length(found_op) - 1)));
        var op  = found_op;

        show_debug_message("COND: Split → LHS='" + lhs + "'  OP='" + op + "'  RHS='" + rhs + "'");

        // 1) Evaluate both sides as expressions
        var lhs_val = basic_evaluate_expression_v2(lhs);
        var rhs_val = basic_evaluate_expression_v2(rhs);
        show_debug_message("COND: Eval → LHS=" + string(lhs_val) + "  RHS=" + string(rhs_val));

        // 2) If either is non-numeric, do string comparisons (original rule)
        var lhs_str = string(lhs_val);
        var rhs_str = string(rhs_val);
        var lhs_is_num = is_real(lhs_val) || is_numeric_string(lhs_str);
        var rhs_is_num = is_real(rhs_val) || is_numeric_string(rhs_str);
        show_debug_message("COND: Types → LHS_is_num=" + string(lhs_is_num) + "  RHS_is_num=" + string(rhs_is_num));

        if (!(lhs_is_num && rhs_is_num)) {
            var sres = false;
            switch (op) {
                case "=":  sres = (lhs_str == rhs_str); break;
                case "<>": sres = (lhs_str != rhs_str); break;
                default:   sres = false; // no ordering on strings
            }
            show_debug_message("COND: String-compare '" + op + "' → " + string(sres));
            return sres;
        }

        // 3) Numeric compare
        var lhs_num = real(lhs_str);
        var rhs_num = real(rhs_str);
        var nres = false;
        switch (op) {
            case "=":  nres = (lhs_num == rhs_num); break;
            case "<":  nres = (lhs_num <  rhs_num); break;
            case ">":  nres = (lhs_num >  rhs_num); break;
            case "<=": nres = (lhs_num <= rhs_num); break;
            case ">=": nres = (lhs_num >= rhs_num); break;
            case "<>": nres = (lhs_num != rhs_num); break;
        }
        show_debug_message("COND: Numeric-compare '" + op + "' → " + string(nres));
        return nres;
    }

    // --- Fallback to your existing space-split path (kept for compatibility) ---
    var tokens = string_split(s, " ");
    if (array_length(tokens) == 3) {
        var lhs2 = string_trim(tokens[0]);
        var op2  = string_trim(tokens[1]);
        var rhs2 = string_trim(tokens[2]);
        show_debug_message("COND: Fallback (space-split) → LHS='" + lhs2 + "' OP='" + op2 + "' RHS='" + rhs2 + "'");

        var lhs_val2 = basic_evaluate_expression_v2(lhs2);
        var rhs_val2 = basic_evaluate_expression_v2(rhs2);
        show_debug_message("COND: Fallback eval → LHS=" + string(lhs_val2) + "  RHS=" + string(rhs_val2));

        var lhs_str2 = string(lhs_val2);
        var rhs_str2 = string(rhs_val2);
        var lhs_is_num2 = is_real(lhs_val2) || is_numeric_string(lhs_str2);
        var rhs_is_num2 = is_real(rhs_val2) || is_numeric_string(rhs_str2);
        show_debug_message("COND: Fallback types → LHS_is_num=" + string(lhs_is_num2) + "  RHS_is_num=" + string(rhs_is_num2));

        if (!(lhs_is_num2 && rhs_is_num2)) {
            var sres2 = false;
            switch (op2) {
                case "=":  sres2 = (lhs_str2 == rhs_str2); break;
                case "<>": sres2 = (lhs_str2 != rhs_str2); break;
                default:   sres2 = false;
            }
            show_debug_message("COND: Fallback string-compare '" + op2 + "' → " + string(sres2));
            return sres2;
        }

        var lhs_num2 = real(lhs_str2);
        var rhs_num2 = real(rhs_str2);
        var nres2 = false;
        switch (op2) {
            case "=":  nres2 = (lhs_num2 == rhs_num2); break;
            case "<":  nres2 = (lhs_num2 <  rhs_num2); break;
            case ">":  nres2 = (lhs_num2 >  rhs_num2); break;
            case "<=": nres2 = (lhs_num2 <= rhs_num2); break;
            case ">=": nres2 = (lhs_num2 >= rhs_num2); break;
            case "<>": nres2 = (lhs_num2 != rhs_num2); break;
        }
        show_debug_message("COND: Fallback numeric-compare '" + op2 + "' → " + string(nres2));
        return nres2;
    }

    // Unary convenience (your existing behavior): ABS(x), RND(x)
    var single = string_upper(string_trim(s));
    if (string_pos("ABS(", single) == 1) {
        var insideA = string_copy(single, 5, string_length(single) - 5);
        insideA = string_delete(insideA, string_length(insideA), 1);
        var aval = abs(real(insideA));
        show_debug_message("COND: Unary ABS(...) → " + string(aval));
        return aval;
    }
    if (string_pos("RND(", single) == 1) {
        var insideR = string_copy(single, 5, string_length(single) - 5);
        insideR = string_delete(insideR, string_length(insideR), 1);
        var rval = irandom(real(insideR));
        show_debug_message("COND: Unary RND(...) → " + string(rval));
        return rval;
    }

    show_debug_message("COND: No operator recognized; returning false");
    return false;
}
