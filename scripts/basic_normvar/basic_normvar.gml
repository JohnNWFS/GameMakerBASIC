/// basic_normvar(name) -> canonical variable key
function basic_normvar(_name) {
    return string_upper(string_trim(string(_name)));
}

/// basic_looks_numeric(s) -> bool  (no regex; robust enough for BASIC)
function basic_looks_numeric(_s) {
    var s = string_trim(string(_s));
    if (s == "") return false;
    var digits = 0;
    for (var i = 1; i <= string_length(s); i++) {
        var c = ord(string_char_at(s, i));
        if ((c >= 48 && c <= 57)) digits++;                     // 0..9
        else if (c == 46 || c == 45) { /* '.' or leading '-' */ }
        else return false;
    }
    return digits > 0;
}
