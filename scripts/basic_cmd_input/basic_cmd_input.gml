/// @script basic_cmd_input
/// @description Prompt the user with a text and await input into a variable

/// @script basic_cmd_input
/// @description Simple INPUT command that works with existing keyboard handling
function basic_cmd_input(arg) {
    var s = string_trim(arg);
    var prompt = "";
    var varName = "";

    // Parse INPUT syntax: INPUT "prompt", VAR or INPUT VAR
    var comma_pos = string_pos(",", s);
    var semicolon_pos = string_pos(";", s);
    
    // Find first separator (comma or semicolon)
    var sep_pos = 0;
    if (comma_pos > 0 && semicolon_pos > 0) {
        sep_pos = min(comma_pos, semicolon_pos);
    } else if (comma_pos > 0) {
        sep_pos = comma_pos;
    } else if (semicolon_pos > 0) {
        sep_pos = semicolon_pos;
    }
    
    if (sep_pos > 0) {
        // Has prompt: INPUT "prompt", VAR
        prompt = string_trim(string_copy(s, 1, sep_pos - 1));
        varName = string_upper(string_trim(string_copy(s, sep_pos + 1, string_length(s) - sep_pos)));
        
        // Remove quotes from prompt if present
        if (string_length(prompt) >= 2 
            && string_char_at(prompt, 1) == "\"" 
            && string_char_at(prompt, string_length(prompt)) == "\"") {
            prompt = string_copy(prompt, 2, string_length(prompt) - 2);
        }
    } else {
        // No prompt: INPUT VAR
        varName = string_upper(s);
        //prompt = "? "; // Default prompt
    }
    
    dbg_log(DBG_FLOW, "INPUT: Variable='" + varName + "', Prompt='" + prompt + "'");

    // Set up input state for your existing keyboard handler
    global.input_prompt     = prompt;          // shown live in Draw alongside typed text
    global.input_show_qmark = (prompt == "");  // no prompt → show default "? "
    global.awaiting_input = true;
    global.pause_mode = false;
    global.input_expected = true;
    global.input_target_var = varName;
    global.interpreter_input = ""; // Clear any existing input buffer
    global.interpreter_cursor_pos = 0;
    global.input_guard_frames = 3;
    global.input_ignore_enter_until_release = true;
    
// Initialize the variable only if absent; avoid numeric 0 pre-seed
 varName = basic_normvar(varName); // ensure canonical now
if (!basic_var_exists(varName)) {
    basic_var_set(varName, "");
}

    
    dbg_log(DBG_FLOW, "INPUT: Awaiting input for variable " + varName);
	
	// NEW: schedule "resume at next colon segment" and yield now
	global.interpreter_use_stmt_jump = true;
	global.interpreter_target_line   = global.interpreter_current_line_index;
	global.interpreter_target_stmt   = global.interpreter_current_stmt_index + 1;
	if (dbg_on(DBG_FLOW)) show_debug_message(
	    "INPUT: scheduling resume at stmt " + string(global.interpreter_target_stmt)
	    + " on line-index " + string(global.interpreter_target_line)
	);
	return; // IMPORTANT: stop dispatching the rest of this line now	
	
	
	
	
}
/*function basic_cmd_input(arg) {
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
        dbg_log(DBG_FLOW, "INPUT: Prompt='" + rawPrompt + "'");
    } else {
        dbg_log(DBG_FLOW, "INPUT: No prompt (default '? ')");
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

    dbg_log(DBG_FLOW, "INPUT: Awaiting input for variable " + varName);
}
