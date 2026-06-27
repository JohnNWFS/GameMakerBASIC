/// @function mode1_color_name(col)
/// @desc Return a name for a color (lookup in global.colors) or numeric fallback
function mode1_color_name(col) {
    basic_colors_ensure();
    var keys = variable_struct_get_names(global.colors);
    for (var i = 0; i < array_length(keys); i++) {
        var k = keys[i];
        if (global.colors[$ k] == col) return k;
    }
    return string(col);
}
