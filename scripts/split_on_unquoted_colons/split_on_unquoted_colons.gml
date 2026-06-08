/// @function split_on_unquoted_colons(line)
/// @description Split a line on top-level colons, ignoring colons inside "quoted strings" or after an apostrophe comment
function split_on_unquoted_colons(line) {
    var parts = [];
    var buf    = "";
    var inStr  = false;
    var len    = string_length(line);
    for (var i = 1; i <= len; i++) {
        var ch = string_char_at(line, i);
        if (ch == "\"") {
            // toggle string state and keep the quote
            inStr = !inStr;
            buf  += ch;
        }
        else if (ch == "’" && !inStr) {
            // apostrophe comment — consume remaining characters one by one, stop splitting
            buf += ch;
            for (var _j = i + 1; _j <= len; _j++) {
                buf += string_char_at(line, _j);
            }
            break;
        }
        else if (ch == ":" && !inStr) {
            // top-level colon → break here
            array_push(parts, buf);
            buf = "";
        }
        else {
            buf += ch;
        }
    }
    // push whatever’s left
    array_push(parts, buf);
    return parts;
}
