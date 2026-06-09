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
        dbg_log(DBG_FLOW, "parse_data_value: STRING → \"" + inner + "\" from " + s);
        return inner;
    }

    // Try numeric only after a safe textual scan. Non-numeric DATA remains a string.
    if (is_numeric_string(s)) {
        var n = real(s);
        dbg_log(DBG_FLOW, "parse_data_value: NUMBER → " + string(n) + " from " + s);
        return n;
    }

    // Fallback: keep as literal string (lets users store symbolic tokens)
    dbg_log(DBG_FLOW, "parse_data_value: FALLBACK STRING → \"" + s + "\"");
    return s;
}
