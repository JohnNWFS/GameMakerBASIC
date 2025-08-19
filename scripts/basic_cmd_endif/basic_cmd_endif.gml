/// @script basic_cmd_endif
/// @description Handle ENDIF—pop IF-stack and continue
function basic_cmd_endif() {
  if (dbg_on(DBG_FLOW))  show_debug_message("ENDIF START");
    // ← GUARD: must have an open IF
    if (ds_stack_empty(global.if_stack)) {
        if (dbg_on(DBG_FLOW))  show_debug_message("?ENDIF ERROR: ENDIF without matching IF");
        return;
    }
    var frame = ds_stack_pop(global.if_stack);

    var current_index = global.interpreter_current_line_index;
    // Pop and destroy the frame

    ds_map_destroy(frame);

    // Continue immediately after ENDIF
    global.interpreter_next_line = current_index + 1;
    if (dbg_on(DBG_FLOW))  show_debug_message("ENDIF done, next index " + string(global.interpreter_next_line));
}
