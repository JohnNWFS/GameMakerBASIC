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
    var start = real(parts[2]);
    var to_val = real(parts[4]);

    var step = 1; // Default step
    if (array_length(parts) >= 7 && string_upper(parts[5]) == "STEP") {
        step = real(parts[6]);
    }

    show_debug_message("FOR: Parsed var='" + varname + "', start=" + string(start) + ", to=" + string(to_val) + ", step=" + string(step));

    // Initialize the loop control variable
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
