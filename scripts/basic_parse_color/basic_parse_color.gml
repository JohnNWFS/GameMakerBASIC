/// Initialize the named BASIC color table (struct storage).
function basic_colors_init() {
    global.colors = {
        RED: make_color_rgb(255, 0, 0),
        GREEN: make_color_rgb(0, 255, 0),
        BLUE: make_color_rgb(0, 0, 255),
        CYAN: c_teal,
        MAGENTA: c_fuchsia,
        YELLOW: c_yellow,
        WHITE: c_white,
        BLACK: c_black,
        GRAY: c_gray,
        ORANGE: make_color_rgb(255, 165, 0),
        LIME: c_lime,
        NAVY: make_color_rgb(0, 0, 128),
        DKGRAY: make_color_rgb(64, 64, 64),
    };
}

function basic_colors_ensure() {
    if (!variable_global_exists("colors") || !is_struct(global.colors)) {
        basic_colors_init();
    }
}

function basic_color_normalize_key(_key) {
    var k = string_upper(string_trim(_key));
    if (k == "GREY") return "GRAY";
    if (k == "DARKGRAY" || k == "DARKGREY") return "DKGRAY";
    return k;
}

/// Named color lookup; undefined when unknown (LIGHTGRAY alias handled here).
function basic_color_named_get(_key) {
    basic_colors_ensure();
    var k = basic_color_normalize_key(_key);
    if (k == "LIGHTGRAY" || k == "LIGHTGREY") {
        return make_color_rgb(192, 192, 192);
    }
    if (!variable_struct_exists(global.colors, k)) return undefined;
    return global.colors[$ k];
}

function basic_hex_nibble(_ch) {
    _ch = string_upper(_ch);
    if (_ch >= "0" && _ch <= "9") return ord(_ch) - ord("0");
    if (_ch >= "A" && _ch <= "F") return 10 + (ord(_ch) - ord("A"));
    return 0;
}

function basic_hex_byte(_two) {
    return basic_hex_nibble(string_char_at(_two, 1)) * 16 + basic_hex_nibble(string_char_at(_two, 2));
}

/// Pull the first 6 hex digits from a tail string.
function basic_color_collect_hex6(_tail) {
    var clean = "";
    for (var i = 1; i <= string_length(_tail); i++) {
        var ch = string_upper(string_char_at(_tail, i));
        if ((ch >= "0" && ch <= "9") || (ch >= "A" && ch <= "F")) {
            clean += ch;
            if (string_length(clean) >= 6) break;
        }
    }
    return (string_length(clean) == 6) ? clean : "";
}

/// Parse a 6-digit hex string (RRGGBB) to a GML color.
function basic_parse_hex_rgb(_hex6) {
    if (string_length(_hex6) != 6) return undefined;
    return make_color_rgb(
        basic_hex_byte(string_copy(_hex6, 1, 2)),
        basic_hex_byte(string_copy(_hex6, 3, 2)),
        basic_hex_byte(string_copy(_hex6, 5, 2))
    );
}

/// QBASIC &HBBGGRR — byte layout matches GML $BBGGRR colour integers.
function basic_parse_hex_bgr(_hex6) {
    if (string_length(_hex6) != 6) return undefined;
    var _bb = basic_hex_byte(string_copy(_hex6, 1, 2));
    var _gg = basic_hex_byte(string_copy(_hex6, 3, 2));
    var _rr = basic_hex_byte(string_copy(_hex6, 5, 2));
    return _bb | (_gg << 8) | (_rr << 16);
}

/// Normalize a color spec string (quotes, entities, unicode lookalikes).
function basic_color_normalize_spec(_raw) {
    var s = string_trim(_raw);
    if (string_length(s) == 0) return s;

    s = string_replace_all(s, "&amp;", "&");
    s = string_replace_all(s, "&AMP;", "&");
    s = string_replace_all(s, "&&", "&");
    s = string_replace_all(s, chr(65286), chr(38)); // fullwidth &
    s = string_replace_all(s, chr(65284), chr(36)); // fullwidth $
    // Collapse optional space after ampersand: "& H00FF00" -> "&H00FF00"
    var _amp = chr(38);
    s = string_replace_all(s, _amp + " ", _amp);

    // PRINTAT-style quote strip: always drop opening quote; drop closing when present.
    var f = string_char_at(s, 1);
    if (f == "\"" || f == "'") {
        s = string_copy(s, 2, string_length(s) - 1);
        if (string_length(s) > 0 && string_char_at(s, string_length(s)) == f) {
            s = string_copy(s, 1, string_length(s) - 1);
        }
    }

    return string_trim(s);
}

