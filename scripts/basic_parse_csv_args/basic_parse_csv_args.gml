/// MODE 1 COMMAND
function basic_parse_csv_args(str) {
    var args = [];
    var current = "";
    var in_quotes = false;
    var paren_depth = 0;
    var i = 1;
    var len = string_length(str);

    while (i <= len) {
        var c = string_char_at(str, i);

        if (c == "\"") {
            in_quotes = !in_quotes;
            current += c; // Preserve quote so later commands can detect strings
        }
        else if (!in_quotes && c == "(") {
            paren_depth += 1;
            current += c;
        }
        else if (!in_quotes && c == ")") {
            paren_depth -= 1;
            current += c;
        }
        else if (c == "," && !in_quotes && paren_depth == 0) {
            array_push(args, string_trim(current));
            current = "";
        }
        else {
            current += c;
        }

        i += 1;
    }

    if (string_length(current) > 0) {
        array_push(args, string_trim(current));
    }

    return args;
}
