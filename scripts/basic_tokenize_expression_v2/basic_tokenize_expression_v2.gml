function basic_tokenize_expression_v2(expr) {
    if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Starting expression: '" + expr + "'");

    var tokens = [];
    var i = 1;
    var len = string_length(expr);
    var current = "";

    var function_names = ["RND", "ABS", "EXP", "LOG", "LOG10", "SGN", "INT", "SIN", "COS", "TAN", "STR$", "CHR$", "REPEAT$"];

    while (i <= len) {
        var c = string_char_at(expr, i);
//        show_debug_message("TOKENIZER: Char[" + string(i) + "] = '" + c + "'");
		if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Char[" + string(i) + "] = '" + c + "'");
		

        // --- STRING LITERAL SUPPORT (preserve exact quoted content) ---
        if (c == "\"") {
            var str = "\"";
            i++;
            while (i <= len) {
                var ch = string_char_at(expr, i);
                str += ch;
                if (ch == "\"") break;
                i++;
            }
            array_push(tokens, str);
            if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added (quoted string): " + str);
            i++;
            continue;
        }

        // --- Handle whitespace ---
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


        // --- Handle operators ---
			if (c == "+" || c == "*" || c == "/" || c == "(" || c == ")" || c == "%" || c == "^") {
            if (current != "") {
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Finalizing token before operator: '" + current + "'");
                array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added: " + current);
                current = "";
            }
            if (c == "(" && array_length(tokens) > 0) {
				var last = "";
				if (variable_instance_exists(id, "tokens") && is_array(tokens) && array_length(tokens) > 0) {
				    last = string_upper(string(tokens[array_length(tokens) - 1]));
				}
                if (array_contains(function_names, last)) {
                    array_push(tokens, "(");
                    if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Function call detected: " + last + "(");
                } else {
                    array_push(tokens, "(");
                    if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Operator token added: " + c);
                }
            } else {
                array_push(tokens, c);
                if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Operator token added: " + c);
            }
            i++;
            continue;
        }

        // --- Handle commas ---
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

// --- Handle subtraction/negative numbers ---
if (c == "-") {
    // First, finalize any pending token
    if (current != "") {
        if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Finalizing token before minus: '" + current + "'");
        array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
        if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added: " + current);
        current = "";
    }
    
    // Check if this should be a negative number
    var is_negative = false;
    
    // Must be followed by a digit to be a negative number
    if (i < len && (ord(string_char_at(expr, i + 1)) >= 48 && ord(string_char_at(expr, i + 1)) <= 57)) {
        if (array_length(tokens) == 0) {
            // Start of expression -> negative number
            is_negative = true;
        } else {
            // Check what the last token was
            var last_token = tokens[array_length(tokens) - 1];
            if (last_token == "+" || last_token == "-" || last_token == "*" || 
                last_token == "/" || last_token == "(" || last_token == "%" || 
                last_token == "^" || string_upper(last_token) == "MOD" || 
                last_token == "=" || last_token == "<" || last_token == ">" ||
                last_token == "<=" || last_token == ">=" || last_token == "<>") {
                // After operator -> negative number
                is_negative = true;
            }
        }
    }
    
    if (is_negative) {
        // Start building a negative number token
        current = "-";
        if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Starting negative number");
    } else {
        // Regular subtraction operator
        array_push(tokens, "-");
        if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Added subtraction operator");
    }
    
    i++;
    continue;
}
//END if c = -

        // --- Accumulate characters for identifiers or numbers ---
        current += c;
        i++;
    }

    // --- Finalize any remaining token ---
    if (current != "") {
        if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Finalizing last token: '" + current + "'");
        array_push(tokens, string_upper(current) == "MOD" ? "MOD" : current);
        if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Token added: " + current);
    }

    if (dbg_on(DBG_PARSE)) show_debug_message("TOKENIZER: Final token list = " + string(tokens));
    return tokens;
}