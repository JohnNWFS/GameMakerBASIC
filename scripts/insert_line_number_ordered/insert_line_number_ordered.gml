// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
 function insert_line_number_ordered(new_line_num) {
    var size = ds_list_size(global.line_numbers);
    var inserted = false;
    
    for (var i = 0; i < size; i++) {
        if (ds_list_find_value(global.line_numbers, i) > new_line_num) {
            ds_list_insert(global.line_numbers, i, new_line_num);
            inserted = true;
            break;
      }
    }
    
    if (!inserted) {
        ds_list_add(global.line_numbers, new_line_num);
    }
 }