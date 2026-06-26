/// @function basic_array_get(name, idx)
/// @description Retrieves a value from a 1D or multi-D array stored in global.basic_arrays.
/// idx may be a single value (1D) or a comma-separated string of indices (multi-D).
function basic_array_get(_name, _idx) {
    var nm = string_upper(string_trim(_name));
    dbg_log(DBG_FLOW, "ARRAY_GET: Accessing " + nm + "[" + string(_idx) + "]");

    if (!ds_map_exists(global.basic_arrays, nm)) {
        dbg_log(DBG_FLOW, "ARRAY_GET ERROR: Array '" + nm + "' does not exist");
        return 0;
    }
    var arr = global.basic_arrays[? nm];
    if (!is_array(arr)) {
        dbg_log(DBG_FLOW, "ARRAY_GET ERROR: '" + nm + "' is not a native array");
        return 0;
    }

    var _base = variable_global_exists("option_base") ? global.option_base : 1;
    var flat_idx;

    // Check for multi-dimensional index (comma-separated string)
    var idx_str = string(_idx);
    if (string_pos(",", idx_str) > 0) {
        // Multi-dim: compute row-major flat index
        var has_dims = variable_global_exists("basic_array_dims")
                    && ds_exists(global.basic_array_dims, ds_type_map)
                    && ds_map_exists(global.basic_array_dims, nm);
        if (!has_dims) {
            dbg_log(DBG_FLOW, "ARRAY_GET ERROR: No dim info for multi-dim array " + nm);
            return 0;
        }
        var dims = global.basic_array_dims[? nm];
        var parts = basic_split_top_commas(idx_str);
        if (array_length(parts) != array_length(dims)) {
            dbg_log(DBG_FLOW, "ARRAY_GET ERROR: Wrong number of indices for " + nm);
            return 0;
        }
        flat_idx = 0;
        var stride = 1;
        // Row-major: rightmost dimension varies fastest
        for (var di = array_length(dims) - 1; di >= 0; di--) {
            var iv = floor(real(string_trim(parts[di]))) - _base;
            if (iv < 0 || iv >= dims[di]) {
                dbg_log(DBG_FLOW, "ARRAY_GET ERROR: Index out of bounds on dim " + string(di) + " for " + nm);
                return 0;
            }
            flat_idx += iv * stride;
            stride *= dims[di];
        }
    } else {
        // 1D
        var idx_basic = max(_base, floor(real(_idx)));
        flat_idx = idx_basic - _base;
    }

    var n = array_length(arr);
    if (flat_idx < 0 || flat_idx >= n) {
        dbg_log(DBG_FLOW, "ARRAY_GET ERROR: flat_idx " + string(flat_idx) + " out of bounds for " + nm + " (size=" + string(n) + ")");
        return 0;
    }
    return arr[flat_idx];
}