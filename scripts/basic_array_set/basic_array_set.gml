/// @function basic_array_set(name, idx, value)
/// @description Sets a value in a 1D array stored in global.basic_arrays (0-based indexing, auto-grows)
/// @param name  The name of the array (string)
/// @param idx   The index to set (0-based)
/// @param value The value to set
function basic_array_set(_name, _idx, _val) {
    var nm = string_upper(string_trim(_name));
    dbg_log(DBG_FLOW, "ARRAY_SET: Setting " + nm + "[" + string(_idx) + "] = " + string(_val));

    if (!ds_map_exists(global.basic_arrays, nm)) {
        dbg_log(DBG_FLOW, "ARRAY_SET: Creating new array for " + nm);
        global.basic_arrays[? nm] = [];
    }

    var arr = global.basic_arrays[? nm];
    if (!is_array(arr)) {
        dbg_log(DBG_FLOW, "ARRAY_SET: Replacing non-array backing store for " + nm);
        arr = [];
        global.basic_arrays[? nm] = arr;
    }

    var idx = floor(real(_idx));
    if (idx < 0) {
        dbg_log(DBG_FLOW, "ARRAY_SET ERROR: Negative index " + string(idx) + " for array " + nm);
        return;
    }

    var _len = array_length(arr);
    while (_len <= idx) {
        arr = array_resize(arr, _len + 1);
        arr[_len] = 0;
        _len++;
    }
    global.basic_arrays[? nm] = arr;
    arr[idx] = _val;
}