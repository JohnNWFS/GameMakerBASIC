function load_program_from(filename)
{
    // Normalize input
    filename = string_trim(filename);
    if (string_length(filename) == 0) {
        basic_show_error_message("NO FILENAME PROVIDED");
        return;
    }
    // Strip quotes if present
    if (string_char_at(filename, 1) == "\"" && string_char_at(filename, string_length(filename)) == "\"") {
        filename = string_copy(filename, 2, string_length(filename) - 2);
    }
    // Add .bas if missing
    var ext = string_lower(string_copy(filename, string_length(filename) - 3, 4));
    if (ext != ".bas") {
        filename += ".bas";
    }

    // Build full path from the same directory used by SAVE
    var file_path = get_save_directory() + filename;

    if (!file_exists(file_path)) {
        basic_show_error_message("FILE NOT FOUND: " + filename);
        return;
    }

    // Clear current program (your function should reset global.program_lines etc.)
    new_program();

    var file = file_text_open_read(file_path);
    if (file == -1) {
        basic_show_error_message("COULD NOT OPEN FILE: " + filename);
        return;
    }

    // Read file line-by-line
    while (!file_text_eof(file)) {
        var line = file_text_read_string(file);
        file_text_readln(file); // consume newline
        line = string_trim(line);

        if (string_length(line) == 0) {
            continue; // skip empties
        }

        // Split on first space to detect a numeric line number
        var sp = string_pos(" ", line);
        if (sp <= 0) {
            // No space → treat as free text; assign a synthetic line number by asking your helper,
            // or just skip if you strictly require numeric lines. Here we skip to keep behavior predictable.
            continue;
        }

        var line_num_str = string_copy(line, 1, sp - 1);
        var code_content = string_copy(line, sp + 1, string_length(line) - sp);
        var line_num = real(line_num_str);

        // Use your existing validation helpers
        if (is_line_number(line_num_str) && is_valid_line_number(line_num)) {
            // Store into your canonical container and order list
            ds_map_set(global.program_lines, line_num, code_content);
            insert_line_number_ordered(line_num);
        }
    }

    file_text_close(file);
    current_filename = filename;
    basic_show_message("LOADED: " + filename);
    update_display();
}
