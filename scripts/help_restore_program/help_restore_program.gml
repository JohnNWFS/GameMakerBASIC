/// help_restore_program()
function help_restore_program() {
    if (!variable_global_exists("help_snapshot_lines")) return;

    basic_program_clear();

    var key = ds_map_find_first(global.help_snapshot_lines);
    while (!is_undefined(key)) {
        var val = ds_map_find_value(global.help_snapshot_lines, key);
        ds_map_add(global.program_map, key, val);
        key = ds_map_find_next(global.help_snapshot_lines, key);
    }
    for (var i = 0; i < ds_list_size(global.help_snapshot_nums); i++) {
        ds_list_add(global.line_list, ds_list_find_value(global.help_snapshot_nums, i));
    }

    basic_program_rebuild_index_map();

    ds_map_destroy(global.help_snapshot_lines);
    ds_list_destroy(global.help_snapshot_nums);
    global.help_snapshot_lines = undefined;
    global.help_snapshot_nums  = undefined;
}