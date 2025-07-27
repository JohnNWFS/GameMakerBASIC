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
					                    var line_num = real(line_num_str);
                    var code_content = string_copy(line, space_pos + 1, string_length(line));
                    
                    if (is_line_number(line_num_str) && is_valid_line_number(line_num)) {
                        ds_map_set(global.program_lines, line_num, code_content);
                        insert_line_number_ordered(line_num);
                    }
                }
            }
        }
        file_text_close(file);
        current_filename = filename;
        basic_show_message("LOADED via DRAG: " + filename);
        update_display();
    } catch (e) {
        show_error_message("DRAG LOAD ERROR");
    }
 }