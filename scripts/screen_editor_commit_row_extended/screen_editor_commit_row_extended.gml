// ===============================================
// FILE: scripts/screen_editor_commit_row_extended/screen_editor_commit_row_extended.gml
// NEW: Modified commit function that accepts full line text
// ===============================================

/// @function screen_editor_commit_row_extended(editor_inst, _row, line_text)
function screen_editor_commit_row_extended(editor_inst, _row, line_text) {
    with (editor_inst) {
        var trimmed_text = string_trim(line_text);
        show_debug_message("SCREEN_EDITOR: Committing row " + string(_row) + ": '" + trimmed_text + "'");
        
        if (trimmed_text == "") return;
        
        if (string_upper(trimmed_text) == "EXIT") {
            screen_editor_exit(id);
            return;
        }
        
        var space_pos = string_pos(" ", trimmed_text);
        var line_num_str = "";
        var code = "";
        
        if (space_pos > 0) {
            line_num_str = string_copy(trimmed_text, 1, space_pos - 1);
            code = string_trim(string_copy(trimmed_text, space_pos + 1, string_length(trimmed_text)));
        } else {
            line_num_str = trimmed_text;
        }
        
        var line_num = real(line_num_str);
        if (line_num_str != "" && is_real(line_num) && line_num > 0) {
            if (code == "") {
                delete_program_line(line_num);
                show_debug_message("SCREEN_EDITOR: Deleted line " + string(line_num));
            } else {
                add_or_update_program_line(line_num, code);
                show_debug_message("SCREEN_EDITOR: Added/updated line " + string(line_num) + ": " + code);
            }
        }
    }
}