/// @function basic_cmd_next(arg)
/// @description Handles BASIC NEXT loop continuation

function basic_cmd_next(arg) {
    if (ds_stack_empty(global.for_stack)) {
        basic_show_message("NEXT without FOR");
        global.interpreter_running = false;
        return;
    }

    var frame = ds_stack_top(global.for_stack);

    var varname = frame.varname;
    var to_val = frame.to;
    var step = frame.step;
    var return_line = frame.return_line;

    // Safely get and increment the loop variable
    var current = global.basic_variables[? varname];
    current += step;
    global.basic_variables[? varname] = current;

    // Determine whether the loop should continue
    var continue_loop = (step > 0) ? (current <= to_val) : (current >= to_val);

    if (continue_loop) {
        // Rewind to the line after the FOR
        interpreter_next_line = return_line + 1;
    } else {
        ds_stack_pop(global.for_stack);
    }
}
