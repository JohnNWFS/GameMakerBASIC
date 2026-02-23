// Call this to display a message for roughly 2 seconds (120 frames at 60 fps).
function basic_show_message(msg) {
    message_text  = msg;
    global.message_timer = 120;
}

/// @function basic_print_system_message(msg)
/// @description Thin alias kept for legacy call sites in basic_cmd_font / basic_cmd_fontset.
function basic_print_system_message(msg) {
    basic_show_message(msg);
}
