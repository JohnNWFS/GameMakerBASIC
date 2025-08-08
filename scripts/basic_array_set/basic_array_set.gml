/// @function basic_array_set(name, idx, value)
/// @description 1-based, one-dimensional array write (auto-grows)
function basic_array_set(_name, _idx, _val) {
    var nm  = string_upper(string_trim(_name));
    if (!ds_map_exists(global.basic_arrays, nm)) {
        global.basic_arrays[? nm] = ds_list_create();
    }
    var lst = global.basic_arrays[? nm];
    var idx = max(1, round(real(_idx)));         // force 1-based integer

    // grow the list with zeroes until we can set at (idx-1)
    while (ds_list_size(lst) < idx) {
        ds_list_add(lst, 0);
    }

    // replace the existing slot
    ds_list_replace(lst, idx - 1, _val);
}