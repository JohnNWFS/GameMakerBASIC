/// @function basic_cmd_goto(arg)
/// @description Sets the program counter to a new line number if it exists.
function basic_cmd_goto(arg) {
    show_debug_message("GOTO START — Raw arg: '" + arg + "'");

    var trimmed_arg = string_trim(arg);
    var target_line = real(trimmed_arg);

    show_debug_message("GOTO: Parsed target line number: " + string(target_line));

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
        show_debug_message("GOTO SUCCESS → Jumping to line " + string(target_line) + " (list index " + string(index) + ")");
    } else {
        show_debug_message("?GOTO ERROR: Line number " + string(target_line) + " not found in global.line_list");
    }
}
