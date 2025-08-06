/// @function basic_cmd_for(arg)
/// @description Parses and handles BASIC FOR loop initialization

function basic_cmd_for(arg) {
    show_debug_message("FOR: Entering handler with argument: '" + arg + "'");

    var parts = string_split(arg, " ");
    if (array_length(parts) < 4 || parts[1] != "=" || string_upper(parts[3]) != "TO") {
        show_debug_message("FOR: SYNTAX ERROR — parts = " + string(parts));
        basic_show_message("SYNTAX ERROR IN FOR STATEMENT: " + arg);
        global.interpreter_running = false;
        return;
    }

    var varname = string_upper(parts[0]);

    // Evaluate start expression
    var start_expr = parts[2];
    var start_tokens = basic_tokenize_expression_v2(start_expr);
    var start_postfix = infix_to_postfix(start_tokens);
    var start = evaluate_postfix(start_postfix);

    // Evaluate TO expression
    var to_val_expr = parts[4];
    var to_val_tokens = basic_tokenize_expression_v2(to_val_expr);
    var to_val_postfix = infix_to_postfix(to_val_tokens);
    var to_val = evaluate_postfix(to_val_postfix);

    // Default step
    var step = 1;

    // Evaluate optional STEP expression
    if (array_length(parts) >= 7 && string_upper(parts[5]) == "STEP") {
        var step_expr = parts[6];
        var step_tokens = basic_tokenize_expression_v2(step_expr);
        var step_postfix = infix_to_postfix(step_tokens);
        step = evaluate_postfix(step_postfix);
    }

    show_debug_message("FOR: Parsed var='" + varname + "', start=" + string(start) + ", to=" + string(to_val) + ", step=" + string(step));

    // Initialize loop control variable
    global.basic_variables[? varname] = start;
    show_debug_message("FOR: Initialized variable " + varname + " = " + string(start));

    // Ensure the for_stack exists
    if (!ds_exists(global.for_stack, ds_type_stack)) {
        global.for_stack = ds_stack_create();
        show_debug_message("FOR: Created new for_stack");
    }

    // Build and push loop frame
    var frame = {
        varname: varname,
        to: to_val,
        step: step,
        return_line: line_index  // will resume at NEXT
    };
    ds_stack_push(global.for_stack, frame);
    show_debug_message("FOR: Pushed frame to for_stack with return_line = " + string(line_index));
}
