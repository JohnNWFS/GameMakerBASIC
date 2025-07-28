function is_quoted_string(str) {
    return (string_length(str) >= 2 &&
            string_char_at(str, 1) == "\"" &&
            string_char_at(str, string_length(str)) == "\"");
}
