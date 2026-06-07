/// @script basic_cmd_elseif
/// @description Handle an ELSEIF in a block‐structured IF…THEN…ELSEIF…ELSE…ENDIF chain
function basic_cmd_elseif(arg) {
    dbg_log(DBG_FLOW, "ELSEIF START — Raw arg: '" + arg + "'");
    
    // ── GUARD 1: Must have an open IF on the stack ──
    if (ds_stack_empty(global.if_stack)) {
        dbg_log(DBG_FLOW, "?ELSEIF ERROR: ELSEIF without matching IF");
        return;
    }
    
    // 1) Where are we in the program?
    var current_index = global.interpreter_current_line_index;
    
    // 2) Peek the top IF‐frame
    var frame = ds_stack_top(global.if_stack);
    
    // ── GUARD 2: Must have block metadata for this IF ──
    if (!ds_map_exists(global.if_block_map, frame[? "startIndex"])) {
        dbg_log(DBG_FLOW, "?ELSEIF ERROR: No IF‐block metadata (bad nesting?)");
        return;
    }
    
    var taken       = frame[? "takenBranch"];
    var elseif_list = frame[? "elseifIndices"]; // ds_list of all ELSEIF positions
    var else_index  = frame[? "elseIndex"];
    var endif_index = frame[? "endifIndex"];
    
    // 3) Find which ELSEIF this is
    var pos = ds_list_find_index(elseif_list, current_index);
    if (pos < 0) {
        dbg_log(DBG_FLOW, "?ELSEIF ERROR: Unexpected ELSEIF at index " + string(current_index));
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
        global.interpreter_use_stmt_jump = true;
        global.interpreter_target_line = next_index;
        global.interpreter_target_stmt = 0;
        global.interpreter_next_line = -1;
        dbg_log(DBG_FLOW, "ELSEIF skipping to index " + string(next_index));
        return;
    }
    
    // 5) Parse and evaluate this ELSEIF’s condition
    var raw      = string_trim(arg);
    var upperRaw = string_upper(raw);
    var then_pos = string_pos("THEN", upperRaw);
    if (then_pos <= 0) {
        dbg_log(DBG_FLOW, "?ELSEIF ERROR: Missing THEN in '" + raw + "'");
        return;
    }
    var cond_text = string_trim(string_copy(raw, 1, then_pos - 1));
    dbg_log(DBG_FLOW, "Parsed ELSEIF condition: '" + cond_text + "'");
    
    var result = basic_evaluate_condition(cond_text);
    dbg_log(DBG_FLOW, "ELSEIF condition result: " + string(result));
    
    // 6) If it’s true, mark the frame as “taken” and fall into this block…
    if (result) {
        frame[? "takenBranch"] = true;
        global.interpreter_use_stmt_jump = true;
        global.interpreter_target_line = current_index + 1;
        global.interpreter_target_stmt = 0;
        global.interpreter_next_line = -1;
        dbg_log(DBG_FLOW, "ELSEIF TRUE: entering branch at index " + string(global.interpreter_target_line));
    } else {
        // …otherwise skip to the next ELSEIF/ELSE/ENDIF
        var next_index = (pos < ds_list_size(elseif_list) - 1)
                         ? elseif_list[| pos + 1]
                         : (else_index >= 0 ? else_index : endif_index);
        global.interpreter_use_stmt_jump = true;
        global.interpreter_target_line = next_index;
        global.interpreter_target_stmt = 0;
        global.interpreter_next_line = -1;
        dbg_log(DBG_FLOW, "ELSEIF FALSE: skipping to index " + string(next_index));
    }
}
