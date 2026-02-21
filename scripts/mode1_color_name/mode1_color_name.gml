/// @function mode1_color_name(col)
/// @desc Return a name for a color (lookup in global.colors) or numeric fallback
function mode1_color_name(col) {
    if (!variable_global_exists("colors") || !ds_map_exists(global.colors, "")) {
        return string(col);
    }
    // iterate map keys to find matching value (small map — ok)
    var keys = ds_map_keys(global.colors);
    for (var i = 0; i < array_length(keys); i++) {
        var k = keys[i];
        var v = global.colors[? k];
        if (v == col) return k;
    }
    return string(col);
}
