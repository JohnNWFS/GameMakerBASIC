/// @function basic_cmd_goto(arg)
/// @description Sets the program counter to a new line number if it exists.
function basic_cmd_goto(arg) {
    var target_line = real(string_trim(arg));
    if (ds_map_exists(global.basic_program, target_line)) {
        global.justreturned = 1;
        global.program_counter = target_line;
    } else {
        show_debug_message("?GOTO ERROR: Line " + string(target_line) + " not found");
        global.program_counter = -1;
    }
}
