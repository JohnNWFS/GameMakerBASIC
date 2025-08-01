function basic_cmd_input(arg) {
    var varname = string_upper(string_trim(arg));
    
    show_debug_message("INPUT START — DRAW COLOR: " + string(global.current_draw_color));
    show_debug_message("INPUT: Awaiting input for variable: '" + varname + "'");

    global.awaiting_input = true;
    global.input_target_var = varname;
	global.input_expected = true;

}
