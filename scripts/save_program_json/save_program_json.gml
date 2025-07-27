// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
 function save_program_json(filename) {
    try {
        var save_data = ds_map_create();
        ds_map_copy(save_data, global.program_lines);
        
        var json_string = json_encode(save_data);
        var file_path = working_directory + filename + ".json";
        var file = file_text_open_write(file_path);
        file_text_write_string(file, json_string);
        file_text_close(file);
        
        ds_map_destroy(save_data);
        basic_show_message("SAVED: " + filename + " (JSON)");
    } catch (e) {
        show_error_message("JSON SAVE ERROR");
    }
 }