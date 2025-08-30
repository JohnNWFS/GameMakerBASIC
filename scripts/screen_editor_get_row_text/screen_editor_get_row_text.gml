// FILE: scripts/screen_editor_get_row_text/screen_editor_get_row_text.gml
/// @function screen_editor_get_row_text(editor_inst, _row)
function screen_editor_get_row_text(editor_inst, _row) {
    with (editor_inst) {
        if (_row < 0 || _row >= screen_rows) return "";
        
        var text = "";
        var last_non_space = -1;
        
        for (var _x = 0; _x < screen_cols; _x++) {
            var ch = chr(screen_editor_get_char_at(id, _x, _row));
            text += ch;
            if (ch != " ") last_non_space = _x;
        }
        
        return (last_non_space >= 0) ? string_copy(text, 1, last_non_space + 1) : "";
    }
}