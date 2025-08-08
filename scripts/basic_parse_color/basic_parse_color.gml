function basic_parse_color(colstr) {
    colstr = string_upper(string_trim(colstr));

    if (ds_map_exists(global.colors, colstr)) {
        return global.colors[? colstr];
    }

    // Try as direct numeric value
    var val = real(colstr);
    if (!is_nan(val)) {
        return val;
    }

    return c_white; // Fallback
}
