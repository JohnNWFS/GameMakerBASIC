// ===============================================
// FILE: scripts/refresh_current_line_display/refresh_current_line_display.gml
// NEW: Helper function to update display for current line
// ===============================================

/// @function refresh_current_line_display(editor_inst)
function refresh_current_line_display(editor_inst) {
    with (editor_inst) {
        var full_text = get_full_line_text(id, cursor_y);
        var display_text = string_copy(full_text, horizontal_offset + 1, screen_cols);
        
        show_debug_message("SCREEN_EDITOR: Refreshing display - full_text='" + full_text + "', display='" + display_text + "', h_offset=" + string(horizontal_offset));
        
        // Clear the row
        screen_editor_clear_row(id, cursor_y);
        
        // Display the visible portion
        for (var i = 1; i <= string_length(display_text); i++) {
            var ch = string_char_at(display_text, i);
            screen_editor_set_char_at(id, i - 1, cursor_y, ord(ch));
        }
    }
}