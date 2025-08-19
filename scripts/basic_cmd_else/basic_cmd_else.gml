/// @script basic_cmd_else
/// @description Handle ELSE in a structured IF…ELSEIF…ELSE…ENDIF
function basic_cmd_else() {
    if (dbg_on(DBG_FLOW))  show_debug_message("ELSE START");
    // ← GUARD: must have an open IF
    if (ds_stack_empty(global.if_stack)) {
        if (dbg_on(DBG_FLOW))  show_debug_message("?ELSE ERROR: ELSE without matching IF");
        return;
    }
	
    var frame = ds_stack_top(global.if_stack);
    var taken = frame[? "takenBranch"];

    var current_index = global.interpreter_current_line_index;
    var endifIx = frame[? "endifIndex"];

    if (taken) {
        // Already ran IF or an ELSEIF → skip entire ELSE-block
        global.interpreter_next_line = endifIx;
        if (dbg_on(DBG_FLOW))  show_debug_message("ELSE skipping to ENDIF at index " + string(endifIx));
    } else {
        // No branch yet taken → run ELSE body
        ds_map_replace(frame, "takenBranch", true);
        global.interpreter_next_line = current_index + 1;
        if (dbg_on(DBG_FLOW))  show_debug_message("ELSE entering branch at index " + string(global.interpreter_next_line));
    }
}
