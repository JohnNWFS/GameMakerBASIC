/// @function basic_array_get(name, idx)
/// @description 1-based, one-dimensional array read
function basic_array_get(_name, _idx) {
    var nm  = string_upper(string_trim(_name));
    if (!ds_map_exists(global.basic_arrays, nm)) return 0;
    var lst = global.basic_arrays[? nm];
    var idx = max(1, round(real(_idx)));         // force 1-based integer
    if (idx > ds_list_size(lst)) return 0;       // out-of-bounds → 0
    return ds_list_find_value(lst, idx - 1);     // DS-list is 0-based
}