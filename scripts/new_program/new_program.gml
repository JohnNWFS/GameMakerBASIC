// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
 function new_program() {
    // Save state for undo before clearing
    if (ds_list_size(global.line_list) > 0) {
        save_undo_state();
    }
    
    basic_program_clear();
    bas_sprite_clear_all();
    current_filename = "";
    list_range_active = false;
    display_start_line = 0;
    global.stop_breakpoint_active = false;
    update_display();
    basic_show_message("NEW PROGRAM");
 }
