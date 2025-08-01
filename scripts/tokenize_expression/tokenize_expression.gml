function tokenize_expression(expr) {
    var tokens = [];
    var i = 1;
    while (i <= string_length(expr)) {
        var ch = string_char_at(expr, i);

        if (ch == " " || ch == "\t") {
            i++;
            continue;
        }

        if (ch == "+" || ch == "-" || ch == "*" || ch == "/" || ch == "^" || ch == "(" || ch == ")") {
            array_push(tokens, ch);
            i++;
        }
        else if (ord(ch) >= 48 && ord(ch) <= 57) {
            var num = "";
            while (i <= string_length(expr) && (ord(string_char_at(expr, i)) >= 48 && ord(string_char_at(expr, i)) <= 57)) {
                num += string_char_at(expr, i);
                i++;
            }
            array_push(tokens, num);
        }
        else if (is_letter(ch)) {
            var ident = "";
            while (i <= string_length(expr) && (is_letter_or_digit(string_char_at(expr, i)))) {
                ident += string_char_at(expr, i);
                i++;
            }
            if (string_char_at(expr, i) == "(") {
                array_push(tokens, ident); // Function name
            } else {
                array_push(tokens, ident); // Variable
            }
        }
        else if (ch == ",") {
            array_push(tokens, ",");
            i++;
        }
        else {
            show_debug_message("Unknown character in expression: " + ch);
            i++;
        }
    }

    return tokens;
}

