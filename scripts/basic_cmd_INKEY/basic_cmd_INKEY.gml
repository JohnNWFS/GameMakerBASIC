// === 1. Add INKEY$ command handler ===
function basic_cmd_INKEY() {
    show_debug_message("INKEY$: Pausing program, waiting for single keypress...");
    
    global.pause_in_effect = true;
    global.awaiting_input = true;
    global.input_target_var = "__INKEY_RESULT"; // Special variable for INKEY$ result
    global.pause_mode = true;
    global.input_expected = true; // We ARE expecting input
    global.inkey_mode = true; // Flag to indicate INKEY$ mode vs regular INPUT
}