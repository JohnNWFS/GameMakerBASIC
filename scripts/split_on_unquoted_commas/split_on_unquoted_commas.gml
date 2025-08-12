/// @func split_on_unquoted_commas(s)
/// @desc Split a string on commas that are OUTSIDE quotes (and outside parentheses),
///       mirroring your colon-splitter behavior. Keeps empty fields trimmed out.
///       Examples:
///         split_on_unquoted_commas("1,2,\"a,b\",3") -> ["1","2","\"a,b\"","3"]
///         split_on_unquoted_commas("A(1,2),B")      -> ["A(1,2)","B"]
function split_on_unquoted_commas(s) {
    var parts = [];
    if (s == undefined) return parts;

    var L = string_length(s);
    var in_q = false;
    var _depth = 0;     // parentheses depth for safety (DATA can contain A(…), keep it intact)
    var start = 1;

    for (var i = 1; i <= L; i++) {
        var ch = string_char_at(s, i);

        if (ch == "\"") {
            // Handle doubled quotes "" inside strings -> treat as escaped, stay in same quote state
            var nxt = (i < L) ? string_char_at(s, i + 1) : "";
            if (in_q && nxt == "\"") { i++; continue; }
            in_q = !in_q;
            continue;
        }

        if (!in_q) {
            if (ch == "(") { _depth++; continue; }
            if (ch == ")") { _depth = max(0, _depth - 1); continue; }
            if (ch == "," && _depth == 0) {
                var seg = string_trim(string_copy(s, start, i - start));
                if (seg != "") parts[array_length(parts)] = seg;
                start = i + 1;
            }
        }
    }

    // tail
    var tail = string_trim(string_copy(s, start, L - start + 1));
    if (tail != "") parts[array_length(parts)] = tail;

    if (dbg_on && is_undefined(dbg_on) == false) {} // no-op to avoid warnings if dbg_on is macro
    if (dbg_on(DBG_FLOW)) show_debug_message("split_on_unquoted_commas('" + s + "') -> " + string(parts));

    return parts;
}
