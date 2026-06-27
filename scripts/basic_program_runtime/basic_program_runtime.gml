/// Ensure canonical program storage exists (editor + runtime share these).
function basic_program_ensure() {
    if (!ds_exists(global.program_map, ds_type_map)) {
        global.program_map = ds_map_create();
    }
    if (!ds_exists(global.line_list, ds_type_list)) {
        global.line_list = ds_list_create();
    }
    if (!variable_global_exists("line_index_map") || !ds_exists(global.line_index_map, ds_type_map)) {
        global.line_index_map = ds_map_create();
    }
}

/// Rebuild O(1) line-number → list-index map from sorted line_list.
function basic_program_rebuild_index_map() {
    basic_program_ensure();
    ds_map_clear(global.line_index_map);
    for (var _j = 0; _j < ds_list_size(global.line_list); _j++) {
        var _ln = global.line_list[| _j];
        ds_map_set(global.line_index_map, string(real(_ln)), _j);
    }
}

/// Insert a line number into line_list keeping ascending order.
function basic_program_insert_line_ordered(_line_no) {
    basic_program_ensure();
    var _size = ds_list_size(global.line_list);
    for (var _i = 0; _i < _size; _i++) {
        if (global.line_list[| _i] > _line_no) {
            ds_list_insert(global.line_list, _i, _line_no);
            return;
        }
    }
    ds_list_add(global.line_list, _line_no);
}

/// Set or replace one program line. Rebuilds index map unless deferred.
function basic_program_set_line(_line_no, _code, _rebuild_index = true) {
    basic_program_ensure();
    ds_map_set(global.program_map, _line_no, _code);
    if (ds_list_find_index(global.line_list, _line_no) < 0) {
        basic_program_insert_line_ordered(_line_no);
    }
    if (_rebuild_index) {
        basic_program_rebuild_index_map();
    }
}

/// Delete one program line and rebuild the index map.
function basic_program_delete_line(_line_no) {
    basic_program_ensure();
    if (ds_map_exists(global.program_map, _line_no)) {
        ds_map_delete(global.program_map, _line_no);
    }
    var _pos = ds_list_find_index(global.line_list, _line_no);
    if (_pos >= 0) {
        ds_list_delete(global.line_list, _pos);
    }
    basic_program_rebuild_index_map();
}

/// Clear all program lines (NEW / LOAD preamble).
function basic_program_clear() {
    basic_program_ensure();
    ds_map_clear(global.program_map);
    ds_list_clear(global.line_list);
    ds_map_clear(global.line_index_map);
}

/// Prepare interpreter helpers before RUN (no copy — editor uses same storage).
function basic_program_sync_runtime() {
    basic_program_ensure();
    ds_list_sort(global.line_list, true);
    basic_program_rebuild_index_map();
    dbg_log(DBG_FLOW, "PROGRAM RUNTIME: ready " + string(ds_list_size(global.line_list)) + " lines");
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