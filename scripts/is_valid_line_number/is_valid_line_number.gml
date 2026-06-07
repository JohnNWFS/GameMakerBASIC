// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
 function is_valid_line_number(line_num) {
    if (!variable_global_exists("config") || !ds_exists(global.config, ds_type_map)) {
        return (line_num >= 1 && line_num <= 65535);
    }
    return (line_num >= 1 && line_num <= global.config[? "max_line_number"]);
 }
