/// @script basic_cmd_input
/// @description Prompt the user with a text and await input into a variable
function basic_cmd_input(arg) {
    var s = string_trim(arg);
    var rawPrompt = "";
    var varName   = "";

    // 1) Primary split: first top-level ';' or ',' (quote-aware)
    var sep_pos = 0;
    var sep_ch  = "";
    var in_q = false;
    var L = string_length(s);
    for (var i = 1; i <= L; i++) {
        var ch = string_char_at(s, i);
        if (ch == "\"") { in_q = !in_q; continue; }
        if (!in_q && (ch == ";" || ch == ",")) { sep_pos = i; sep_ch = ch; break; }
    }

    if (sep_pos > 0) {
        rawPrompt = string_trim(string_copy(s, 1, sep_pos - 1));
        varName   = string_upper(string_trim(string_copy(s, sep_pos + 1, L - sep_pos)));
    } else {
        // 2) Fallback: starts with a quoted prompt but no separator was detected (e.g., `"PROMPT" ; VAR`)
        if (L >= 2 && string_char_at(s, 1) == "\"") {
            // find closing quote
            var close = 0;
            for (var k = 2; k <= L; k++) {
                if (string_char_at(s, k) == "\"") { close = k; break; }
            }
            if (close > 0) {
                rawPrompt = string_copy(s, 2, close - 2); // inside quotes
                var rest = string_trim(string_copy(s, close + 1, L - close));
                // consume optional separator and following spaces
                if (string_length(rest) > 0) {
                    var first = string_char_at(rest, 1);
                    if (first == ";" || first == ",") {
                        rest = string_trim(string_delete(rest, 1, 1));
                    }
                }
                varName = string_upper(string_trim(rest));
            } else {
                // no closing quote → treat entire thing as var
                varName = string_upper(s);
            }
        } else {
            // no prompt provided; entire arg is the variable name
            varName = string_upper(s);
        }
    }

    // 3) If prompt still has surrounding quotes, strip them
    if (string_length(rawPrompt) >= 2
        && string_char_at(rawPrompt, 1) == "\""
        && string_char_at(rawPrompt, string_length(rawPrompt)) == "\"")
    {
        rawPrompt = string_copy(rawPrompt, 2, string_length(rawPrompt) - 2);
    }

    // 4) Emit the prompt (append a space if missing) 
    if (rawPrompt != "") {
        if (string_char_at(rawPrompt, string_length(rawPrompt)) != " ") rawPrompt += " ";
        ds_list_add(global.output_lines, rawPrompt);
        ds_list_add(global.output_colors, global.basic_text_color);
        show_debug_message("INPUT: Prompt='" + rawPrompt + "'");
    } else {
        show_debug_message("INPUT: No prompt (default '? ')");
    }

    // 5) Seed the variable (string vars end with $, others numeric)
    if (string_length(varName) > 0 && string_char_at(varName, string_length(varName)) == "$") {
        global.basic_variables[? varName] = "";
    } else {
        global.basic_variables[? varName] = "0";
    }

    // 6) Enter input mode
    global.awaiting_input   = true;
    global.pause_mode       = false;
    global.input_expected   = true;
    global.input_target_var = varName;

    show_debug_message("INPUT: Awaiting input for variable " + varName);
}
