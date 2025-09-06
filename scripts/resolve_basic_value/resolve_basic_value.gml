function resolve_basic_value(key) {
    var k = basic_normvar(key); // normalize before lookup
    return ds_map_exists(global.basic_variables, k)
        ? global.basic_variables[? k]
        : real(key);             // keep your original fallback
}
