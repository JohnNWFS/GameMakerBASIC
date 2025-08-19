/// @script basic_cmd_elseif
/// @description Handle an ELSEIF in a block‐structured IF…THEN…ELSEIF…ELSE…ENDIF chain
function basic_cmd_elseif(arg) {
    if (dbg_on(DBG_FLOW))  show_debug_message("ELSEIF START — Raw arg: '" + arg + "'");
    
    // ── GUARD 1: Must have an open IF on the stack ──
    if (ds_stack_empty(global.if_stack)) {
        if (dbg_on(DBG_FLOW))  show_debug_message("?ELSEIF ERROR: ELSEIF without matching IF");
        return;
    }
    
    // 1) Where are we in the program?
    var current_index = global.interpreter_current_line_index;
    
    // 2) Peek the top IF‐frame
    var frame = ds_stack_top(global.if_stack);
    
    // ── GUARD 2: Must have block metadata for this IF ──
    if (!ds_map_exists(global.if_block_map, frame[? "startIndex"])) {
        if (dbg_on(DBG_FLOW))  show_debug_message("?ELSEIF ERROR: No IF‐block metadata (bad nesting?)");
        return;
    }
    
    var taken       = frame[? "takenBranch"];
    var elseif_list = frame[? "elseifIndices"]; // ds_list of all ELSEIF positions
    var else_index  = frame[? "elseIndex"];
    var endif_index = frame[? "endifIndex"];
    
    // 3) Find which ELSEIF this is
    var pos = ds_list_find_index(elseif_list, current_index);
    if (pos < 0) {
        if (dbg_on(DBG_FLOW))  show_debug_message("?ELSEIF ERROR: Unexpected ELSEIF at index " + string(current_index));
        return;
    }
    
    // 4) If we’ve already taken a branch, skip straight through
    if (taken) {
        // decide next jump: next ELSEIF, or ELSE, or ENDIF
        var next_index = -1;
        if (pos < ds_list_size(elseif_list) - 1) {
            next_index = elseif_list[| pos + 1];
        } else if (else_index >= 0) {
            next_index = else_index;
        } else {
            next_index = endif_index;
        }
        global.interpreter_next_line = next_index;
        if (dbg_on(DBG_FLOW))  show_debug_message("ELSEIF skipping to index " + string(next_index));
        return;
    }
    
    // 5) Parse and evaluate this ELSEIF’s condition
    var raw      = string_trim(arg);
    var upperRaw = string_upper(raw);
    var then_pos = string_pos("THEN", upperRaw);
    if (then_pos <= 0) {
        if (dbg_on(DBG_FLOW))  show_debug_message("?ELSEIF ERROR: Missing THEN in '" + raw + "'");
        return;
    }
    var cond_text = string_trim(string_copy(raw, 1, then_pos - 1));
    if (dbg_on(DBG_FLOW))  show_debug_message("Parsed ELSEIF condition: '" + cond_text + "'");
    
    // Reuse your AND/OR logic from basic_cmd_if
    var result = false;
    var logic_op = "";
    var upcond   = string_upper(cond_text);
    if (string_pos("AND", upcond) > 0) logic_op = "AND";
    else if (string_pos("OR", upcond) > 0) logic_op = "OR";
    if (logic_op != "") {
        var parts = string_split(cond_text, logic_op);
        var res1 = basic_evaluate_condition(string_trim(parts[0]));
        var res2 = basic_evaluate_condition(string_trim(parts[1]));
        result = (logic_op == "AND") ? (res1 && res2) : (res1 || res2);
        if (dbg_on(DBG_FLOW))  show_debug_message("Combined ELSEIF (" + logic_op + "): " +
                           string(res1) + " " + logic_op + " " + string(res2) +
                           " = " + string(result));
    } else {
        result = basic_evaluate_condition(cond_text);
        if (dbg_on(DBG_FLOW))  show_debug_message("ELSEIF single condition result: " + string(result));
    }
    
    // 6) If it’s true, mark the frame as “taken” and fall into this block…
    if (result) {
        frame[? "takenBranch"] = true;
        global.interpreter_next_line = current_index + 1;
        if (dbg_on(DBG_FLOW))  show_debug_message("ELSEIF TRUE: entering branch at index " + string(global.interpreter_next_line));
    } else {
        // …otherwise skip to the next ELSEIF/ELSE/ENDIF
        var next_index = (pos < ds_list_size(elseif_list) - 1)
                         ? elseif_list[| pos + 1]
                         : (else_index >= 0 ? else_index : endif_index);
        global.interpreter_next_line = next_index;
        if (dbg_on(DBG_FLOW))  show_debug_message("ELSEIF FALSE: skipping to index " + string(next_index));
    }
}
