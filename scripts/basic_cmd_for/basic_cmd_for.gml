/// @function basic_cmd_for(arg) 
/// @description Parses and handles BASIC FOR loop initialization (spacing-tolerant; optional STEP)
///
/// Accepted headers:
///   FOR I=1 TO 5
///   FOR I = 1 TO 5
///   FOR I=1 TO 5 STEP 2
///
/// Notes:
/// - We KEEP legacy behavior: frame.return_line = line_index (whatever your dispatcher sets).
/// - We also store loop_line/loop_stmt = -1 as placeholders for future inline-colon support.
/// - Uses only globals you already define in obj_globals Create Event.

function basic_cmd_for(arg) {
    show_debug_message("FOR: Entering handler with argument: '" + string(arg) + "'");

    // --------------------------
    // 1) Normalize / find '='
    // --------------------------
    var raw   = string_trim(string(arg));
    var eqpos = string_pos("=", raw);
    if (eqpos <= 0) {
        show_debug_message("FOR: SYNTAX ERROR — missing '=' in header: '" + raw + "'");
        basic_system_message("SYNTAX ERROR IN FOR: " + raw); // CHANGED
        global.interpreter_running = false;
        return;
    }

    // Left of '=' is the loop variable name
    var varname = string_upper(string_trim(string_copy(raw, 1, eqpos - 1)));
    if (varname == "") {
        show_debug_message("FOR: SYNTAX ERROR — empty variable name before '='");
        basic_system_message("SYNTAX ERROR IN FOR (empty variable): " + raw); // CHANGED
        global.interpreter_running = false;
        return;
    }

    // Right side after '=' should contain: start_expr  TO  to_expr  [ STEP step_expr ]
    var rhs  = string_trim(string_copy(raw, eqpos + 1, string_length(raw) - eqpos));
    var rhsU = string_upper(rhs);

    // --------------------------
    // 2) Locate 'TO' (case-insensitive)
    // --------------------------
    var to_at = -1;
    // Scan explicitly to avoid false positives and keep positions in the ORIGINAL rhs string
    for (var p = 1; p <= string_length(rhs) - 1; p++) {
        if (string_upper(string_copy(rhs, p, 2)) == "TO") {
            to_at = p;
            break;
        }
    }
    if (to_at < 0) {
        show_debug_message("FOR: SYNTAX ERROR — missing 'TO' in: '" + rhs + "'");
        basic_system_message("SYNTAX ERROR IN FOR (missing TO): " + raw); // CHANGED
        global.interpreter_running = false;
        return;
    }

    var start_expr = string_trim(string_copy(rhs, 1, to_at - 1));
    var after_to   = string_trim(string_copy(rhs, to_at + 2, string_length(rhs) - (to_at + 1)));

    if (start_expr == "" || after_to == "") {
        show_debug_message("FOR: SYNTAX ERROR — start/to expressions incomplete. start='" + start_expr + "', after_to='" + after_to + "'");
        basic_system_message("SYNTAX ERROR IN FOR (incomplete expressions): " + raw); // CHANGED
        global.interpreter_running = false;
        return;
    }

    // --------------------------
    // 3) Optional 'STEP'
    // --------------------------
    var step_expr = "1";
    var to_expr   = after_to;

    var step_at = -1;
    for (var q = 1; q <= string_length(after_to) - 3; q++) {
        if (string_upper(string_copy(after_to, q, 4)) == "STEP") {
            step_at = q;
            break;
        }
    }
    if (step_at > 0) {
        to_expr   = string_trim(string_copy(after_to, 1, step_at - 1));
        step_expr = string_trim(string_copy(after_to, step_at + 4, string_length(after_to) - (step_at + 3)));
        if (step_expr == "") step_expr = "1";
    }

    show_debug_message("FOR: Header pieces → var='" + varname + "' | start='" + start_expr + "' | to='" + to_expr + "' | step='" + step_expr + "'");

    // --------------------------
    // 4) Evaluate expressions
    // --------------------------
    var start_tokens  = basic_tokenize_expression_v2(start_expr);
    var start_postfix = infix_to_postfix(start_tokens);
    var start_val     = evaluate_postfix(start_postfix);

    var to_tokens     = basic_tokenize_expression_v2(to_expr);
    var to_postfix    = infix_to_postfix(to_tokens);
    var to_val        = evaluate_postfix(to_postfix);

	var step_val = basic_evaluate_expression_v2(step_expr);


    show_debug_message("FOR: Evaluated values → start=" + string(start_val) + " | to=" + string(to_val) + " | step=" + string(step_val));

    if (step_val == 0) {
        show_debug_message("FOR: WARNING — STEP evaluated to 0; loop would never progress.");
        // Deliberately not auto-fixing to keep semantics obvious. NEXT will handle termination.
    }

    // --------------------------
    // 5) Initialize loop variable
    // --------------------------
    if (!is_undefined(global.basic_variables)) {
        global.basic_variables[? varname] = start_val;
        show_debug_message("FOR: Initialized variable " + varname + " = " + string(start_val));
    } else {
        show_debug_message("FOR: ERROR — global.basic_variables map is undefined.");
        basic_system_message("RUNTIME ERROR: variable store not initialized"); // CHANGED
        global.interpreter_running = false;
        return;
    }

    // --------------------------
    // 6) Prepare and push loop frame
    // --------------------------
    // Keep legacy behavior: your NEXT handler already uses return_line.
    // DO NOT rename this unless you also change NEXT.
    var legacy_return_line = line_index; // relies on the dispatcher’s local/outer variable

    // Record the exact spot to jump back to: the statement AFTER the FOR header
    var loop_line_idx = line_index; // current BASIC line (e.g., 20)
    var loop_stmt_idx = -1;

    // We exposed the current statement index in the Step event (Fix 1).
    // The loop body starts at the very next colon slot.
    if (variable_global_exists("interpreter_current_stmt_index")) {
        loop_stmt_idx = global.interpreter_current_stmt_index + 1;
    }

    show_debug_message("FOR: Loop entry captured → line=" + string(loop_line_idx)
        + ", stmt(after header)=" + string(loop_stmt_idx));

    // Ensure for_stack exists (safety)
    if (!ds_exists(global.for_stack, ds_type_stack)) {
        global.for_stack = ds_stack_create();
        show_debug_message("FOR: Safety — created global.for_stack");
    }

    var frame = {
        varname     : varname,
        to          : to_val,
        step        : step_val,
        return_line : legacy_return_line, // legacy jump target used by current NEXT

        // Inline support placeholders (not used until NEXT is updated)
        loop_line   : loop_line_idx,
        loop_stmt   : loop_stmt_idx
    };

    ds_stack_push(global.for_stack, frame);

    show_debug_message("FOR: Pushed frame → {var=" + varname
        + ", to=" + string(to_val)
        + ", step=" + string(step_val)
        + ", return_line=" + string(legacy_return_line)
        + ", loop=(" + string(loop_line_idx) + "," + string(loop_stmt_idx) + ")}");
}
