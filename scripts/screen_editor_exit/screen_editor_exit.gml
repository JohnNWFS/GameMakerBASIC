function screen_editor_exit(editor_inst) {
    with (editor_inst) {
       if (dbg_on(DBG_FLOW)) show_debug_message("SCREEN_EDITOR: Exiting screen editor");
        global.screen_edit_mode = false;
        
        // CRITICAL: Clear keyboard_string to prevent leakage to obj_editor
        keyboard_string = "";
       if (dbg_on(DBG_FLOW)) show_debug_message("SCREEN_EDITOR: Cleared keyboard_string");
        
        instance_destroy();
    }
}