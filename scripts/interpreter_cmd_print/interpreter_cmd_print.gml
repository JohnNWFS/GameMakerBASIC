/// @function interpreter_cmd_print(argument)
/// @description Handles the BASIC PRINT command.
/// @param arg - The string argument from the BASIC code

function interpreter_cmd_print(arg) {
    // Remove surrounding double quotes if present
    if (string_length(arg) >= 2 &&
        string_char_at(arg, 1) == "\"" &&
        string_char_at(arg, string_length(arg)) == "\"") {
        arg = string_copy(arg, 2, string_length(arg) - 2);
    }

    ds_list_add(output_lines, arg);
}
