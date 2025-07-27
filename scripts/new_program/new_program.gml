// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
 function new_program() {
    // Save state for undo before clearing
    if (ds_list_size(global.line_numbers) > 0) {
        save_undo_state();
    }
    
    ds_map_clear(global.program_lines);
    ds_list_clear(global.line_numbers);
    current_filename = "";
    display_start_line = 0;
    update_display();
    basic_show_message("NEW PROGRAM");
 }