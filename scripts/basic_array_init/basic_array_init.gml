/// @function basic_array_init(name, size)
/// @description Initializes a 1D array as a ds_list in global.basic_arrays
/// @param name The name of the array (string)
/// @param size The size of the array (number of elements)
/// arrays v1 — 2025-08-08
/// 1D arrays backed by ds_list, 0-based, auto-grow, OOB reads return 0

function basic_array_init(_name, _size) {
    var nm = string_upper(string_trim(_name));
    dbg_log(DBG_FLOW, "ARRAY_INIT: Initializing " + nm + " with size " + string(_size));

    // If the array already exists, destroy its backing list
    if (ds_map_exists(global.basic_arrays, nm)) {
        dbg_log(DBG_FLOW, "ARRAY_INIT WARNING: Array '" + nm + "' already exists, destroying");
        var old_lst = global.basic_arrays[? nm];
        if (ds_exists(old_lst, ds_type_list)) {
            ds_list_destroy(old_lst);
        }
        ds_map_delete(global.basic_arrays, nm);
    }

    // Normalize and validate size
    var sz = floor(real(_size));
    if (sz < 0) {
        dbg_log(DBG_FLOW, "ARRAY_INIT ERROR: Invalid size " + string(sz) + " for " + nm);
        return;
    }

    // Create and fill
    var lst = ds_list_create();
    repeat (sz) {
        ds_list_add(lst, 0);
    }
    global.basic_arrays[? nm] = lst;

    dbg_log(DBG_FLOW, "ARRAY_INIT: Created " + nm + " with size " + string(ds_list_size(lst)));
}
