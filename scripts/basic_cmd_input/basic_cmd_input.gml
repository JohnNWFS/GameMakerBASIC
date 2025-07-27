function basic_cmd_input(arg) {
	show_debug_message("INPUT START — DRAW COLOR: " + string(global.current_draw_color));

    global.awaiting_input = true;
    global.input_target_var = string_upper(string_trim(arg));
}
