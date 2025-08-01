function resolve_basic_value(key) {
    return ds_map_exists(global.basic_variables, key) ? global.basic_variables[? key] : real(key);
}

