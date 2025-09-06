// FILE: scripts/screen_editor_commit_row/screen_editor_commit_row.gml
/// @function screen_editor_commit_row(editor_inst, _row)
function screen_editor_commit_row(editor_inst, _row) {
    with (editor_inst) {
        var line_text = string_trim(screen_editor_get_row_text(id, _row));
       if (dbg_on(DBG_FLOW)) show_debug_message("SCREEN_EDITOR: Committing row " + string(_row) + ": '" + line_text + "'");
        
        if (line_text == "") return;
        
        // Check for EXIT command
        if (string_upper(line_text) == "EXIT") {
            screen_editor_exit(id);
            return;
        }
        
        // Parse line number and code
        var space_pos = string_pos(" ", line_text);
        var line_num_str = "";
        var code = "";
        
        if (space_pos > 0) {
            line_num_str = string_copy(line_text, 1, space_pos - 1);
            code = string_trim(string_copy(line_text, space_pos + 1, string_length(line_text)));
        } else {
            line_num_str = line_text;
        }
        
        // Check if it's a valid line number
        var line_num = real(line_num_str);
        if (line_num_str != "" && is_real(line_num) && line_num > 0) {
            if (code == "") {
                // Delete line
                delete_program_line(line_num);
               if (dbg_on(DBG_FLOW)) show_debug_message("SCREEN_EDITOR: Deleted line " + string(line_num));
            } else {
                // Add/update line
                add_or_update_program_line(line_num, code);
               if (dbg_on(DBG_FLOW)) show_debug_message("SCREEN_EDITOR: Added/updated line " + string(line_num) + ": " + code);
            }
        }
    }
}