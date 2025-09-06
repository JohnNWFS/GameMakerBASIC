/// @function basic_cmd_for(arg) 
/// @description Parses and handles BASIC FOR loop initialization (spacing-tolerant; optional STEP)
function basic_cmd_for(arg) {
    if (dbg_on(DBG_FLOW)) show_debug_message("FOR: Entering handler with argument: '" + string(arg) + "'");

    // 1) Parse "VAR = start TO end [STEP step]"
    var raw   = string_trim(string(arg));
    var eqpos = string_pos("=", raw);
    if (eqpos <= 0) {
        basic_syntax_error("FOR missing '=' - use FOR I=1 TO 10",
            global.current_line_number, global.interpreter_current_stmt_index, "FOR_SYNTAX");
        return;
    }

    var varname = string_upper(string_trim(string_copy(raw, 1, eqpos - 1)));
    if (varname == "") {
        basic_syntax_error("FOR missing variable name before '='",
            global.current_line_number, global.interpreter_current_stmt_index, "FOR_SYNTAX");
        return;
    }

    var rhs = string_trim(string_copy(raw, eqpos + 1, string_length(raw) - eqpos));

    // find TO
    var to_at = -1;
    for (var p = 1; p <= string_length(rhs) - 1; p++) {
        if (string_upper(string_copy(rhs, p, 2)) == "TO") { to_at = p; break; }
    }
    if (to_at < 0) {
        basic_syntax_error("FOR missing TO - use FOR I=1 TO 10",
            global.current_line_number, global.interpreter_current_stmt_index, "FOR_SYNTAX");
        return;
    }

    var start_expr = string_trim(string_copy(rhs, 1, to_at - 1));
    var after_to   = string_trim(string_copy(rhs, to_at + 2, string_length(rhs) - (to_at + 1)));
    if (start_expr == "" || after_to == "") {
        basic_system_message("SYNTAX ERROR IN FOR (incomplete expressions): " + raw);
        global.interpreter_running = false;
        return;
    }

    // optional STEP
    var step_expr = "1";
    var to_expr   = after_to;

    var step_at = -1;
    for (var q = 1; q <= string_length(after_to) - 3; q++) {
        if (string_upper(string_copy(after_to, q, 4)) == "STEP") { step_at = q; break; }
    }
    if (step_at > 0) {
        to_expr   = string_trim(string_copy(after_to, 1, step_at - 1));
        step_expr = string_trim(string_copy(after_to, step_at + 4, string_length(after_to) - (step_at + 3)));
        if (step_expr == "") step_expr = "1";
    }

    if (dbg_on(DBG_FLOW)) show_debug_message("FOR: Header pieces → var='" + varname
        + "' | start='" + start_expr + "' | to='" + to_expr + "' | step='" + step_expr + "'");

    // 2) Evaluate start, to, step
    var start_tokens  = basic_tokenize_expression_v2(start_expr);
    var start_postfix = infix_to_postfix(start_tokens);
    var start_val     = evaluate_postfix(start_postfix);

    var to_val_eval   = basic_evaluate_expression_v2(to_expr);
    var step_val_eval = basic_evaluate_expression_v2(step_expr);

    // --- SAFE RESOLUTION: only accept string if it's a variable name; never call real() on text ---
    if (is_string(to_val_eval)) {
        var key_to = string_upper(string_trim(to_expr));
        if (!is_undefined(global.basic_variables) && ds_map_exists(global.basic_variables, key_to)) {
            to_val_eval = global.basic_variables[? key_to];
        } else {
            basic_syntax_error("FOR ... TO must be numeric or a numeric variable",
                global.current_line_number, global.interpreter_current_stmt_index, "FOR_RANGE");
            return;
        }
    }
    if (is_string(step_val_eval)) {
        var key_step = string_upper(string_trim(step_expr));
        if (!is_undefined(global.basic_variables) && ds_map_exists(global.basic_variables, key_step)) {
            step_val_eval = global.basic_variables[? key_step];
        } else {
            // if user wrote STEP "" or a non-var string, reject
            basic_syntax_error("FOR ... STEP must be numeric or a numeric variable",
                global.current_line_number, global.interpreter_current_stmt_index, "FOR_STEP");
            return;
        }
    }

    if (dbg_on(DBG_FLOW)) show_debug_message("FOR: Eval → start=" + string(start_val)
        + " | to(eval)=" + string(to_val_eval) + " [raw='" + to_expr + "']"
        + " | step(eval)=" + string(step_val_eval) + " [raw='" + step_expr + "']");

    // 3) Initialize loop var
    if (is_undefined(global.basic_variables)) {
        basic_system_message("RUNTIME ERROR: variable store not initialized");
        global.interpreter_running = false;
        return;
    }
    global.basic_variables[? varname] = start_val;
    if (dbg_on(DBG_FLOW)) show_debug_message("FOR: Initialized variable " + varname + " = " + string(start_val));

    // 4) Push frame (legacy + inline stmt coordinates)
    var legacy_return_line = line_index;
    var loop_line_idx = line_index;
    var loop_stmt_idx = -1;
    if (variable_global_exists("interpreter_current_stmt_index")) {
        loop_stmt_idx = global.interpreter_current_stmt_index + 1;
    }

    if (!ds_exists(global.for_stack, ds_type_stack)) {
        global.for_stack = ds_stack_create();
        if (dbg_on(DBG_FLOW)) show_debug_message("FOR: Safety — created global.for_stack");
    }

    var frame = {
        varname     : varname,
        to          : to_val_eval,
        step        : step_val_eval,
        to_raw      : to_expr,       // keep raw for dynamic re-eval in NEXT
        step_raw    : step_expr,     // keep raw for dynamic re-eval in NEXT
        return_line : legacy_return_line,
        loop_line   : loop_line_idx,
        loop_stmt   : loop_stmt_idx
    };
    ds_stack_push(global.for_stack, frame);

    if (dbg_on(DBG_FLOW)) show_debug_message("FOR: Pushed frame → {var=" + varname
        + ", to=" + string(to_val_eval)
        + ", step=" + string(step_val_eval)
        + ", return_line=" + string(legacy_return_line)
        + ", loop=(" + string(loop_line_idx) + "," + string(loop_stmt_idx) + ")}");
}
