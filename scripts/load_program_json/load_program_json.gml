// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function load_program_json(filename) {
    var file_path = working_directory + filename + ".json";
    
    if (!file_exists(file_path)) {
        show_error_message("JSON FILE NOT FOUND");
        return;
    }
    
    try {
        var file = file_text_open_read(file_path);
        var json_string = file_text_read_string(file);
        file_text_close(file);
        
        var loaded_map = json_decode(json_string);
        
        new_program();
        ds_map_copy(global.program_lines, loaded_map);
        
        // Rebuild line numbers list
        var key = ds_map_find_first(global.program_lines);
        while (!is_undefined(key)) {
            insert_line_number_ordered(real(key));
            key = ds_map_find_next(global.program_lines, key);
        }
        
        ds_map_destroy(loaded_map);
        basic_show_message("LOADED JSON: " + filename);
        update_display();
    } catch (e) {
        show_error_message("JSON LOAD ERROR");
    }
 }