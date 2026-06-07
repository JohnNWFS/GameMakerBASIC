/// @script basic_cmd_if
/// @description Block‐structured IF…THEN…ELSEIF…ELSE…ENDIF initializer
function basic_cmd_if(arg) {
    dbg_log(DBG_FLOW, "IF START — Raw arg: '" + arg + "'");

    // 1) Compute the current line‐list index (we assume global.interpreter_next_line was pre-incremented)
    var current_index = global.interpreter_current_line_index;

// DEBUG: Show what's in the IF block map
    dbg_log(DBG_FLOW, "DEBUG: current_index = " + string(current_index));
    var keys = ds_map_keys_to_array(global.if_block_map);
    for (var i = 0; i < array_length(keys); i++) {
        dbg_log(DBG_FLOW, "DEBUG: IF block map key[" + string(i) + "] = " + string(keys[i]));
    }



    // ── Legacy inline IF?  If no block metadata exists, invoke old handler ──
    if (!ds_map_exists(global.if_block_map, current_index)) {
        if (dbg_on(DBG_FLOW))  show_debug_message("No block metadata for line " + string(current_index) + 
                           " — falling back to INLINE IF");
        basic_cmd_if_inline(arg);
        return;
    }

    // 2) Strip off the trailing THEN and isolate the condition
    var raw     = string_trim(arg);
    var upper   = string_upper(raw);
    var then_pos = string_pos("THEN", upper);
    if (then_pos <= 0) {
        dbg_log(DBG_FLOW, "?IF ERROR: Missing THEN in '" + raw + "'");
        return;
    }
    var condition_text = string_trim(string_copy(raw, 1, then_pos - 1));
    dbg_log(DBG_FLOW, "Parsed condition: '" + condition_text + "'");

    // 3) Evaluate the condition. The shared condition evaluator handles nested
    // and repeated AND/OR expressions; do not use a local two-part splitter here.
    var result = basic_evaluate_condition(condition_text);
    dbg_log(DBG_FLOW, "Block IF condition result: " + string(result));

    // 4) Fetch the precomputed block‐metadata for this IF
    if (!ds_map_exists(global.if_block_map, current_index)) {
        dbg_log(DBG_FLOW, "?IF ERROR: No IF block metadata for line index " + string(current_index));
        return;
    }
    var blockInfo    = global.if_block_map[? current_index];
    var firstBranch  = blockInfo[? "firstBranchIndex"];

    // 5) Push a new frame onto the IF‐stack
    var frame = ds_map_create();
    ds_map_add(frame, "startIndex",      current_index);
    ds_map_add(frame, "takenBranch",     result);
    ds_map_add(frame, "firstBranchIndex", firstBranch);
    ds_map_add(frame, "endifIndex",      blockInfo[? "endifIndex"]);
    ds_map_add(frame, "elseifIndices",   blockInfo[? "elseifIndices"]);  // a ds_list of indices
    ds_map_add(frame, "elseIndex",       blockInfo[? "elseIndex"]);      // –1 if none
    ds_stack_push(global.if_stack, frame);

    // 6) Jump into THEN-block or skip to the first ELSEIF/ELSE/ENDIF
    if (result) {
        global.interpreter_use_stmt_jump = true;
        global.interpreter_target_line = current_index + 1;
        global.interpreter_target_stmt = 0;
        global.interpreter_next_line = -1;
        dbg_log(DBG_FLOW, "IF TRUE: entering THEN at index " + string(global.interpreter_target_line));
    } else {
        global.interpreter_use_stmt_jump = true;
        global.interpreter_target_line = firstBranch;
        global.interpreter_target_stmt = 0;
        global.interpreter_next_line = -1;
        dbg_log(DBG_FLOW, "IF FALSE: skipping to index " + string(global.interpreter_target_line));
    }
}
