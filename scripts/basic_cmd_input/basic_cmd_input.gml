/// @script basic_cmd_input
/// @description Prompt the user with a text and await input into a variable
function basic_cmd_input(arg) {
    // 1) Split on the first comma → [ promptText , varName ]
    var commaPos = string_pos(",", arg);
    var rawPrompt, varName;
    if (commaPos > 0) {
        rawPrompt = string_trim(string_copy(arg, 1, commaPos - 1));
        varName   = string_upper(string_trim(string_copy(arg, commaPos + 1, string_length(arg))));
    } else {
        rawPrompt = "";
        varName   = string_upper(string_trim(arg));
    }

	  // 2) Strip surrounding quotes from prompt
	if (string_length(rawPrompt) >= 2
	    && string_char_at(rawPrompt, 1) == "\""
	    && string_char_at(rawPrompt, string_length(rawPrompt)) == "\"")
	{
	    rawPrompt = string_copy(rawPrompt, 2, string_length(rawPrompt) - 2);
	}
	
    // 3) Display the prompt text on the interpreter screen
    if (rawPrompt != "") {
        ds_list_add(global.output_lines, rawPrompt);
        ds_list_add(global.output_colors, global.basic_text_color);
    }

	// 4) Seed the variable to "0" so we never get an empty string in expression evaluation
	global.basic_variables[? varName] = "0";

	// 5) Enter input mode
	global.awaiting_input   = true;
	global.pause_mode       = false;
	global.input_target_var = varName;
	show_debug_message("INPUT: Awaiting input for variable " + varName);

}
