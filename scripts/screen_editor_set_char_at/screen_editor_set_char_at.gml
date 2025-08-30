// FILE: scripts/screen_editor_set_char_at/screen_editor_set_char_at.gml
/// @function screen_editor_set_char_at(editor_inst, _x, _y, _char)
function screen_editor_set_char_at(editor_inst, _x, _y, _char) {
    with (editor_inst) {
        if (_x < 0 || _x >= screen_cols || _y < 0 || _y >= screen_rows) return;
        var idx = _y * screen_cols + _x;
        screen_buffer[idx] = _char;
        //show_debug_message("SCREEN_EDITOR: Set char '" + chr(_char) + "' at (" + string(_x) + "," + string(_y) + ")");
    }
}