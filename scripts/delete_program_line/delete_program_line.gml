// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function delete_program_line(line_num) {
    ds_map_delete(global.program_lines, line_num);
    var pos = ds_list_find_index(global.line_numbers, line_num);
    if (pos != -1) {
        ds_list_delete(global.line_numbers, pos);
    }
 }