function basic_cmd_pause() {
    show_debug_message("PAUSE: Execution paused. Waiting for user to press ENTER...");

	global.pause_in_effect = true;
    global.awaiting_input = true;
    global.input_target_var = ""; // No variable to store
    global.pause_mode = true;     // Optional flag if you want to treat it differently in draw
	global.input_expected = false;

}
