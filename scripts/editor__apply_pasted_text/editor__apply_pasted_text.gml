/// @function editor__apply_pasted_text(text)
/// @desc Parses BASIC lines from `text` and mutates global.program_map/global.line_list.
/// @returns {bool} true if at least one line was applied; false otherwise
function editor__apply_pasted_text(text) {
    if (is_undefined(text) || string_length(text) <= 0) {
        show_message("Clipboard is empty.");
        return false;
    }

    var applied = false;
    var lines = string_split(text, "\n");
    if (function_exists(dbg_on) && dbg_on(DBG_FLOW)) {
       dbg_log(DBG_FLOW, "PASTE: received " + string(array_length(lines)) + " raw lines");
    }

    for (var i = 0; i < array_length(lines); i++) {
        var line = string_trim(lines[i]);
        if (string_length(line) == 0) continue;

        var space_pos = string_pos(" ", line);
        if (space_pos <= 0) continue;

        var line_num_str = string_copy(line, 1, space_pos - 1);
        var code_str     = string_copy(line, space_pos + 1, string_length(line) - space_pos);

        if (string_length(code_str) > 0 && string_char_at(code_str, string_length(code_str)) == chr(13)) {
            code_str = string_copy(code_str, 1, string_length(code_str) - 1);
        }

        if (string_digits(line_num_str) != line_num_str) continue;

        var line_num = real(line_num_str);
        if (line_num <= 0 || string_length(code_str) <= 0) continue;

        basic_program_set_line(line_num, code_str, false);

        if (function_exists(dbg_on) && dbg_on(DBG_FLOW)) {
           dbg_log(DBG_FLOW, "PASTE: set " + string(line_num) + " → '" + code_str + "'");
        }

        applied = true;
    }

    if (applied) {
        basic_program_rebuild_index_map();
        basic_show_message("Program pasted successfully.");
    } else {
        show_message("Clipboard is empty or not in '<line> <code>' format.");
    }
    return applied;
}