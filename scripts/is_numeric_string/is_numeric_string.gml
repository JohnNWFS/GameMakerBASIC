function is_numeric_string(str) {
    if (string_length(str) == 0) return false;

    // Allow negative sign
    if (string_char_at(str, 1) == "-") {
        str = string_copy(str, 2, string_length(str));
        if (string_length(str) == 0) return false; // <- Add this
    }

    var dot_count = 0;
    for (var i = 1; i <= string_length(str); i++) {
        var c = string_char_at(str, i);
        if (c == ".") {
            dot_count++;
            if (dot_count > 1) return false;
        }
        else if (ord(c) < ord("0") || ord(c) > ord("9")) {
            return false;
        }
    }

    return true;
}
