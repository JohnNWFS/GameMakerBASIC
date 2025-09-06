function basic_cmd_wend() {
    if (dbg_on(DBG_FLOW)) show_debug_message("WEND: Entering handler...");

    if (!ds_exists(global.while_stack, ds_type_stack) || ds_stack_empty(global.while_stack)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("WEND: ERROR — while_stack missing or empty");
        basic_show_message("WEND without matching WHILE");
        return;
    }

    var while_line_index = ds_stack_top(global.while_stack); // Peek, do not pop yet
    if (dbg_on(DBG_FLOW)) show_debug_message("WEND: Top of while_stack is line index: " + string(while_line_index));

    // Prefer exact condition & resume slot captured at WHILE time
    var have_meta = (variable_global_exists("while_meta") && ds_exists(global.while_meta, ds_type_map)
                     && ds_map_exists(global.while_meta, string(while_line_index)));

    var cond_str, stmt_after;

    if (have_meta) {
        var meta = global.while_meta[? string(while_line_index)];
        cond_str   = string(meta[? "cond_str"]);
        stmt_after = meta[? "stmt_after"];
        if (dbg_on(DBG_FLOW)) show_debug_message("WEND: Using stored cond='" + cond_str + "', stmt_after=" + string(stmt_after));
    } else {
        // === Legacy fallback (keeps prior behavior if meta missing) ===
        var while_line_number = ds_list_find_value(global.line_list, while_line_index);
        var while_code        = ds_map_find_value(global.program_map, while_line_number);
        if (dbg_on(DBG_FLOW)) show_debug_message("WEND: Fallback WHILE line " + string(while_line_number) + " code: '" + while_code + "'");

        cond_str = string_trim(string_delete(while_code, 1, string_pos(" ", while_code)));
        stmt_after = 0; // we’ll jump to start of line as before in fallback
        if (dbg_on(DBG_FLOW)) show_debug_message("WEND: Fallback extracted condition: '" + cond_str + "'");
    }

    var condition_value = basic_evaluate_condition(string_upper(cond_str));
    if (dbg_on(DBG_FLOW)) show_debug_message("WEND: Re-evaluated condition result: " + string(condition_value));

    if (condition_value) {
        if (have_meta) {
            // === FIX 2: loop back to the colon slot immediately AFTER the WHILE header ===
            global.interpreter_use_stmt_jump = true;
            global.interpreter_target_line   = while_line_index;
            global.interpreter_target_stmt   = max(0, stmt_after);
            global.interpreter_next_line     = -1;
            if (dbg_on(DBG_FLOW)) show_debug_message("WEND: TRUE → jump to (line="
                + string(global.interpreter_target_line) + ", stmt=" + string(global.interpreter_target_stmt) + ")");
        } else {
            // Legacy behavior
            if (dbg_on(DBG_FLOW)) show_debug_message("WEND: TRUE (fallback) — setting line_index = " + string(while_line_index - 1));
            line_index = while_line_index - 1; // causes Step to re-run the WHILE line
        }
    } else {
        // Exit loop
        ds_stack_pop(global.while_stack);
        if (have_meta) {
            // Clean up stored meta for this WHILE
            ds_map_delete(global.while_meta, string(while_line_index));
        }
        if (dbg_on(DBG_FLOW)) show_debug_message("WEND: FALSE → pop and continue");
    }
}
