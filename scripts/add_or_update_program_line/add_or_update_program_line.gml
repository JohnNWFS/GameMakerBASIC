// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function add_or_update_program_line(line_num, code) {
    ds_map_set(global.program_lines, line_num, code);
    
    // Update ordered line numbers list
    var pos = ds_list_find_index(global.line_numbers, line_num);
    if (pos == -1) {
        // Insert in correct order
        insert_line_number_ordered(line_num);
    }
 }