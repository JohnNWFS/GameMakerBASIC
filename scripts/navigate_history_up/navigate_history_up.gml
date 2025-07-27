// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function navigate_history_up() {
	
	if (global.justreturned == 1) return; // 🛑 Block history on return
	
    if (ds_list_size(global.input_history) > 0) {
        if (global.history_index == -1) {
            global.history_index = ds_list_size(global.input_history) - 1;
        } else {
            global.history_index = max(0, global.history_index - 1);
        }
        current_input = ds_list_find_value(global.input_history, global.history_index);
        cursor_pos = string_length(current_input);
    }
 }