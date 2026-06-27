/// @function start_tile_editor()
/// @description Launch the interactive MODE 2 custom tile editor from rm_editor.

function start_tile_editor() {
    dbg_log(DBG_FLOW, "COMMAND: start_tile_editor called");

    if (global.tile_edit_mode) {
        basic_show_message("Tile editor already active");
        return;
    }

    if (global.screen_edit_mode) {
        basic_show_message("Exit screen editor first");
        return;
    }

    global.tile_edit_mode = true;
    instance_create_layer(0, 0, "Instances", obj_tile_editor);
    basic_show_message("Tile editor — arrows paint, ESC exit");
}