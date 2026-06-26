/// @function basic_array_init(name, size)
/// @description Initializes a 1D array in global.basic_arrays
/// @param name The name of the array (string)
/// @param size The size of the array (number of elements)
function basic_array_init(_name, _size) {
    var nm = string_upper(string_trim(_name));
    dbg_log(DBG_FLOW, "ARRAY_INIT: Initializing " + nm + " with size " + string(_size));

    if (ds_map_exists(global.basic_arrays, nm)) {
        dbg_log(DBG_FLOW, "ARRAY_INIT WARNING: Array '" + nm + "' already exists, replacing");
        basic_array_release_storage(global.basic_arrays[? nm]);
        ds_map_delete(global.basic_arrays, nm);
    }

    var sz = floor(real(_size));
    if (sz < 0) {
        dbg_log(DBG_FLOW, "ARRAY_INIT ERROR: Invalid size " + string(sz) + " for " + nm);
        return;
    }

    global.basic_arrays[? nm] = array_create(sz, 0);
    dbg_log(DBG_FLOW, "ARRAY_INIT: Created " + nm + " with size " + string(array_length(global.basic_arrays[? nm])));
}