/// @returns { and_h:false, hex6:"" }
function basic_color_extract_hex6(_s) {
    var _out = { and_h: false, hex6: "" };
    var ku = string_upper(_s);
    if (string_length(ku) < 1) return _out;

    var lead_ord = ord(string_char_at(ku, 1));

    // QBASIC &H (ord checks only — never compare against "&" string literals in GML)
    if (string_length(ku) >= 3 && lead_ord == 38 && ord(string_char_at(ku, 2)) == 72) {
        _out.and_h = true;
        _out.hex6 = basic_color_collect_hex6(string_copy(_s, 3, string_length(_s) - 2));
        return _out;
    }
    if (string_length(ku) >= 3 && lead_ord == 48 && ord(string_char_at(ku, 2)) == 88) {
        _out.hex6 = basic_color_collect_hex6(string_copy(_s, 3, string_length(_s) - 2));
        return _out;
    }
    if (lead_ord == 35 || lead_ord == 36) {
        _out.hex6 = basic_color_collect_hex6(string_copy(_s, 2, string_length(_s) - 1));
        return _out;
    }

    // Lost ampersand: H00FF00
    if (string_length(ku) >= 7 && lead_ord == 72) {
        _out.and_h = true;
        _out.hex6 = basic_color_collect_hex6(string_copy(_s, 2, string_length(_s) - 1));
        return _out;
    }

    // Bare 6-digit hex body: 00FF00 / FFA500
    if (string_length(ku) == 6) {
        var bare = basic_color_collect_hex6(_s);
        if (bare != "") _out.hex6 = bare;
    }

    return _out;
}

/// RGB(r,g,b) with expression-capable components.
function basic_parse_rgb_form(_spec) {
    var ku = string_upper(string_trim(_spec));
    if (string_length(ku) < 6 || string_copy(ku, 1, 4) != "RGB(") return undefined;
    if (string_char_at(ku, string_length(ku)) != ")") return undefined;

    var inner = string_copy(ku, 5, string_length(ku) - 5);
    var parts = basic_split_delimited(inner, ",", true, true, false, true, false);
    if (array_length(parts) != 3) return undefined;

    var _r = clamp(floor(basic_evaluate_expression_v2(string_trim(parts[0]))), 0, 255);
    var _g = clamp(floor(basic_evaluate_expression_v2(string_trim(parts[1]))), 0, 255);
    var _b = clamp(floor(basic_evaluate_expression_v2(string_trim(parts[2]))), 0, 255);
    return make_color_rgb(_r, _g, _b);
}

/// MODE 1 COMMAND — basic_parse_color(colstr [, fallback])
/// 1) Named color via global.colors
/// 2) RGB(r,g,b)
/// 3) Hex: &HBBGGRR, 0xrrggbb, #rrggbb, $rrggbb
/// 4) Decimal integer
/// 5) fallback (default c_white; pass noone to signal unknown)
function basic_parse_color(colstr, _fallback) {
    if (argument_count < 2) _fallback = c_white;

    var s = basic_color_normalize_spec(colstr);
    if (string_length(s) == 0) {
        if (_fallback == noone) return noone;
        return _fallback;
    }

    var key = basic_color_normalize_key(s);

    var rgb_form = basic_parse_rgb_form(key);
    if (!is_undefined(rgb_form)) return rgb_form;

    var named = basic_color_named_get(key);
    if (!is_undefined(named)) return named;

    var _hex = basic_color_extract_hex6(s);
    if (_hex.hex6 != "") {
        var parsed = _hex.and_h ? basic_parse_hex_bgr(_hex.hex6) : basic_parse_hex_rgb(_hex.hex6);
        if (!is_undefined(parsed)) return parsed;
    }

    if (is_numeric_string(s)) {
        return real(s);
    }

    if (_fallback == noone) return noone;

    dbg_log(DBG_FLOW, "basic_parse_color: unknown color '" + s + "', defaulting to " + string(_fallback));
    return _fallback;
}