// ===============================================
// FILE: scripts/get_full_line_text/get_full_line_text.gml
// NEW: Helper function to get complete line text
// ===============================================

/// @function get_full_line_text(editor_inst, row)
function get_full_line_text(editor_inst, row) {
    with (editor_inst) {
        if (ds_map_exists(extended_lines, row)) {
            return extended_lines[? row];
        }
        return screen_editor_get_row_text(id, row);
    }
}