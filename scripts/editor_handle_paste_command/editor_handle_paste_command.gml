function editor_handle_paste_command() {
    var raw_clip = clipboard_get_text();
    if (string_length(raw_clip) <= 0) {
        show_message("Clipboard is empty.");
        return;
    }

    var lines = string_split(raw_clip, "\n");

    for (var i = 0; i < array_length(lines); i++) {
        var line = string_trim(lines[i]);

        if (string_length(line) == 0) continue;

        // Expect format: line_number followed by space and code
        var space_pos = string_pos(" ", line);
        if (space_pos > 0) {
            var line_num_str = string_copy(line, 1, space_pos - 1);
            var code_str = string_copy(line, space_pos + 1, string_length(line) - space_pos);

            // ✅ Only proceed if line_num_str is a valid number
            if (string_digits(line_num_str) == line_num_str) {
                var line_num = real(line_num_str);

                if (line_num > 0 && string_length(code_str) > 0) {
                    ds_map_replace(global.program_lines, line_num, code_str);

                    if (!ds_list_find_index(global.line_numbers, line_num)) {
                        ds_list_add(global.line_numbers, line_num);
                        ds_list_sort(global.line_numbers, true);
                    }
                }
            }
        }
    }

    basic_show_message("Program pasted successfully.");
}
