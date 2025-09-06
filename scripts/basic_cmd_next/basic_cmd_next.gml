/// @function basic_cmd_next(arg)
/// @description Handles BASIC NEXT loop continuation (legacy-compatible; optional inline-colon support)
function basic_cmd_next(arg) {
    if (dbg_on(DBG_FLOW)) show_debug_message("NEXT: Entering handler with arg: '" + string(arg) + "'");

    if (!ds_exists(global.for_stack, ds_type_stack) || ds_stack_empty(global.for_stack)) {
        basic_syntax_error("NEXT without matching FOR",
            global.current_line_number, global.interpreter_current_stmt_index, "FOR_MISMATCH");
        return;
    }

    var frame = ds_stack_top(global.for_stack);

    // Optional check: NEXT I
    var user_var = string_trim(string_upper(string(arg)));
    if (user_var != "" && is_struct(frame) && variable_struct_exists(frame, "varname")) {
        if (string_upper(frame.varname) != user_var && dbg_on(DBG_FLOW)) {
            show_debug_message("NEXT: WARNING — NEXT " + user_var + " does not match active FOR var " + string(frame.varname));
        }
    }

    var varname     = frame.varname;
    var to_val      = frame.to;
    var step_val    = frame.step;
    var return_line = frame.return_line;
    var loop_line   = (variable_struct_exists(frame, "loop_line")) ? frame.loop_line : -1;
    var loop_stmt   = (variable_struct_exists(frame, "loop_stmt")) ? frame.loop_stmt : -1;

    if (is_undefined(global.basic_variables)) {
        basic_system_message("RUNTIME ERROR: variable store not initialized");
        global.interpreter_running = false;
        return;
    }

    // Re-evaluate TO / STEP each iteration if they weren’t numeric
    if (!is_real(to_val)) {
        var to_expr_local = variable_struct_exists(frame, "to_raw") ? frame.to_raw : to_val;
        to_val = basic_evaluate_expression_v2(to_expr_local);
        if (is_string(to_val)) {
            var key_to = string_upper(string_trim(to_expr_local));
            if (!ds_map_exists(global.basic_variables, key_to)) {
                basic_syntax_error("FOR ... TO must be numeric",
                    global.current_line_number, global.interpreter_current_stmt_index, "FOR_TO_NONNUM");
                return;
            }
            to_val = global.basic_variables[? key_to];
        }
        frame.to = to_val;
    }
    if (!is_real(step_val)) {
        var step_expr_local = variable_struct_exists(frame, "step_raw") ? frame.step_raw : step_val;
        step_val = basic_evaluate_expression_v2(step_expr_local);
        if (is_string(step_val)) {
            var key_step = string_upper(string_trim(step_expr_local));
            if (!ds_map_exists(global.basic_variables, key_step)) {
                // default if someone did STEP with a non-numeric symbol
                step_val = 1;
            } else {
                step_val = global.basic_variables[? key_step];
            }
        }
        frame.step = step_val;
    }

    var current = global.basic_variables[? varname];

    if (step_val == 0) {
        var inferred = (to_val >= current) ? 1 : -1;
        if (dbg_on(DBG_FLOW)) show_debug_message("NEXT: STEP=0; defaulting to " + string(inferred));
        step_val = inferred;
        frame.step = step_val;
    }

    current += step_val;
    global.basic_variables[? varname] = current;

    var continue_loop = (step_val > 0) ? (current <= to_val) : (current >= to_val);
    if (dbg_on(DBG_FLOW)) show_debug_message("NEXT: to=" + string(to_val)
        + " step=" + string(step_val) + " current=" + string(current)
        + " → continue=" + string(continue_loop));

    if (continue_loop) {
        var have_stmt_jump =
            variable_global_exists("interpreter_target_line") &&
            variable_global_exists("interpreter_target_stmt");

        if (have_stmt_jump && loop_line >= 0 && loop_stmt >= 0) {
            global.interpreter_target_line = loop_line;
            global.interpreter_target_stmt = loop_stmt;
            if (variable_global_exists("interpreter_use_stmt_jump")) {
                global.interpreter_use_stmt_jump = true;
            }
            if (dbg_on(DBG_FLOW)) show_debug_message("NEXT: Inline jump → (" + string(loop_line) + "," + string(loop_stmt) + ")");
        } else {
            global.interpreter_next_line = return_line + 1; // legacy line jump
            if (dbg_on(DBG_FLOW)) show_debug_message("NEXT: Legacy jump → line index " + string(global.interpreter_next_line));
        }
    } else {
        ds_stack_pop(global.for_stack);
        if (dbg_on(DBG_FLOW)) show_debug_message("NEXT: Loop complete — popped FOR frame");
    }
}
