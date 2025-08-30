// FILE: scripts/screen_editor_get_char_at/screen_editor_get_char_at.gml
/// @function screen_editor_get_char_at(editor_inst, _x, _y)
function screen_editor_get_char_at(editor_inst, _x, _y) {
    with (editor_inst) {
        if (_x < 0 || _x >= screen_cols || _y < 0 || _y >= screen_rows) return ord(" ");
        var idx = _y * screen_cols + _x;
        return screen_buffer[idx];
    }
}