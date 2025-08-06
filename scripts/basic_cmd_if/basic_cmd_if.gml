/// @script basic_cmd_if
/// @description Block‐structured IF…THEN…ELSEIF…ELSE…ENDIF initializer
function basic_cmd_if(arg) {
    show_debug_message("IF START — Raw arg: '" + arg + "'");

    // 1) Compute the current line‐list index (we assume global.interpreter_next_line was pre-incremented)
    var current_index = global.interpreter_current_line_index;

    // ── Legacy inline IF?  If no block metadata exists, invoke old handler ──
    if (!ds_map_exists(global.if_block_map, current_index)) {
        show_debug_message("No block metadata for line " + string(current_index) + 
                           " — falling back to INLINE IF");
        basic_cmd_if_inline(arg);
        return;
    }

    // 2) Strip off the trailing THEN and isolate the condition
    var raw     = string_trim(arg);
    var upper   = string_upper(raw);
    var then_pos = string_pos("THEN", upper);
    if (then_pos <= 0) {
        show_debug_message("?IF ERROR: Missing THEN in '" + raw + "'");
        return;
    }
    var condition_text = string_trim(string_copy(raw, 1, then_pos - 1));
    show_debug_message("Parsed condition: '" + condition_text + "'");

    // 3) Evaluate the condition (supporting simple AND/OR)
    var result    = false;
    var logic_op  = "";
    var upcond    = string_upper(condition_text);
    if (string_pos("AND", upcond) > 0) logic_op = "AND";
    else if (string_pos("OR", upcond) > 0) logic_op = "OR";

    if (logic_op != "") {
        var parts = string_split(condition_text, logic_op);
        if (array_length(parts) != 2) {
            show_debug_message("?IF ERROR: Malformed " + logic_op + " condition: '" + condition_text + "'");
            return;
        }
        var res1 = basic_evaluate_condition(string_trim(parts[0]));
        var res2 = basic_evaluate_condition(string_trim(parts[1]));
        result = (logic_op == "AND") ? (res1 && res2) : (res1 || res2);
        show_debug_message("Combined condition (" + logic_op + "): " +
                           string(res1) + " " + logic_op + " " + string(res2) +
                           " = " + string(result));
    } else {
        result = basic_evaluate_condition(condition_text);
        show_debug_message("Single condition result: " + string(result));
    }

    // 4) Fetch the precomputed block‐metadata for this IF
    if (!ds_map_exists(global.if_block_map, current_index)) {
        show_debug_message("?IF ERROR: No IF block metadata for line index " + string(current_index));
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

    // 6) Jump into THEN‐block or skip to the first ELSEIF/ELSE/ENDIF
    if (result) {
        global.interpreter_next_line = current_index + 1;
        show_debug_message("IF TRUE: entering THEN at index " + string(global.interpreter_next_line));
    } else {
        global.interpreter_next_line = firstBranch;
        show_debug_message("IF FALSE: skipping to index " + string(global.interpreter_next_line));
    }
}
