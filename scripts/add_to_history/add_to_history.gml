// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
 function add_to_history(input_text) {
    if (input_text != "" && (ds_list_size(global.input_history) == 0 || 
        ds_list_find_value(global.input_history, ds_list_size(global.input_history) - 1) != input_text)) {
        ds_list_add(global.input_history, input_text);
        // Limit history size
        while (ds_list_size(global.input_history) > 50) {
            ds_list_delete(global.input_history, 0);
        }
	}
 }