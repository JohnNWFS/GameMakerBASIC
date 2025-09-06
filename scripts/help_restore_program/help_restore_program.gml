/// help_restore_program()
function help_restore_program() {
    if (!variable_global_exists("help_snapshot_lines")) return;

    // wipe current
    if (ds_exists(global.program_lines, ds_type_map)) ds_map_clear(global.program_lines);
    if (ds_exists(global.line_numbers, ds_type_list)) ds_list_clear(global.line_numbers);

    // restore
    var key = ds_map_find_first(global.help_snapshot_lines);
    while (!is_undefined(key)) {
        var val = ds_map_find_value(global.help_snapshot_lines, key);
        ds_map_add(global.program_lines, key, val);
        key = ds_map_find_next(global.help_snapshot_lines, key);
    }
    for (var i = 0; i < ds_list_size(global.help_snapshot_nums); i++) {
        ds_list_add(global.line_numbers, ds_list_find_value(global.help_snapshot_nums, i));
    }

    // clean snapshot
    ds_map_destroy(global.help_snapshot_lines);
    ds_list_destroy(global.help_snapshot_nums);
    global.help_snapshot_lines = undefined;
    global.help_snapshot_nums  = undefined;
}

