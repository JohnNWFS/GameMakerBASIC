/// help_snapshot_program()
function help_snapshot_program() {
    if (variable_global_exists("help_snapshot_lines") && ds_exists(global.help_snapshot_lines, ds_type_map)) {
        ds_map_destroy(global.help_snapshot_lines);
    }
    if (variable_global_exists("help_snapshot_nums") && ds_exists(global.help_snapshot_nums, ds_type_list)) {
        ds_list_destroy(global.help_snapshot_nums);
    }

    global.help_snapshot_lines = ds_map_create();
    var key = ds_map_find_first(global.program_map);
    while (!is_undefined(key)) {
        var val = ds_map_find_value(global.program_map, key);
        ds_map_add(global.help_snapshot_lines, key, val);
        key = ds_map_find_next(global.program_map, key);
    }

    global.help_snapshot_nums = ds_list_create();
    for (var i = 0; i < ds_list_size(global.line_list); i++) {
        ds_list_add(global.help_snapshot_nums, ds_list_find_value(global.line_list, i));
    }
}