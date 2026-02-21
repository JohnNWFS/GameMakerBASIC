/// MODE 1 COMMAND
/// FILE: scripts/basic_parse_color.gml
/// FUNCTION: basic_parse_color(colstr)
/// Behavior:
/// 1) Try global.colors map (case-insensitive; quotes ok; aliases normalized)
/// 2) Try hex formats: &Hrrggbb, 0xrrggbb, #rrggbb, $rrggbb
/// 3) Try decimal integer
/// 4) Fallback to c_white with a debug note

function basic_parse_color(colstr) {
    var s = string_trim(colstr);

    // Strip matching quotes
    if (string_length(s) >= 2) {
        var f = string_char_at(s, 1);
        var l = string_char_at(s, string_length(s));
        if ((f == "\"" || f == "'") && f == l) s = string_copy(s, 2, string_length(s) - 2);
    }

    // Normalize for name lookup
    var key = string_upper(s);

    // Alias normalization to your existing keys
    if (key == "GREY") key = "GRAY";
    if (key == "DARKGRAY" || key == "DARKGREY") key = "DKGRAY";
    // LIGHTGRAY not in your map; handle as special case

    // 1) Named color via global.colors (global is a struct, so check the variable)
    if (variable_global_exists("colors")) {
        if (key == "LIGHTGRAY" || key == "LIGHTGREY") {
            return make_color_rgb(192,192,192);
        }
        if (ds_map_exists(global.colors, key)) {
            return ds_map_find_value(global.colors, key);
        }
    }

    // 2) Hex parsing (RRGGBB)
    var hex = "";
    var ku  = string_upper(s);
    if (string_length(ku) >= 3 && string_copy(ku,1,2) == "&H") {
        hex = string_copy(s, 3, string_length(s)-2);
    } else if (string_length(ku) >= 3 && string_copy(ku,1,2) == "0X") {
        hex = string_copy(s, 3, string_length(s)-2);
    } else if (string_length(ku) >= 1 && string_char_at(ku,1) == "#") {
        hex = string_copy(s, 2, string_length(s)-1);
    } else if (string_length(ku) >= 1 && string_char_at(ku,1) == "$") {
        hex = string_copy(s, 2, string_length(s)-1);
    }

    if (hex != "") {
        var clean = "";
        for (var i = 1; i <= string_length(hex); i++) {
            var ch = string_upper(string_char_at(hex, i));
            if ((ch >= "0" && ch <= "9") || (ch >= "A" && ch <= "F")) clean += ch;
        }
        if (string_length(clean) == 6) {
            var rr = string_copy(clean,1,2);
            var gg = string_copy(clean,3,2);
            var bb = string_copy(clean,5,2);
            return make_color_rgb(__hex_byte(rr), __hex_byte(gg), __hex_byte(bb));
        }
    }

    // 3) Decimal integer fallback
    if (is_numeric_string(s)) {
        return real(s);
    }

    // 4) Fallback
    if (dbg_on(DBG_FLOW)) show_debug_message("basic_parse_color: unknown color '" + s + "', defaulting to WHITE");
    return c_white;
}

function __hex_byte(two) {
    var hi = string_char_at(two,1);
    var lo = string_char_at(two,2);
    return __hex_nibble(hi) * 16 + __hex_nibble(lo);
}
function __hex_nibble(ch) {
    ch = string_upper(ch);
    if (ch >= "0" && ch <= "9") return ord(ch) - ord("0");
    if (ch >= "A" && ch <= "F") return 10 + (ord(ch) - ord("A"));
    return 0;
}
