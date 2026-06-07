function screen_editor_exit(editor_inst) {
    with (editor_inst) {
       dbg_log(DBG_FLOW, "SCREEN_EDITOR: Exiting screen editor");
        global.screen_edit_mode = false;
        
        // CRITICAL: Clear keyboard_string to prevent leakage to obj_editor
        keyboard_string = "";
       dbg_log(DBG_FLOW, "SCREEN_EDITOR: Cleared keyboard_string");
        
        instance_destroy();
    }
}