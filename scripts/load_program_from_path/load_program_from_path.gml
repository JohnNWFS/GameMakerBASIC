// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function load_program_from_path(file_path, filename) {
    if (!file_exists(file_path)) {
        show_error_message("DRAG FILE NOT FOUND");
        return;
    }
    
    try {
        save_undo_state();
        new_program_without_undo();
        
        var file = file_text_open_read(file_path);
        while (!file_text_eof(file)) {
            var line = file_text_read_string(file);
            file_text_readln(file);
            
            if (string_trim(line) != "") {
                var space_pos = string_pos(" ", line);
                if (space_pos > 0) {
                    var line_num_str = string_copy(line, 1, space_pos - 1);
                    var code_content = string_copy(line, space_pos + 1, string_length(line));
                    
                    if (is_line_number(line_num_str)) {
                        var line_num = real(line_num_str);
                        if (!is_valid_line_number(line_num)) continue;
                        basic_program_set_line(line_num, code_content, false);
                    }
                }
            }
        }
        file_text_close(file);
        basic_program_rebuild_index_map();
        current_filename = filename;
        basic_show_message("LOADED via DRAG: " + filename);
        update_display();
    } catch (e) {
        show_error_message("DRAG LOAD ERROR");
    }
 }
