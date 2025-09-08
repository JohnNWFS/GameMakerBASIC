function basic_tokenize_expression_v2(expr) { 
    if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Starting expression: '" + expr + "'");

    var tokens  = [];
    var i       = 1;
    var len     = string_length(expr);
    var current = "";

    // Names that, when immediately followed by '(', should be treated as function calls
    var function_names = ["RND","ABS","EXP","LOG","LOG10","SGN","INT","SIN","COS","TAN","STR$","CHR$","REPEAT$","ASC","LEN"];

    while (i <= len) {
        var c = string_char_at(expr, i);
        if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Char[" + string(i) + "] = '" + c + "'");

        // --------------------------------------------------------------------
        // STRING LITERALS: copy verbatim `"..."` including the closing quote.
        // --------------------------------------------------------------------
        if (c == "\"") {
            var str = "\"";
            i++;
            while (i <= len) {
                var ch = string_char_at(expr, i);
                str += ch;
                if (ch == "\"") break;   // NOTE: this keeps doubled quotes as-is; evaluator unescapes "" → "
                i++;
            }
            array_push(tokens, str);
            if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added (quoted string): " + str);
            i++;
            continue;
        }

        // --------------------------------------------------------------------
        // WHITESPACE: finalize any pending token and skip the space.
        // --------------------------------------------------------------------
        if (c == " ") {
            if (current != "") {
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Finalizing token from space: '" + current + "'");
                array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added: " + current);
                current = "";
            }
            i++;
            continue;
        }

        // --------------------------------------------------------------------
        // RELATIONAL (two-char first): <=  >=  <>
        // We must emit these as single tokens so "ROLL<3" → ["ROLL","<","3"].
        // --------------------------------------------------------------------
        if (c == "<" || c == ">") {
            // finalize any pending identifier/number before the operator
            if (current != "") {
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Finalizing token before relation: '" + current + "'");
                array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added: " + current);
                current = "";
            }

            var two = (i < len) ? c + string_char_at(expr, i + 1) : "";
            if (two == "<=" || two == ">=" || two == "<>") {
                array_push(tokens, two);
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Relation token added: " + two);
                i += 2;
                continue;
            } else {
                array_push(tokens, c);  // bare < or >
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Relation token added: " + c);
                i += 1;
                continue;
            }
        }

        // --------------------------------------------------------------------
        // EQUALITY: single '='
        // --------------------------------------------------------------------
        if (c == "=") {
            if (current != "") {
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Finalizing token before '=': '" + current + "'");
                array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added: " + current);
                current = "";
            }
            array_push(tokens, "=");
            if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: '=' token added");
            i += 1;
            continue;
        }

        // --------------------------------------------------------------------
        // ARITHMETIC / PARENS / POWER / INT-DIV: +  *  /  \  (  )  %  ^
        //  - If '(' follows a known function name token, we still just emit '(';
        //    the function-ness is used later by the parser, not the tokenizer.
        // --------------------------------------------------------------------
        if (c == "+" || c == "*" || c == "/" || c == "\\" || c == "(" || c == ")" || c == "%" || c == "^") {
            if (current != "") {
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Finalizing token before operator: '" + current + "'");
                array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added: " + current);
                current = "";
            }

            // We still push "(" literally. Detection of "NAME(" being a function call
            // is handled later by your infix/postfix logic (it looks at the NAME token).
            array_push(tokens, c);
            if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Operator token added: " + c);

            i++;
            continue;
        }

        // --------------------------------------------------------------------
        // ARG SEPARATOR: comma
        // --------------------------------------------------------------------
        if (c == ",") {
            if (current != "") {
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Finalizing token before comma: '" + current + "'");
                array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added: " + current);
                current = "";
            }
            array_push(tokens, ",");
            if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Comma token added");
            i++;
            continue;
        }

        // --------------------------------------------------------------------
        // MINUS: subtraction or start of a negative number token.
        // Heuristic: if '-' is at start, or follows another operator/paren/relation,
        // and is followed by a digit, we treat it as the start of a numeric literal.
        // --------------------------------------------------------------------
        if (c == "-") {
            // finalize any pending token first
            if (current != "") {
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Finalizing token before minus: '" + current + "'");
                array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added: " + current);
                current = "";
            }

            var is_negative = false;

            // only consider negative if a digit follows
            if (i < len) {
                var next_is_digit = (ord(string_char_at(expr, i + 1)) >= 48 && ord(string_char_at(expr, i + 1)) <= 57);
                if (next_is_digit) {
                    if (array_length(tokens) == 0) {
                        is_negative = true; // start of expression → negative
                    } else {
                        var last_token = tokens[array_length(tokens) - 1];
                        // If previous token is an operator/paren/relation, this '-' starts a number
                        if ( last_token == "+" || last_token == "-" || last_token == "*" 
                          || last_token == "/" || last_token == "(" || last_token == "%" 
                          || last_token == "^" || string_upper(last_token) == "MOD" 
                          || last_token == "=" || last_token == "<" || last_token == ">" 
                          || last_token == "<=" || last_token == ">=" || last_token == "<>" ) {
                            is_negative = true;
                        }
                    }
                }
            }

            if (is_negative) {
                current = "-"; // begin building a numeric literal like "-12"
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Starting negative number");
            } else {
                array_push(tokens, "-"); // subtraction operator
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Added subtraction operator");
            }

            i++;
            continue;
        }
        // ------------------------- END '-' handling -------------------------

        // --------------------------------------------------------------------
        // DEFAULT: accumulate chars for identifiers or number bodies.
        // --------------------------------------------------------------------
        current += c;
        i++;
    }

    // ------------------------------------------------------------------------
    // END: flush any leftover token.
    // ------------------------------------------------------------------------
    if (current != "") {
        if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Finalizing last token: '" + current + "'");
        array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
        if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added: " + current);
    }

    if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Final token list = " + string(tokens));
    return tokens;
}
