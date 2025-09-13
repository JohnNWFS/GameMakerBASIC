/// @function string_split_spaces(str)
/// @desc Split on one or more whitespace chars; returns array of tokens (no quotes handling).
function string_split_spaces(str) {
    var s = string(str);
    var L = string_length(s);
    var out = array_create(0);
    var i = 1;

    while (i <= L) {
        // skip whitespace
        while (i <= L) {
            var ch = string_char_at(s, i);
            if (ch != " " && ch != "	" && ch != chr(13) && ch != chr(10)) break;
            i++;
        }
        if (i > L) break;

        var start = i;
        while (i <= L) {
            var ch2 = string_char_at(s, i);
            if (ch2 == " " || ch2 == "	" || ch2 == chr(13) || ch2 == chr(10)) break;
            i++;
        }
        var token = string_copy(s, start, i - start);
        out[array_length(out)] = token;
    }
    return out;
}
