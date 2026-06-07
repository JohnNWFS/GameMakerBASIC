/// @script basic_cmd_endif
/// @description Handle ENDIF—pop IF-stack and continue
function basic_cmd_endif() {
  dbg_log(DBG_FLOW, "ENDIF START");
    // ← GUARD: must have an open IF
    if (ds_stack_empty(global.if_stack)) {
        dbg_log(DBG_FLOW, "?ENDIF ERROR: ENDIF without matching IF");
        return;
    }
    var frame = ds_stack_pop(global.if_stack);

    var current_index = global.interpreter_current_line_index;
    // Pop and destroy the frame

    ds_map_destroy(frame);

    // Continue immediately after ENDIF
    global.interpreter_use_stmt_jump = true;
    global.interpreter_target_line = current_index + 1;
    global.interpreter_target_stmt = 0;
    global.interpreter_next_line = -1;
    dbg_log(DBG_FLOW, "ENDIF done, next index " + string(global.interpreter_target_line));
}
