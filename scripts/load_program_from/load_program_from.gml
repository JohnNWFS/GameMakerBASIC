function load_program_from(filename) {
    var file_path = working_directory + filename + ".bas";
    if (!file_exists(file_path)) {
        basic_show_error_message("FILE NOT FOUND: " + filename);
        return;
    }

    // clear current program
    new_program(); // use your existing clear function

    var file = file_text_open_read(file_path);
    if (file == -1) {
        basic_show_error_message("COULD NOT OPEN FILE: " + filename);
        return;
    }

    while (!file_text_eof(file)) {
        var line = file_text_read_string(file);
        file_text_readln(file);

        line = string_trim(line);
        if (line != "") {
            var space_pos = string_pos(" ", line);
            if (space_pos > 0) {
                var line_num_str = string_copy(line, 1, space_pos - 1);
                var code_content = string_copy(line, space_pos + 1, string_length(line));
                var line_num = real(line_num_str);

                if (is_line_number(line_num_str)) {
                    ds_map_set(global.program_lines, line_num, code_content);
                    insert_line_number_ordered(line_num);
                }
            }
        }
    }
    file_text_close(file);
    current_filename = filename;
    basic_show_message("LOADED: " + filename);
    update_display();
}
