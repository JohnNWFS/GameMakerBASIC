/// help_snapshot_program()
function help_snapshot_program() {
    // destroy any old snapshot
    if (variable_global_exists("help_snapshot_lines") && ds_exists(global.help_snapshot_lines, ds_type_map)) {
        ds_map_destroy(global.help_snapshot_lines);
    }
    if (variable_global_exists("help_snapshot_nums") && ds_exists(global.help_snapshot_nums, ds_type_list)) {
        ds_list_destroy(global.help_snapshot_nums);
    }

    // deep copy maps/lists you mutate during load/run
    global.help_snapshot_lines = ds_map_create();
    var key = ds_map_find_first(global.program_lines);
    while (!is_undefined(key)) {
        var val = ds_map_find_value(global.program_lines, key);
        ds_map_add(global.help_snapshot_lines, key, val);
        key = ds_map_find_next(global.program_lines, key);
    }

    global.help_snapshot_nums = ds_list_create();
    for (var i = 0; i < ds_list_size(global.line_numbers); i++) {
        ds_list_add(global.help_snapshot_nums, ds_list_find_value(global.line_numbers, i));
    }
}

