function basic_tokenize_expression_v2(expr) {
    show_debug_message("TOKENIZER: Starting expression: '" + expr + "'");

    var tokens = [];
    var i = 1;
    var len = string_length(expr);
    var current = "";

    var function_names = ["RND", "ABS", "EXP", "LOG", "SGN", "INT", "SIN", "COS", "TAN"];

    while (i <= len) {
        var c = string_char_at(expr, i);
        show_debug_message("TOKENIZER: Char[" + string(i) + "] = '" + c + "'");

        if (c == " ") {
            if (current != "") {
                show_debug_message("TOKENIZER: Finalizing token from space: '" + current + "'");
                array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
                show_debug_message("TOKENIZER: Token added: " + current);
                current = "";
            }
        }
        else if (c == "+" || c == "*" || c == "/" || c == "(" || c == ")" || c == "%") {
            if (current != "") {
                show_debug_message("TOKENIZER: Finalizing token before operator: '" + current + "'");
                array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
                show_debug_message("TOKENIZER: Token added: " + current);
                current = "";
            }

            // Handle function call: EXP( → "EXP", "("
            if (c == "(" && array_length(tokens) > 0) {
                var last = string_upper(tokens[array_length(tokens) - 1]);
                if (array_contains(function_names, last)) {
                    // Leave function name, just add the paren
                    array_push(tokens, "(");
                    show_debug_message("TOKENIZER: Function call detected: " + last + "(");
                } else {
                    array_push(tokens, "(");
                    show_debug_message("TOKENIZER: Operator token added: " + c);
                }
            } else {
                array_push(tokens, c);
                show_debug_message("TOKENIZER: Operator token added: " + c);
            }
        }
        else if (c == "-") {
            var is_negative_number = false;
            if (array_length(tokens) == 0) {
                is_negative_number = true;
            } else {
                var last_token = tokens[array_length(tokens) - 1];
                if (last_token == "+" || last_token == "-" || last_token == "*" || 
                    last_token == "/" || last_token == "(" || last_token == "%" || 
                    string_upper(last_token) == "MOD") {
                    is_negative_number = true;
                }
            }

            if (is_negative_number) {
                show_debug_message("TOKENIZER: Beginning negative number with '-'");
                current += "-";
            } else {
                if (current != "") {
                    show_debug_message("TOKENIZER: Finalizing token before subtraction: '" + current + "'");
                    array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
                    show_debug_message("TOKENIZER: Token added: " + current);
                    current = "";
                }
                array_push(tokens, "-");
                show_debug_message("TOKENIZER: Subtraction operator token added: -");
            }
        }
        else {
            current += c;
        }
        i += 1;
    }

    if (current != "") {
        show_debug_message("TOKENIZER: Finalizing last token: '" + current + "'");
        array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
        show_debug_message("TOKENIZER: Token added: " + current);
    }

    show_debug_message("TOKENIZER: Final token list = " + string(tokens));
    return tokens;
}
