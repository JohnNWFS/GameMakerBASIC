/// @function basic_cmd_goto(arg)
/// @description Sets the program counter to a new line number if it exists.
function basic_cmd_goto(arg) {
    dbg_log(DBG_FLOW, "GOTO START — Raw arg: '" + arg + "'");

    var trimmed_arg = string_trim(arg);
    var target_arg = basic_eval_number_arg(trimmed_arg, "GOTO", "line");
    if (!target_arg.ok) return;
    var target_line = target_arg.value;

    dbg_log(DBG_FLOW, "GOTO: Parsed target line number: " + string(target_line));

    // Find the index in your line_list
    var index = -1;
	for (var i = 0; i < ds_list_size(global.line_list); i++) {
	    if (real(ds_list_find_value(global.line_list, i)) == target_line) {
	        index = i;
	        break;
	    }
	}

	
    if (index >= 0) {
        global.interpreter_next_line = index;
        dbg_log(DBG_FLOW, "GOTO SUCCESS → Jumping to line " + string(target_line) + " (list index " + string(index) + ")");
    } else {
        dbg_log(DBG_FLOW, "?GOTO ERROR: Line number " + string(target_line) + " not found in global.line_list");
    }
}
