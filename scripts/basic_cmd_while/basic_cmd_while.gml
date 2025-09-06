function basic_cmd_while(arg) {
    // Keep your original behavior & logging
    var condition = string_upper(string_trim(arg));
    if (dbg_on(DBG_FLOW)) show_debug_message("WHILE: Raw condition string: '" + condition + "'");

    var value = basic_evaluate_condition(condition);
    if (dbg_on(DBG_FLOW)) show_debug_message("WHILE: Evaluated result of '" + condition + "' → " + string(value));

    // ---- Lazy-init tiny metadata store for WHILE frames (no global file edits required)
    if (!variable_global_exists("while_meta") || !ds_exists(global.while_meta, ds_type_map)) {
        global.while_meta = ds_map_create();
    }

    if (!value) {
        // === FIX 1: robust skip ahead that inspects colon-separated statements, not only first token ===
        if (dbg_on(DBG_FLOW)) show_debug_message("WHILE: Condition is FALSE — skipping ahead to matching WEND");
        var _depth = 1;

        var li_max = ds_list_size(global.line_list);
        var li     = global.interpreter_current_line_index;         // current physical line index
        var stmt   = global.interpreter_current_stmt_index + 1;     // start after the WHILE header

        while (li < li_max) {
            var _ln   = ds_list_find_value(global.line_list, li);
            var code  = ds_map_find_value(global.program_map, _ln);
            var parts = split_on_unquoted_colons(string_trim(code));

            for (var p = stmt; p < array_length(parts); p++) {
                var raw  = string_trim(parts[p]);
                if (raw == "") continue;

                raw = strip_basic_remark(raw);
                var sp  = string_pos(" ", raw);
                var cmd = (sp > 0) ? string_upper(string_copy(raw, 1, sp - 1)) : string_upper(raw);

                if (dbg_on(DBG_FLOW)) show_debug_message("WHILE: scan line " + string(_ln) + " part " + string(p) + " → " + cmd);

                if (cmd == "WHILE") {
                    _depth += 1; // nested while inside the false body we’re skipping
                } else if (cmd == "WEND") {
                    _depth -= 1;
                    if (_depth == 0) {
                        if (dbg_on(DBG_FLOW)) show_debug_message(
                            "WHILE: Found matching WEND at line index " + string(li) + ", line " + string(_ln) + ", part " + string(p)
                        );
                        // Land just AFTER this WEND colon slot
                        global.interpreter_use_stmt_jump = true;
                        global.interpreter_target_line   = li;
                        global.interpreter_target_stmt   = p + 1;
                        global.interpreter_next_line     = -1;
                        return;
                    }
                }
            }

            li   += 1;
            stmt  = 0; // from next physical line, start at first colon slot
        }

        if (dbg_on(DBG_FLOW)) show_debug_message("?WHILE ERROR: No matching WEND found — control flow may break");
        return;
    }

    // === Condition TRUE → record minimal metadata and push loop frame as you already do ===
    if (dbg_on(DBG_FLOW)) show_debug_message("WHILE: Condition is TRUE — evaluating stack push logic");

    // Ensure stack exists
    if (!ds_exists(global.while_stack, ds_type_stack)) {
        global.while_stack = ds_stack_create();
        if (dbg_on(DBG_FLOW)) show_debug_message("WHILE: Created new while_stack");
    }

    // Only push if not already at top (preserve your logic)
    if (ds_stack_empty(global.while_stack) || ds_stack_top(global.while_stack) != line_index) {
        ds_stack_push(global.while_stack, line_index);
        if (dbg_on(DBG_FLOW)) show_debug_message("WHILE: Pushed line_index " + string(line_index) + " onto while_stack");
    } else {
        if (dbg_on(DBG_FLOW)) show_debug_message("WHILE: Stack already contains this line_index at top — skipping push");
    }

    // Save exact condition and the colon slot to resume the loop body after WHILE’s header
    var key = string(line_index); // key by the WHILE's physical line index
    var meta = ds_map_create();
    meta[? "cond_str"]   = string_trim(arg); // store as written on the line (not uppercased)
    meta[? "stmt_after"] = global.interpreter_current_stmt_index + 1;
    ds_map_replace(global.while_meta, key, meta);

    // Continue normally
    global.interpreter_next_line = -1;
}
