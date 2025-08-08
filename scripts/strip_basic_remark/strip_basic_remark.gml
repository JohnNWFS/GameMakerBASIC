/// Remove single quote comments, unless inside double quotes
function strip_basic_remark(arg) {
    var len = string_length(arg);
    var inside_string = false;

    for (var i = 1; i <= len; i++) {
        var c = string_char_at(arg, i);

        if (c == "\"") {
            inside_string = !inside_string;
        }
        else if (c == "'" && !inside_string) {
            // Found unquoted remark start – strip everything after
            return string_trim(string_copy(arg, 1, i - 1));
        }
    }

    // No unquoted remark found – return original
    return arg;
}
