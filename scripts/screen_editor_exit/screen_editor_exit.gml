function screen_editor_exit(editor_inst) {
    with (editor_inst) {
        show_debug_message("SCREEN_EDITOR: Exiting screen editor");
        global.screen_edit_mode = false;
        
        // CRITICAL: Clear keyboard_string to prevent leakage to obj_editor
        keyboard_string = "";
        show_debug_message("SCREEN_EDITOR: Cleared keyboard_string");
        
        instance_destroy();
    }
}