/// @function screen_editor_display_line(editor_inst, line_text, screen_row)
function screen_editor_display_line(editor_inst, line_text, screen_row) {
    with (editor_inst) {
        // Clear the row first
        for (var clear_x = 0; clear_x < screen_cols; clear_x++) {
            screen_editor_set_char_at(id, clear_x, screen_row, ord(" "));
        }
        
        // Apply horizontal offset only to cursor line
        var display_text = line_text;
        if (screen_row == cursor_y && horizontal_offset > 0) {
            display_text = string_copy(line_text, horizontal_offset + 1, screen_cols);
        }
        
        // Display the text
        var text_len = min(string_length(display_text), screen_cols);
        for (var j = 1; j <= text_len; j++) {
            var ch = string_char_at(display_text, j);
            screen_editor_set_char_at(id, j - 1, screen_row, ord(ch));
        }
        
        show_debug_message("SCREEN_EDITOR: Displayed line " + string(screen_row) + 
                          (screen_row == cursor_y ? " (with offset " + string(horizontal_offset) + ")" : " (no offset)"));
    }
}