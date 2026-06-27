/// Sync editor program storage into the canonical runtime view used by RUN.
/// Builds sorted line_list, program_map copy, and O(1) line_index_map.
function basic_program_sync_runtime() {
    if (!ds_exists(global.program_lines, ds_type_map)) {
        global.program_lines = ds_map_create();
    }
    if (!ds_exists(global.line_numbers, ds_type_list)) {
        global.line_numbers = ds_list_create();
    }

    if (!ds_exists(global.program_map, ds_type_map)) {
        global.program_map = ds_map_create();
    } else {
        ds_map_clear(global.program_map);
    }
    ds_map_copy(global.program_map, global.program_lines);

    if (!ds_exists(global.line_list, ds_type_list)) {
        global.line_list = ds_list_create();
    } else {
        ds_list_clear(global.line_list);
    }
    for (var _i = 0; _i < ds_list_size(global.line_numbers); _i++) {
        ds_list_add(global.line_list, global.line_numbers[| _i]);
    }
    ds_list_sort(global.line_list, true);

    if (!variable_global_exists("line_index_map") || !ds_exists(global.line_index_map, ds_type_map)) {
        global.line_index_map = ds_map_create();
    } else {
        ds_map_clear(global.line_index_map);
    }
    for (var _j = 0; _j < ds_list_size(global.line_list); _j++) {
        var _ln = global.line_list[| _j];
        ds_map_set(global.line_index_map, string(real(_ln)), _j);
    }

    dbg_log(DBG_FLOW, "PROGRAM RUNTIME: synced " + string(ds_list_size(global.line_list)) + " lines");
}

/// Return sorted list index for a BASIC line number, or -1 if not found.
function basic_line_index_for(_line_no) {
    if (!variable_global_exists("line_index_map") || !ds_exists(global.line_index_map, ds_type_map)) {
        return -1;
    }
    var _key = string(real(_line_no));
    if (!ds_map_exists(global.line_index_map, _key)) {
        return -1;
    }
    return ds_map_find_value(global.line_index_map, _key);
}

/// Line number at sorted list index, or -1 when out of range.
function basic_line_number_at(_index) {
    if (!ds_exists(global.line_list, ds_type_list)) return -1;
    if (_index < 0 || _index >= ds_list_size(global.line_list)) return -1;
    return global.line_list[| _index];
}

/// Program source for a line number (empty string when missing).
function basic_program_code_for(_line_no) {
    if (!ds_exists(global.program_map, ds_type_map)) return "";
    var _code = ds_map_find_value(global.program_map, _line_no);
    if (is_undefined(_code)) return "";
    return string(_code);
}