/// @function basic_array_get(name, idx)
/// @description Retrieves a value from a 1D array stored in global.basic_arrays (0-based indexing)
/// @param name The name of the array (string)
/// @param idx  The index to access (0-based)
/// arrays v1 — 2025-08-08
/// 1D arrays backed by ds_list, 0-based, auto-grow, OOB reads return 0

function basic_array_get(_name, _idx) {
    var nm = string_upper(string_trim(_name));
    if (dbg_on(DBG_FLOW))  show_debug_message("ARRAY_GET: Accessing " + nm + "[" + string(_idx) + "]");

    // Must exist in the map
    if (!ds_map_exists(global.basic_arrays, nm)) {
        if (dbg_on(DBG_FLOW))  show_debug_message("ARRAY_GET ERROR: Array '" + nm + "' does not exist");
        return 0;
    }

    // Must be a valid ds_list handle
    var lst = global.basic_arrays[? nm];
    if (!ds_exists(lst, ds_type_list)) {
        if (dbg_on(DBG_FLOW))  show_debug_message("ARRAY_GET ERROR: '" + nm + "' is not a ds_list");
        return 0;
    }

    // Normalize index
    var idx = floor(real(_idx)); // use floor; indices are 0..N-1

    // Bounds check
    var n = ds_list_size(lst);
    if (idx < 0 || idx >= n) {
        if (dbg_on(DBG_FLOW))  show_debug_message("ARRAY_GET ERROR: Index " + string(idx) + " out of bounds for " + nm + " (size=" + string(n) + ")");
        return 0;
    }

    // Fetch
    var value = ds_list_find_value(lst, idx);
    // OPTIONAL: verbose log (comment out if noisy)
    // show_debug_message("ARRAY_GET: " + nm + "[" + string(idx) + "] = " + string(value));
    return value;
}
