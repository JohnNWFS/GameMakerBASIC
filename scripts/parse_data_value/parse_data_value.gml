/// @func parse_data_value(raw)
/// @desc Convert a DATA token to a GML value:
///       - Quoted -> string with "" -> " unescaped
///       - Else   -> real(number) if numeric, otherwise keep as string (tolerant)
function parse_data_value(raw) {
    var s = string_trim(raw);
    var L = string_length(s);

    // Quoted string
    if (L >= 2 && string_char_at(s, 1) == "\"" && string_char_at(s, L) == "\"") {
        var inner = string_copy(s, 2, L - 2);
        inner = string_replace_all(inner, "\"\"", "\""); // unescape doubled quotes
        if (dbg_on(DBG_FLOW)) show_debug_message("parse_data_value: STRING → \"" + inner + "\" from " + s);
        return inner;
    }

    // Try numeric
    var n = real(s);
    if (string(n) == s || is_real(n)) {
        // Note: GML will give us 0 for non-numeric too; we try a tighter check:
        // If s contains any alpha (not e/E for exponent), treat as string.
        var _has_alpha = false;
        for (var i = 1; i <= L; i++) {
            var ch = string_char_at(s, i);
            if ( (ch >= "A" && ch <= "Z") || (ch >= "a" && ch <= "z") ) {
                if (ch != "E" && ch != "e") { _has_alpha = true; break; }
            }
        }
        if (!_has_alpha) {
            if (dbg_on(DBG_FLOW)) show_debug_message("parse_data_value: NUMBER → " + string(n) + " from " + s);
            return n;
        }
    }

    // Fallback: keep as literal string (lets users store symbolic tokens)
    if (dbg_on(DBG_FLOW)) show_debug_message("parse_data_value: FALLBACK STRING → \"" + s + "\"");
    return s;
}
