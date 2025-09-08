/// @script basic_cmd_else
/// @description Handle ELSE in a structured IF…ELSEIF…ELSE…ENDIF
function basic_cmd_else() {
    if (dbg_on(DBG_FLOW)) show_debug_message("ELSE START");

    // Guard: IF stack must exist and be non-empty
    if (!ds_exists(global.if_stack, ds_type_stack) || ds_stack_size(global.if_stack) == 0) {
        if (dbg_on(DBG_FLOW)) show_debug_message("?ELSE ERROR: ELSE without matching IF (empty IF stack)");
        return;
    }

    // Pull current IF frame (map id)
    var frame_id = ds_stack_top(global.if_stack);
    if (!ds_exists(frame_id, ds_type_map)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("?ELSE ERROR: IF frame missing/invalid map");
        return;
    }

    // Read state with safe defaults
    var taken   = ds_map_exists(frame_id, "takenBranch") ? (frame_id[? "takenBranch"]) : false;
    var endifIx = ds_map_exists(frame_id, "endifIndex")  ? (frame_id[? "endifIndex"])  : -1;

    var current_index = global.interpreter_current_line_index;

    if (taken) {
        // Already ran IF or an ELSEIF → skip ELSE body to ENDIF (if known)
        if (endifIx >= 0) {
            global.interpreter_next_line = endifIx;
            if (dbg_on(DBG_FLOW)) show_debug_message("ELSE skipping to ENDIF at index " + string(endifIx));
        } else {
            // Fallback: advance one line if ENDIF index unknown
            global.interpreter_next_line = current_index + 1;
            if (dbg_on(DBG_FLOW)) show_debug_message("ELSE: no ENDIF index; advancing to " + string(global.interpreter_next_line));
        }
    } else {
        // No branch taken yet → execute ELSE body
        ds_map_replace(frame_id, "takenBranch", true);
        global.interpreter_next_line = current_index + 1;
        if (dbg_on(DBG_FLOW)) show_debug_message("ELSE entering branch at index " + string(global.interpreter_next_line));
    }
}
