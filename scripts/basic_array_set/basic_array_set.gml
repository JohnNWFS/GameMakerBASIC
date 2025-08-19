/// @function basic_array_set(name, idx, value)
/// @description Sets a value in a 1D array stored in global.basic_arrays (0-based indexing, auto-grows)
/// @param name  The name of the array (string)
/// @param idx   The index to set (0-based)
/// @param value The value to set
/// arrays v1 — 2025-08-08
/// 1D arrays backed by ds_list, 0-based, auto-grow, OOB reads return 0

function basic_array_set(_name, _idx, _val) {
    var nm = string_upper(string_trim(_name));
    if (dbg_on(DBG_FLOW))  show_debug_message("ARRAY_SET: Setting " + nm + "[" + string(_idx) + "] = " + string(_val));

    // Ensure the map entry exists and is a ds_list
    if (!ds_map_exists(global.basic_arrays, nm)) {
        if (dbg_on(DBG_FLOW))  show_debug_message("ARRAY_SET: Creating new ds_list for " + nm);
        global.basic_arrays[? nm] = ds_list_create();
    }

    var lst = global.basic_arrays[? nm];
    if (!ds_exists(lst, ds_type_list)) {
        if (dbg_on(DBG_FLOW))  show_debug_message("ARRAY_SET: Replacing non-list backing store for " + nm);
        lst = ds_list_create();
        global.basic_arrays[? nm] = lst;
    }

    // Normalize index
    var idx = floor(real(_idx)); // integer index (use floor to avoid +1 surprises near boundaries)

    // OPTIONAL: hard-stop on negative indexes (comment this out if you prefer silent ignore)
    if (idx < 0) {
        if (dbg_on(DBG_FLOW))  show_debug_message("ARRAY_SET ERROR: Negative index " + string(idx) + " for array " + nm);
        return;
    }

    // Grow to fit (fills with 0)
    while (ds_list_size(lst) <= idx) {
        ds_list_add(lst, 0);
        // OPTIONAL: verbose growth log (disable if noisy)
        // show_debug_message("ARRAY_SET: Growing " + nm + " to size " + string(ds_list_size(lst)));
    }

    // Assign
    ds_list_replace(lst, idx, _val);
    // OPTIONAL: confirmation log (disable if noisy)
    // show_debug_message("ARRAY_SET: Set " + nm + "[" + string(idx) + "] = " + string(_val));
}
