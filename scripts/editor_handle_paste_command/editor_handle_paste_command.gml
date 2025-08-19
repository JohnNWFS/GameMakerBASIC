/// @function editor_handle_paste_command
// === BEGIN: editor_handle_paste_command ===
function editor_handle_paste_command() {
    var raw_clip = clipboard_get_text();
    if (string_length(raw_clip) <= 0) {
        show_message("Clipboard is empty.");
        return;
    }

    var lines = string_split(raw_clip, "\n");
    if (dbg_on(DBG_FLOW)) show_debug_message("PASTE: captured " + string(array_length(lines)) + " raw lines");

    for (var i = 0; i < array_length(lines); i++) {
        var line = string_trim(lines[i]);
        if (string_length(line) == 0) continue;

        // Expect: <number><space><code>
        var space_pos = string_pos(" ", line);
        if (space_pos > 0) {
            var line_num_str = string_copy(line, 1, space_pos - 1);
            var code_str     = string_copy(line, space_pos + 1, string_length(line) - space_pos);

            // Windows CRLF: trim trailing '\r' if present
            if (string_length(code_str) > 0 && string_char_at(code_str, string_length(code_str)) == chr(13)) {
                code_str = string_copy(code_str, 1, string_length(code_str) - 1);
            }

            if (string_digits(line_num_str) == line_num_str) {
                var line_num = real(line_num_str);

                if (line_num > 0 && string_length(code_str) > 0) {
                    // INSERT or REPLACE program text
                    ds_map_set(global.program_lines, line_num, code_str);
                    if (dbg_on(DBG_FLOW)) show_debug_message("PASTE: set " + string(line_num) + " → '" + code_str + "'");

                    // Maintain ordered line number list — add only if not present
                    var idx = ds_list_find_index(global.line_numbers, line_num);
                    if (idx == -1) {
                        ds_list_add(global.line_numbers, line_num);
                        ds_list_sort(global.line_numbers, true);
                        if (dbg_on(DBG_FLOW)) show_debug_message("PASTE: added line number " + string(line_num));
                    } else if (dbg_on(DBG_FLOW)) {
                        if (dbg_on(DBG_FLOW)) show_debug_message("PASTE: updated existing line number " + string(line_num) + " (idx=" + string(idx) + ")");
                    }
                }
            }
        }
    }

    basic_show_message("Program pasted successfully.");
}
// === END: editor_handle_paste_command ===
