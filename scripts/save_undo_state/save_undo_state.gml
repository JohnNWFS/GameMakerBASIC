function save_undo_state() {
    if (!ds_exists(global.program_map, ds_type_map) || !ds_exists(global.line_list, ds_type_list)) return;

    if (!variable_global_exists("undo_stack") || !ds_exists(global.undo_stack, ds_type_list)) {
        global.undo_stack = ds_list_create();
    }

    var snapshot = ds_map_create();
    var lines_copy = ds_map_create();
    var nums_copy = ds_list_create();

    ds_map_copy(lines_copy, global.program_map);
    ds_list_copy(nums_copy, global.line_list);

    snapshot[? "program_map"] = lines_copy;
    snapshot[? "line_list"] = nums_copy;

    ds_list_add(global.undo_stack, snapshot);

    var max_undo = 20;
    while (ds_list_size(global.undo_stack) > max_undo) {
        var old_snapshot = ds_list_find_value(global.undo_stack, 0);
        if (ds_exists(old_snapshot[? "program_map"], ds_type_map)) ds_map_destroy(old_snapshot[? "program_map"]);
        if (ds_exists(old_snapshot[? "line_list"], ds_type_list)) ds_list_destroy(old_snapshot[? "line_list"]);
        ds_map_destroy(old_snapshot);
        ds_list_delete(global.undo_stack, 0);
    }

    dbg_log(DBG_FLOW, "UNDO: saved snapshot, depth=" + string(ds_list_size(global.undo_stack)));
}

function undo_last_change() {
    if (!variable_global_exists("undo_stack") || !ds_exists(global.undo_stack, ds_type_list) || ds_list_size(global.undo_stack) <= 0) {
        basic_show_message("NOTHING TO UNDO");
        return;
    }

    var idx = ds_list_size(global.undo_stack) - 1;
    var snapshot = ds_list_find_value(global.undo_stack, idx);
    ds_list_delete(global.undo_stack, idx);

    basic_program_ensure();
    ds_map_clear(global.program_map);
    ds_list_clear(global.line_list);

    var lines_copy = snapshot[? "program_map"];
    var nums_copy = snapshot[? "line_list"];

    if (ds_exists(lines_copy, ds_type_map)) ds_map_copy(global.program_map, lines_copy);
    if (ds_exists(nums_copy, ds_type_list)) ds_list_copy(global.line_list, nums_copy);

    if (ds_exists(lines_copy, ds_type_map)) ds_map_destroy(lines_copy);
    if (ds_exists(nums_copy, ds_type_list)) ds_list_destroy(nums_copy);
    ds_map_destroy(snapshot);

    basic_program_rebuild_index_map();
    update_display();
    basic_show_message("UNDO");
    dbg_log(DBG_FLOW, "UNDO: restored snapshot, depth=" + string(ds_list_size(global.undo_stack)));
}