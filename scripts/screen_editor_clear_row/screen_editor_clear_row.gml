// ===============================================
// FILE: scripts/screen_editor_clear_row/screen_editor_clear_row.gml
// NEW: Helper function to clear a display row
// ===============================================

/// @function screen_editor_clear_row(editor_inst, _row)
function screen_editor_clear_row(editor_inst, _row) {
    with (editor_inst) {
        if (_row < 0 || _row >= screen_rows) return;
        for (var _x = 0; _x < screen_cols; _x++) {
            screen_editor_set_char_at(id, _x, _row, ord(" "));
        }
       dbg_log(DBG_FLOW, "SCREEN_EDITOR: Cleared row " + string(_row));
    }
}