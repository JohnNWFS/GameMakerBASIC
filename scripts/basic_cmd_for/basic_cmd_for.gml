/// @function basic_cmd_for(arg)
/// @description Parses and handles BASIC FOR loop initialization

function basic_cmd_for(arg) {
    // Expected syntax: FOR I = 1 TO 10 STEP 1 (STEP is optional)
    var parts = string_split(arg, " ");
    if (array_length(parts) < 4 || parts[1] != "=" || string_upper(parts[3]) != "TO") {
        basic_show_message("SYNTAX ERROR IN FOR STATEMENT: " + arg);
        global.interpreter_running = false;
        return;
    }

    var varname = string_upper(parts[0]);
    var start = real(parts[2]);
    var to_val = real(parts[4]);

    var step = 1; // default
    if (array_length(parts) >= 7 && string_upper(parts[5]) == "STEP") {
        step = real(parts[6]);
    }

    // Store the variable in the global BASIC variable map
    global.basic_variables[? varname] = start;

    // Push loop frame to the for_stack
    var frame = {
        varname: varname,
        to: to_val,
        step: step,
        return_line: line_index  // line_index points to current FOR line
    };
    ds_stack_push(global.for_stack, frame);
}
