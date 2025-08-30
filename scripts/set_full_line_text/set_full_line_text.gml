// ===============================================
// FILE: scripts/set_full_line_text/set_full_line_text.gml  
// NEW: Helper function to store complete line text
// ===============================================

/// @function set_full_line_text(editor_inst, row, text)
function set_full_line_text(editor_inst, row, text) {
    with (editor_inst) {
        if (string_length(text) > screen_cols) {
            extended_lines[? row] = text;
            show_debug_message("SCREEN_EDITOR: Stored extended line " + string(row) + ": '" + text + "'");
        } else {
            // Remove from extended storage if line is now short
            if (ds_map_exists(extended_lines, row)) {
                ds_map_delete(extended_lines, row);
                show_debug_message("SCREEN_EDITOR: Removed extended line " + string(row) + " (now fits on screen)");
            }
        }
    }
}