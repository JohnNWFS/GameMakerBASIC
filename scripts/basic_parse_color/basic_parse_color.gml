/// Parse a 6-digit hex string (RRGGBB) to a GML color via int64.
function basic_parse_hex_rgb(_hex6) {
    var clean = "";
    for (var i = 1; i <= string_length(_hex6); i++) {
        var ch = string_upper(string_char_at(_hex6, i));
        if ((ch >= "0" && ch <= "9") || (ch >= "A" && ch <= "F")) clean += ch;
    }
    if (string_length(clean) != 6) return undefined;
    var packed = int64("0x" + clean);
    return make_color_rgb((packed >> 16) & $FF, (packed >> 8) & $FF, packed & $FF);
}

/// MODE 1 COMMAND — basic_parse_color(colstr)
/// 1) Named color via global.colors
/// 2) Hex: &Hrrggbb, 0xrrggbb, #rrggbb, $rrggbb
/// 3) Decimal integer
/// 4) Fallback c_white
function basic_parse_color(colstr) {
    var s = string_trim(colstr);

    if (string_length(s) >= 2) {
        var f = string_char_at(s, 1);
        var l = string_char_at(s, string_length(s));
        if ((f == "\"" || f == "'") && f == l) s = string_copy(s, 2, string_length(s) - 2);
    }

    var key = string_upper(s);
    if (key == "GREY") key = "GRAY";
    if (key == "DARKGRAY" || key == "DARKGREY") key = "DKGRAY";

    if (variable_global_exists("colors")) {
        if (key == "LIGHTGRAY" || key == "LIGHTGREY") {
            return make_color_rgb(192, 192, 192);
        }
        if (ds_map_exists(global.colors, key)) {
            return ds_map_find_value(global.colors, key);
        }
    }

    var hex = "";
    var ku  = string_upper(s);
    if (string_length(ku) >= 3 && string_copy(ku, 1, 2) == "&H") {
        hex = string_copy(s, 3, string_length(s) - 2);
    } else if (string_length(ku) >= 3 && string_copy(ku, 1, 2) == "0X") {
        hex = string_copy(s, 3, string_length(s) - 2);
    } else if (string_length(ku) >= 1 && string_char_at(ku, 1) == "#") {
        hex = string_copy(s, 2, string_length(s) - 1);
    } else if (string_length(ku) >= 1 && string_char_at(ku, 1) == "$") {
        hex = string_copy(s, 2, string_length(s) - 1);
    }

    if (hex != "") {
        var parsed = basic_parse_hex_rgb(hex);
        if (!is_undefined(parsed)) return parsed;
    }

    if (is_numeric_string(s)) {
        return real(s);
    }

    dbg_log(DBG_FLOW, "basic_parse_color: unknown color '" + s + "', defaulting to WHITE");
    return c_white;
}