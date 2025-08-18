/// @function basic_cmd_let(arg)
// === BEGIN: basic_cmd_let ===
/// @description BASIC LET/assignment with array support (D(I)=expr), scalars, and string literals.
/// Notes:
/// - Array indices are evaluated via basic_evaluate_expression_v2 and stored with basic_array_set (1-based).
/// - Safeguards unmatched parentheses and empty pieces to avoid hard crashes.

function basic_cmd_let(arg) {
    show_debug_message("LET: Raw input: '" + string(arg) + "'");

    // ---------------------------
    // 1) Split "name = expr"
    // ---------------------------
    var eq_pos = string_pos("=", arg);
    if (eq_pos <= 0) {
        show_debug_message("LET ERROR: No '=' found in input: " + string(arg));
        return;
    }

    // Normalize name and expression text
    var varname = string_upper(string_trim(string_copy(arg, 1, eq_pos - 1)));
    var expr    = string_trim(string_copy(arg, eq_pos + 1, string_length(arg) - eq_pos));

    show_debug_message("LET: Parsed variable name: '" + varname + "'");
    show_debug_message("LET: Parsed expression    : '" + expr + "'");

    if (varname == "") {
        show_debug_message("LET ERROR: Empty variable name before '='");
        return;
    }
    if (expr == "") {
        show_debug_message("LET WARNING: Empty expression after '='; treating as empty string");
        global.basic_variables[? varname] = "";
        return;
    }

    // ---------------------------------------------------
    // 1.5) SPECIAL: Blocking GET-style INKEY$ on RHS
    //      - Arms pause on first encounter, waits for key release.
    //      - On resume, assigns captured char; string to $ vars, ASC() to numeric.
    // ---------------------------------------------------
    var _exprU = string_upper(string_replace_all(string_replace_all(expr, " ", ""), "\t", ""));
    var _is_inkey = (_exprU == "INKEY$" || _exprU == "INKEY$()");

    if (_is_inkey) {
        // Ensure INKEY state globals exist
        if (is_undefined(global.inkey_waiting))       global.inkey_waiting       = false;
        if (is_undefined(global.inkey_captured))      global.inkey_captured      = "";
        if (is_undefined(global.inkey_target_var))    global.inkey_target_var    = "";

        // If a char was captured already (from the Step pause handler), assign now
        if (!global.inkey_waiting && is_string(global.inkey_captured) && string_length(global.inkey_captured) > 0) {
            var _ch = global.inkey_captured;
            global.inkey_captured   = "";   // consume
            global.inkey_target_var = "";   // clear

            if (string_char_at(varname, string_length(varname)) == "$") {
                global.basic_variables[? varname] = _ch;
                show_debug_message("INKEY_WAIT: assigning captured char '" + _ch + "' to " + varname);
            } else {
                var _asc = ord(_ch);
                global.basic_variables[? varname] = _asc;
                show_debug_message("INKEY_WAIT: assigning ASC('" + _ch + "')=" + string(_asc) + " to " + varname);
            }

            // Do NOT pause; normal flow continues and Step will advance colon slot.
            return;
        }

        // Otherwise, arm the modal wait (pause just like PAUSE) and return.
        global.inkey_target_var = varname;
        global.inkey_waiting    = true;
        global.pause_in_effect  = true;   // gate used by your PAUSE
        global.awaiting_input   = false;  // ensure INPUT gate is off
        show_debug_message("INKEY_WAIT: armed for '" + varname + "'; pausing until key release");
        return;
    }

    // -----------------------------------------------
    // 2) String-literal assignment (double quotes)
    // -----------------------------------------------
    if (string_length(expr) >= 2
    &&  string_char_at(expr, 1) == "\""
    &&  string_char_at(expr, string_length(expr)) == "\"")
    {
        var str_val = string_copy(expr, 2, string_length(expr) - 2);
        global.basic_variables[? varname] = str_val;
        show_debug_message("LET: Assigned string value: '" + str_val + "' to '" + varname + "'");
        return;
    }

    // ---------------------------------------------------
    // 3) Array assignment: NAME( index_expr ) = value_expr
    //     - Works for VAR( I ), VAR( 1+J ), etc.
    // ---------------------------------------------------
    var openPos = string_pos("(", varname);
    if (openPos > 0) {
        // Ensure trailing ')'
        if (string_char_at(varname, string_length(varname)) != ")") {
            show_debug_message("LET WARNING: Array syntax missing ')': '" + varname + "'. Falling back to scalar assignment.");
        } else {
            // Extract array name and raw index text (allow spaces inside)
            var arrName = string_copy(varname, 1, openPos - 1);
            var idxText = string_copy(varname, openPos + 1, string_length(varname) - openPos - 1);
            // strip trailing ')' if still present due to odd spacing
            if (string_length(idxText) > 0 && string_char_at(idxText, string_length(idxText)) == ")") {
                idxText = string_delete(idxText, string_length(idxText), 1);
            }

            arrName = string_upper(string_trim(arrName));
            idxText = string_trim(idxText);

            if (arrName == "" || idxText == "") {
                show_debug_message("LET WARNING: Malformed array target. arrName='" + arrName + "', idxText='" + idxText + "'. Falling back to scalar.");
            } else {
                // Evaluate index and value via the standard expression pipeline
                var idxVal   = basic_evaluate_expression_v2(idxText);
                var valueVal = basic_evaluate_expression_v2(expr);

                // Defensive: if idxVal is not numeric, bail gracefully
                if (!is_real(idxVal)) {
                    show_debug_message("LET ERROR: Array index evaluated to non-numeric '" + string(idxVal) + "' from '" + idxText + "'");
                    return;
                }

                // Perform 1-based array set via your helper
                basic_array_set(arrName, idxVal, valueVal);
                show_debug_message("LET: Assigned array '" + arrName + "(" + string(idxVal) + ")' = " + string(valueVal));
                return;
            }
        }
        // If we got here, array syntax was malformed; continue to scalar handling below
    }

    // ---------------------------------------------------
    // 4) Scalar numeric / expression assignment (fallback)
    // ---------------------------------------------------
    var result = basic_evaluate_expression_v2(expr);

    // We don’t force-type; whatever evaluate returns is stored
    global.basic_variables[? varname] = result;

    if (is_string(result)) {
        show_debug_message("LET: Assigned string value: '" + string(result) + "' to '" + varname + "'");
    } else {
        show_debug_message("LET: Assigned numeric value: " + string(result) + " to '" + varname + "'");
    }
}
// === END: basic_cmd_let ===
