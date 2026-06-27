/// Core quote-aware delimiter splitter for BASIC statement parsing.
/// @param _trim        trim each emitted segment
/// @param _paren       ignore delimiters inside nested parentheses
/// @param _rem         apostrophe outside quotes starts REM (rest of line kept in segment)
/// @param _skip_empty  omit zero-length segments when splitting
/// @param _skip_empty_tail  if true, omit final segment when empty (semicolon PRINT args)
function basic_split_delimited(_s, _delim, _trim, _paren, _rem, _skip_empty, _skip_empty_tail) {
    var parts = [];
    if (_s == undefined) return parts;

    var L = string_length(_s);
    if (L == 0) return parts;

    var in_q = false;
    var _depth = 0;
    var start = 1;
    var dlen = string_length(_delim);

    for (var i = 1; i <= L; i++) {
        var ch = string_char_at(_s, i);

        if (ch == "\"") {
            var nxt = (i < L) ? string_char_at(_s, i + 1) : "";
            if (in_q && nxt == "\"") { i++; continue; }
            in_q = !in_q;
            continue;
        }

        if (_rem && !in_q && ord(ch) == 39) {
            var seg = string_copy(_s, start, L - start + 1);
            if (!_skip_empty || string_length(seg) > 0) {
                if (_trim) seg = string_trim(seg);
                array_push(parts, seg);
            }
            return parts;
        }

        if (!in_q) {
            if (_paren) {
                if (ch == "(") { _depth++; continue; }
                if (ch == ")") { _depth = max(0, _depth - 1); continue; }
            }

            var is_delim = false;
            if (dlen == 1) {
                is_delim = (ch == _delim && (!_paren || _depth == 0));
            } else if (i + dlen - 1 <= L) {
                is_delim = (string_copy(_s, i, dlen) == _delim && (!_paren || _depth == 0));
            }

            if (is_delim) {
                var piece = string_copy(_s, start, i - start);
                if (_trim) piece = string_trim(piece);
                if (!_skip_empty || string_length(piece) > 0) {
                    array_push(parts, piece);
                }
                start = i + dlen;
                i += dlen - 1;
            }
        }
    }

    var tail = string_copy(_s, start, L - start + 1);
    if (_trim) tail = string_trim(tail);
    if (_skip_empty_tail) {
        if (string_length(tail) > 0) array_push(parts, tail);
    } else if (!_skip_empty || string_length(tail) > 0) {
        array_push(parts, tail);
    }

    return parts;
}

/// @func split_on_unquoted_commas(s)
/// @desc Split a string on commas that are OUTSIDE quotes (and outside parentheses).
function split_on_unquoted_commas(s) {
    var parts = basic_split_delimited(s, ",", true, true, false, true, false);
    dbg_log(DBG_FLOW, "split_on_unquoted_commas('" + s + "') -> " + string(parts));
    return parts;
}