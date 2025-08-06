/// @function basic_run_to_console()
/// @description Executes the BASIC program in memory and prints the output to the console instead of the screen.

function basic_run_to_console() {
    show_debug_message("==== BEGIN PROGRAM CONSOLE OUTPUT ====");

    // Safety check
    if (!ds_exists(global.program_lines, ds_type_map) || !ds_exists(global.line_numbers, ds_type_list)) {
        show_debug_message("No program loaded.");
        return;
    }

    // Local context for LET variable storage
    var local_vars = ds_map_create();

    // Run through each line in order
    for (var i = 0; i < ds_list_size(global.line_numbers); i++) {
        var line_num = ds_list_find_value(global.line_numbers, i);
        var code = ds_map_find_value(global.program_lines, line_num);
        var trimmed = string_trim(code);

        var sp = string_pos(" ", trimmed);
        var cmd = (sp > 0) ? string_upper(string_copy(trimmed, 1, sp - 1)) : string_upper(trimmed);
        var arg = (sp > 0) ? string_trim(string_copy(trimmed, sp + 1, string_length(trimmed))) : "";

        switch (cmd) {
            case "LET":
                var eq_pos = string_pos("=", arg);
                if (eq_pos > 0) {
                    var varname = string_trim(string_copy(arg, 1, eq_pos - 1));
                    var value = string_trim(string_copy(arg, eq_pos + 1, string_length(arg)));
                    var value_num = real(value);
                    ds_map_replace(local_vars, varname, value_num);
                }
                break;

            case "PRINT":
                // Check if last character is semicolon
                var ends_with_semicolon = (string_char_at(arg, string_length(arg)) == ";");
                if (ends_with_semicolon) {
                    arg = string_copy(arg, 1, string_length(arg) - 1);
                }

                var segments = string_split(arg, "+");
                var output = "";
                for (var j = 0; j < array_length(segments); j++) {
                    var segment = string_trim(segments[j]);
                    if (string_length(segment) >= 2 && string_char_at(segment, 1) == "\"" && string_char_at(segment, string_length(segment)) == "\"") {
                        output += string_copy(segment, 2, string_length(segment) - 2);
                    } else if (ds_map_exists(local_vars, segment)) {
                        output += string(ds_map_find_value(local_vars, segment));
                    } else {
                        output += segment;
                    }
                }

                if (ends_with_semicolon) {
                    // no newline
                    show_debug_message(">> " + output);
                } else {
                    show_debug_message(">> " + output + "\n");
                }
                break;

            default:
                show_debug_message("Unknown command on line " + string(line_num) + ": " + cmd);
        }
    }

    ds_map_destroy(local_vars);
	basic_run_to_console_flag = false;
    show_debug_message("==== END PROGRAM CONSOLE OUTPUT ====");
}
