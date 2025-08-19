/// @function basic_cmd_next(arg)
/// @description Handles BASIC NEXT loop continuation (legacy-compatible; optional inline-colon support)
///
/// Behavior:
/// - Legacy: jumps using frame.return_line (set by FOR) → global.interpreter_next_line = return_line + 1
/// - Optional: if your engine exposes statement-level jump globals AND the FOR frame
///   has loop_line/loop_stmt >= 0, jump to that exact (line, stmt).
///
/// Note:
/// - We accept but do not require "NEXT I". If supplied and it doesn't match the top frame,
///   we log a warning (no stack search to keep behavior unchanged).

function basic_cmd_next(arg) {
    if (dbg_on(DBG_FLOW))  show_debug_message("NEXT: Entering handler with arg: '" + string(arg) + "'");

    // --------------------------
    // 0) Validate FOR stack
    // --------------------------
    if (!ds_exists(global.for_stack, ds_type_stack) || ds_stack_empty(global.for_stack)) {
        if (dbg_on(DBG_FLOW))  show_debug_message("NEXT: ERROR — NEXT without matching FOR");
        basic_system_message("NEXT without FOR");
        global.interpreter_running = false;
        return;
    }

    // Peek the current FOR frame
    var frame = ds_stack_top(global.for_stack);

    // --------------------------
    // 1) Optional var check: "NEXT I"
    // --------------------------
    var user_var = string_trim(string_upper(string(arg)));
    if (user_var != "") {
        if (is_struct(frame) && variable_struct_exists(frame, "varname")) {
            if (string_upper(frame.varname) != user_var) {
                // Do NOT alter control flow; just warn (no stack search to avoid side effects).
                if (dbg_on(DBG_FLOW))  show_debug_message("NEXT: WARNING — NEXT " + user_var + " does not match active FOR var " + string(frame.varname));
            }
        }
    }

    // --------------------------
    // 2) Load frame fields
    // --------------------------
    var varname     = frame.varname;
    var to_val      = frame.to;
    var step_val    = frame.step;
    var return_line = frame.return_line;

    // Placeholders for inline-colon support (may be -1 until wired in FOR)
    var loop_line   = (variable_struct_exists(frame, "loop_line")) ? frame.loop_line : -1;
    var loop_stmt   = (variable_struct_exists(frame, "loop_stmt")) ? frame.loop_stmt : -1;

    // --------------------------
    // 3) Validate variable store
    // --------------------------
    if (is_undefined(global.basic_variables)) {
        if (dbg_on(DBG_FLOW))  show_debug_message("NEXT: ERROR — global.basic_variables is undefined.");
        basic_system_message("RUNTIME ERROR: variable store not initialized");
        global.interpreter_running = false;
        return;
    }

    // Fetch current value
    var current = global.basic_variables[? varname];
    if (dbg_on(DBG_FLOW))  show_debug_message("NEXT: Current value of " + string(varname) + " = " + string(current));

    // --------------------------
    // 3a) Sanitize to_val / step_val BEFORE applying the step
    // --------------------------
    if (is_string(to_val))   to_val   = basic_evaluate_expression_v2(to_val);
    if (is_string(step_val)) step_val = basic_evaluate_expression_v2(step_val);

    // Guard against STEP=0 to avoid infinite loop when parser fed 0 (e.g., unary minus mishap)
    if (step_val == 0) {
        var inferred = (to_val >= current) ? 1 : -1;
        if (dbg_on(DBG_FLOW))  show_debug_message("NEXT: STEP evaluated to 0; defaulting to " + string(inferred));
        step_val = inferred;
    }

    // --------------------------
    // 3b) NOW apply the step and persist the loop var
    // --------------------------
    current += step_val;
    global.basic_variables[? varname] = current;
    if (dbg_on(DBG_FLOW))  show_debug_message("NEXT: Updated value of " + string(varname) + " = " + string(current));

    // --------------------------
    // 4) Continuation test
    // --------------------------
    var continue_loop = (step_val > 0) ? (current <= to_val) : (current >= to_val);
    if (dbg_on(DBG_FLOW))  show_debug_message("NEXT: Loop check — continue = " + string(continue_loop)
        + " (to=" + string(to_val) + ", step=" + string(step_val) + ")");

    if (continue_loop) {
        // --------------------------------------------
        // 5a) CONTINUE: perform the jump for next iter
        // --------------------------------------------

        // Try statement-level jump first (only if you’ve exposed the globals)
        var have_stmt_jump =
            variable_global_exists("interpreter_target_line") &&
            variable_global_exists("interpreter_target_stmt");

        if (have_stmt_jump && loop_line >= 0 && loop_stmt >= 0) {
            global.interpreter_target_line = loop_line;
            global.interpreter_target_stmt = loop_stmt;
            if (variable_global_exists("interpreter_use_stmt_jump")) {
                global.interpreter_use_stmt_jump = true;
            }
            if (dbg_on(DBG_FLOW))  show_debug_message("NEXT: Inline jump to (line, stmt) = (" + string(loop_line) + ", " + string(loop_stmt) + ")");
        } else {
            // Legacy compatible line-based jump (what you have today)
            global.interpreter_next_line = return_line + 1;
            if (dbg_on(DBG_FLOW))  show_debug_message("NEXT: Legacy jump — looping back to line index: " + string(global.interpreter_next_line));
        }

    } else {
        // --------------------------------------------
        // 5b) COMPLETE: pop frame and continue after NEXT
        // --------------------------------------------
        ds_stack_pop(global.for_stack);
        if (dbg_on(DBG_FLOW))  show_debug_message("NEXT: Loop complete — popped FOR frame");
        // Execution naturally proceeds to the next statement after NEXT
    }
}
