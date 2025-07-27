/// @desc Saves the current program to a .bas file
/// @param filename The filename to save as (without extension)
function save_program_as(filename) {
    // Trim spaces
    filename = string_trim(filename);

    // Remove surrounding quotes if present
    if (string_length(filename) >= 2) {
        var first = string_char_at(filename, 1);
        var last  = string_char_at(filename, string_length(filename));
        if ((first == "\"" || first == "'") && first == last) {
            filename = string_copy(filename, 2, string_length(filename) - 2);
        }
    }

    var file_path = working_directory + filename + ".bas";
    var file = file_text_open_write(file_path);
    if (file == -1) {
        show_error_message("COULD NOT OPEN FILE: " + filename);
        return;
    }

    var count = ds_list_size(global.line_numbers);
    for (var i = 0; i < count; i++) {
        var line_num = ds_list_find_value(global.line_numbers, i);
        var code     = ds_map_find_value(global.program_lines, line_num);
        file_text_write_string(file, string(line_num) + " " + code);
        file_text_writeln(file);
    }

    file_text_close(file);
    current_filename = filename;
    basic_show_message("SAVED: " + filename + " (working_directory)");
}
