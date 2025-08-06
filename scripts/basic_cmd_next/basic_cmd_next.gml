/// @function basic_cmd_next(arg)
/// @description Handles BASIC NEXT loop continuation

function basic_cmd_next(arg) {
    show_debug_message("NEXT: Entering handler");

    if (ds_stack_empty(global.for_stack)) {
        show_debug_message("NEXT: ERROR — NEXT without matching FOR");
        basic_show_message("NEXT without FOR");
        global.interpreter_running = false;
        return;
    }

    var frame = ds_stack_top(global.for_stack);

    var varname = frame.varname;
    var to_val = frame.to;
    var step = frame.step;
    var return_line = frame.return_line;

    var current = global.basic_variables[? varname];
    show_debug_message("NEXT: Current value of " + varname + " = " + string(current));

    current += step;
    global.basic_variables[? varname] = current;
    show_debug_message("NEXT: Updated value of " + varname + " = " + string(current));

    var continue_loop = (step > 0) ? (current <= to_val) : (current >= to_val);
    show_debug_message("NEXT: Loop check — continue = " + string(continue_loop));

    if (continue_loop) {
        global.interpreter_next_line = return_line + 1;
        show_debug_message("NEXT: Looping back to line index: " + string(global.interpreter_next_line));
    } else {
        ds_stack_pop(global.for_stack);
        show_debug_message("NEXT: Loop complete — popped FOR frame");
    }
}
