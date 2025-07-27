/// @function string_is_number(str)
/// @desc Returns true if the input string can be safely converted to a number.
/// @param {string} str - The string to check
function string_is_number(str) {
    if (is_real(str)) return true; // Already a number
    var trimmed = string_trim(str);
    if (trimmed == "") return false;

    var dot_found = false;
    var start = 1;

    // Allow for optional leading minus sign
    if (string_char_at(trimmed, 1) == "-") {
        if (string_length(trimmed) == 1) return false;
        start = 2;
    }

    for (var i = start; i <= string_length(trimmed); i++) {
        var ch = string_char_at(trimmed, i);
        if (ch >= "0" && ch <= "9") continue;
        else if (ch == ".") {
            if (dot_found) return false; // only one dot allowed
            dot_found = true;
        } else {
            return false;
        }
    }

    return true;
}
