/// @function basic_cmd_goto(arg)
/// @description Sets the program counter to a new line number if it exists.
function basic_cmd_goto(arg) {
    show_debug_message("GOTO TRIGGERED");
    var target_line = real(string_trim(arg));
    
    // Find the index in your line_list
    var index = ds_list_find_index(global.line_list, target_line);
    if (index >= 0) {
        interpreter_next_line = index;
        show_debug_message("GOTO successful → line " + string(target_line) + " (index " + string(index) + ")");
    } else {
        show_debug_message("?GOTO ERROR: Line " + string(target_line) + " not found");
    }
}