// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function save_program() {
    if (current_filename == "") {
        show_error_message("NO FILENAME");
        return;
    }
    save_program_as(current_filename);
 }