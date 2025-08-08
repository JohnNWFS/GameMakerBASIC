function split_on_unquoted_semicolons(s) {
    var result = [];
    var current = "";
    var in_string = false;
    for (var i = 1; i <= string_length(s); i++) {
        var c = string_char_at(s, i);
        if (c == "\"") in_string = !in_string;
        if (c == ";" && !in_string) {
            array_push(result, string_trim(current));
            current = "";
        } else {
            current += c;
        }
    }
    if (string_length(current) > 0) array_push(result, string_trim(current));
    return result;
}
