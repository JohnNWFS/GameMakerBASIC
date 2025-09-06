/// === BEGIN: basic_cmd_let ===
/// LET handler with modal INKEY$ support and array handling
function basic_cmd_let(arg) {
    if (dbg_on(DBG_FLOW)) show_debug_message("LET: Raw input: '" + arg + "'");

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
                    global.basic_variables[? k] = ch_commit;
                }

                // Clear modal flags
                global.inkey_captured   = "";
                global.inkey_waiting    = false;
                global.pause_in_effect  = false;
                global.inkey_target_var = "";

                if (dbg_on(DBG_FLOW)) show_debug_message("LET/INKEY$: committed '" + ch_commit + "' to " + varName + " (resume)");
                return;
            }

            // Still waiting, keep paused this frame
            global.pause_in_effect = true;
            if (dbg_on(DBG_FLOW)) show_debug_message("LET/INKEY$: still waiting (no captured char yet)");
            return;
        }

        // 2) Not waiting yet – FAST PATH: assign immediately if queue already has a key
        // Support either queue name (__inkey_queue primary; inkey_queue legacy)
        var _q = undefined;
        if (ds_exists(global.__inkey_queue, ds_type_queue)) _q = global.__inkey_queue;
        else if (variable_global_exists("inkey_queue") && ds_exists(global.inkey_queue, ds_type_queue)) _q = global.inkey_queue;

        if (!is_undefined(_q) && ds_queue_size(_q) > 0) {
            var ch2 = ds_queue_dequeue(_q);
            if (is_real(ch2)) ch2 = chr(ch2);
            
            // Handle array vs regular variable for INKEY$ assignment
            if (basic_is_array_reference(varName)) {
                basic_assign_to_array(varName, string(ch2));
            } else {
                var k = basic_normvar(varName);
                global.basic_variables[? k] = string(ch2);
            }
            
            if (dbg_on(DBG_FLOW)) show_debug_message("LET/INKEY$: fast-path assign '" + string(ch2) + "' to " + varName);
            return;
        }

        // 3) Arm modal wait: no key ready yet → pause interpreter and let Step capture ONE key
        global.inkey_waiting    = true;
        global.pause_in_effect  = true;
        global.inkey_target_var = varName; // Store the full variable name including array syntax
        global.inkey_captured   = "";
        if (dbg_on(DBG_FLOW)) show_debug_message("LET/INKEY$: armed modal wait for " + varName);
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
        global.basic_variables[? k] = string(val);
        if (dbg_on(DBG_FLOW)) show_debug_message("LET: Assigned string value: '" + string(val) + "' to '" + k + "'");
    } else {
        // Numeric: if it looks numeric, coerce to real; else 0 (or keep as-is if you prefer)
        if (is_real(val)) {
            global.basic_variables[? k] = val;
        } else if (basic_looks_numeric(string(val))) {
            global.basic_variables[? k] = real(val);
        } else {
            global.basic_variables[? k] = 0;
        }
        if (dbg_on(DBG_FLOW)) show_debug_message("LET: Assigned value: '" + string(global.basic_variables[? k]) + "' to '" + k + "'");
    }
}

/// Helper function to check if a variable name is an array reference
function basic_is_array_reference(varName) {
    var open_paren = string_pos("(", varName);
    var close_paren = string_pos(")", varName);
    return (open_paren > 0 && close_paren > open_paren);
}

/// Helper function to assign values to arrays
function basic_assign_to_array(varName, val) {
    // Parse array name and index from varName like "TOPIC$(I)"
    var open_paren = string_pos("(", varName);
    var close_paren = string_pos(")", varName);
    
    if (open_paren <= 0 || close_paren <= open_paren) {
        basic_syntax_error("Invalid array syntax: " + varName);
        return;
    }
    
    var arrayName = string_trim(string_copy(varName, 1, open_paren - 1));
    var indexExpr = string_trim(string_copy(varName, open_paren + 1, close_paren - open_paren - 1));
    
    // Normalize the array name
    var normalizedArrayName = basic_normvar(arrayName);
    
    // Evaluate the index expression
    var indexTokens = basic_tokenize_expression_v2(indexExpr);
    var indexPostfix = infix_to_postfix(indexTokens);
    var indexVal = evaluate_postfix(indexPostfix);
    
    // Convert index to integer
    var index = floor(real(indexVal));
    
    if (dbg_on(DBG_FLOW)) {
        show_debug_message("ARRAY ASSIGN: Array='" + normalizedArrayName + "' Index=" + string(index) + " Value='" + string(val) + "'");
    }
    
    // Ensure the array exists in global.basic_arrays
    if (!ds_map_exists(global.basic_arrays, normalizedArrayName)) {
        // Create the array if it doesn't exist
        global.basic_arrays[? normalizedArrayName] = ds_list_create();
        if (dbg_on(DBG_FLOW)) show_debug_message("ARRAY ASSIGN: Created new array '" + normalizedArrayName + "'");
    }
    
    var arrayList = global.basic_arrays[? normalizedArrayName];
    
    // Ensure the list is big enough for this index
    while (ds_list_size(arrayList) <= index) {
        ds_list_add(arrayList, 0); // Add default values
    }
    
    // Determine if this should be stored as string or number based on array name
    var is_string_array = (string_length(normalizedArrayName) > 0) && (string_char_at(normalizedArrayName, string_length(normalizedArrayName)) == "$");
    
    if (is_string_array) {
        ds_list_replace(arrayList, index, string(val));
        if (dbg_on(DBG_FLOW)) show_debug_message("ARRAY ASSIGN: Set " + normalizedArrayName + "[" + string(index) + "] = '" + string(val) + "' (string)");
    } else {
        // Numeric array
        var numVal = is_real(val) ? val : (basic_looks_numeric(string(val)) ? real(val) : 0);
        ds_list_replace(arrayList, index, numVal);
        if (dbg_on(DBG_FLOW)) show_debug_message("ARRAY ASSIGN: Set " + normalizedArrayName + "[" + string(index) + "] = " + string(numVal) + " (numeric)");
    }
}
/// === END: basic_cmd_let ===