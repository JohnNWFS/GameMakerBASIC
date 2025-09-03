/// @function editor_import_text_to_program(_text)
/// @desc Parse plain text into numbered BASIC lines and import.
/// Lines in form "NNN CODE..."; a bare "NNN" deletes that line.
function editor_import_text_to_program(_text) {
    if (!is_string(_text)) return 0;

    // Normalize line endings
    var blob = string_replace_all(string_replace_all(_text, "\r\n", "\n"), "\r", "\n");

    var count = 0;
    var i = 1, len = string_length(blob), start = 1;
    while (i <= len + 1) {
        if (i > len || string_char_at(blob, i) == "\n") {
            var line = string_trim(string_copy(blob, start, i - start));
            if (line != "") {
                var sp = string_pos(" ", line);
                var ln_str = (sp > 0) ? string_copy(line, 1, sp - 1) : line;
                var code   = (sp > 0) ? string_trim(string_copy(line, sp + 1, string_length(line))) : "";
                var _ln = real(ln_str);
                if (ln_str != "" && is_real(_ln) && _ln > 0) {
                    if (code == "") {
                        // delete empty-numbered line
                        if (function_exists("delete_program_line")) delete_program_line(_ln);
                    } else {
                        if (function_exists("add_or_update_program_line")) add_or_update_program_line(_ln, code);
                    }
                    count++;
                }
            }
            start = i + 1;
        }
        i++;
    }
    return count;
}
