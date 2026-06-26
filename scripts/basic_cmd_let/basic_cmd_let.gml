/// === BEGIN: basic_cmd_let ===
/// LET handler with modal INKEY$ support and array handling
function basic_cmd_let(arg) {
    dbg_log(DBG_FLOW, "LET: Raw input: '" + arg + "'");

    // Split "NAME = EXPR"
    var eq = string_pos("=", arg);
    if (eq <= 0) {
        basic_syntax_error("LET requires '='", /*line*/ undefined, global.interpreter_current_stmt_index, "LET_MISSING_EQUALS");
        return;
    }

    var varName = string_trim(string_copy(arg, 1, eq - 1));
    var exprStr = string_trim(string_copy(arg, eq + 1, string_length(arg) - eq));

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("LET: Parsed variable name: '" + varName + "'");
        show_debug_message("LET: Parsed expression    : '" + exprStr + "'");
    }

    // ---------- MODAL INKEY$: pure RHS detection ----------
    var expr_uc = string_upper(exprStr);
    var is_pure_inkey = false;

    // Allow "INKEY$" or "INKEY$()" with arbitrary spaces
    // Strip whitespace
    var expr_compact = string_replace_all(string_replace_all(expr_uc, " ", ""), "\t", "");
    if (expr_compact == "INKEY$" || expr_compact == "INKEY$()") is_pure_inkey = true;

    if (is_pure_inkey) {

        // 1) If we are resuming from a prior wait and have a captured char, COMMIT now.
        if (variable_global_exists("inkey_waiting") && global.inkey_waiting) {
            if (variable_global_exists("inkey_captured") && string_length(global.inkey_captured) > 0) {
                var ch_commit = string(global.inkey_captured);
                
                // Handle array vs regular variable for INKEY$ assignment
                if (basic_is_array_reference(varName)) {
                    basic_assign_to_array(varName, ch_commit);
                } else {
                    var k = basic_normvar(varName);
                    basic_var_set(k, ch_commit);
                }

                // Clear modal flags
                global.inkey_captured   = "";
                global.inkey_waiting    = false;
                global.pause_in_effect  = false;
                global.inkey_target_var = "";
                global.inkey_release_guard = true;

                if (variable_global_exists("__inkey_queue") && ds_exists(global.__inkey_queue, ds_type_queue)) {
                    ds_queue_clear(global.__inkey_queue);
                }

                dbg_log(DBG_FLOW, "LET/INKEY$: committed '" + ch_commit + "' to " + varName + " (resume)");
                return;
            }

            // Still waiting, keep paused this frame
            global.pause_in_effect = true;
            dbg_log(DBG_FLOW, "LET/INKEY$: still waiting (no captured char yet)");
            return;
        }

        // 2) Not waiting yet – FAST PATH: assign immediately if queue already has a key
        var _q = undefined;
        if (!variable_global_exists("__inkey_queue") || !ds_exists(global.__inkey_queue, ds_type_queue)) global.__inkey_queue = ds_queue_create();
        _q = global.__inkey_queue;

        if (!is_undefined(_q) && ds_queue_size(_q) > 0) {
            var ch2 = ds_queue_dequeue(_q);
            if (is_real(ch2)) ch2 = chr(ch2);
            
            // Handle array vs regular variable for INKEY$ assignment
            if (basic_is_array_reference(varName)) {
                basic_assign_to_array(varName, string(ch2));
            } else {
                var k = basic_normvar(varName);
                basic_var_set(k, string(ch2));
            }

            if (variable_global_exists("__inkey_queue") && ds_exists(global.__inkey_queue, ds_type_queue)) {
                ds_queue_clear(global.__inkey_queue);
            }
            global.inkey_release_guard = true;
             
            dbg_log(DBG_FLOW, "LET/INKEY$: fast-path assign '" + string(ch2) + "' to " + varName);
            return;
        }

        // 3) Arm modal wait: no key ready yet → pause interpreter and let Step capture ONE key
        global.inkey_waiting    = true;
        global.pause_in_effect  = true;
        global.inkey_target_var = varName; // Store the full variable name including array syntax
        global.inkey_captured   = "";
        dbg_log(DBG_FLOW, "LET/INKEY$: armed modal wait for " + varName);
        return;
    }
    // ---------- END MODAL INKEY$ special case ----------

    // ---------- Default LET path: evaluate expression and assign ----------
    var tokens  = basic_tokenize_expression_v2(exprStr);
    var postfix = infix_to_postfix(tokens);
    var val     = evaluate_postfix(postfix);

    // Check if this is an array assignment
    if (basic_is_array_reference(varName)) {
        basic_assign_to_array(varName, val);
        return;
    }

    // Regular variable assignment (existing logic)
    var k = basic_normvar(varName);

    // Coerce based on variable sigil: trailing $ means string var
    var is_string_var = (string_length(k) > 0) && (string_char_at(k, string_length(k)) == "$");
    if (is_string_var) {
        basic_var_set(k, string(val));
        dbg_log(DBG_FLOW, "LET: Assigned string value: '" + string(val) + "' to '" + k + "'");
    } else {
        // Numeric: if it looks numeric, coerce to real; else 0 (or keep as-is if you prefer)
        if (is_real(val)) {
            basic_var_set(k, val);
        } else if (basic_looks_numeric(string(val))) {
            basic_var_set(k, real(val));
        } else {
            basic_var_set(k, 0);
        }
        dbg_log(DBG_FLOW, "LET: Assigned value: '" + string(basic_var_get(k)) + "' to '" + k + "'");
    }
}

