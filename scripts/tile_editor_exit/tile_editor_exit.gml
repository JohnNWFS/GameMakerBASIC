function tile_editor_exit(editor_inst) {
    with (editor_inst) {
        dbg_log(DBG_FLOW, "TILE_EDITOR: exiting");
        global.tile_edit_mode = false;
        keyboard_string = "";
        instance_destroy();
    }
}