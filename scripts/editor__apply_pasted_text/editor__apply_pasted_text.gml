/// FILE: scripts/editor__apply_pasted_text.gml
/// @function editor__apply_pasted_text(text)
/// @desc Parses BASIC lines from `text` and mutates global.program_lines/global.line_numbers.
/// @returns {bool} true if at least one line was applied; false otherwise
function editor__apply_pasted_text(text) {
    if (is_undefined(text) || string_length(text) <= 0) {
        show_message("Clipboard is empty.");
        return false;
    }

    var applied = false;
    var lines = string_split(text, "\n");
    if (function_exists(dbg_on) && dbg_on(DBG_FLOW)) {
        show_debug_message("PASTE: received " + string(array_length(lines)) + " raw lines");
    }

    for (var i = 0; i < array_length(lines); i++) {
        var line = string_trim(lines[i]);
        if (string_length(line) == 0) continue;

        var space_pos = string_pos(" ", line);
        if (space_pos <= 0) continue;

        var line_num_str = string_copy(line, 1, space_pos - 1);
        var code_str     = string_copy(line, space_pos + 1, string_length(line) - space_pos);

        // Strip trailing CR in CRLF cases
        if (string_length(code_str) > 0 && string_char_at(code_str, string_length(code_str)) == chr(13)) {
            code_str = string_copy(code_str, 1, string_length(code_str) - 1);
        }

        // Validate line number is digits-only
        if (string_digits(line_num_str) != line_num_str) continue;

        var line_num = real(line_num_str);
        if (line_num <= 0 || string_length(code_str) <= 0) continue;

        // Insert/replace in program_lines
        ds_map_set(global.program_lines, line_num, code_str);

        if (function_exists(dbg_on) && dbg_on(DBG_FLOW)) {
            show_debug_message("PASTE: set " + string(line_num) + " → '" + code_str + "'");
        }

        // Maintain ordered list of line numbers
        var idx = ds_list_find_index(global.line_numbers, line_num);
        if (idx == -1) {
            ds_list_add(global.line_numbers, line_num);
            ds_list_sort(global.line_numbers, true);
            if (function_exists(dbg_on) && dbg_on(DBG_FLOW)) {
                show_debug_message("PASTE: added line number " + string(line_num));
            }
        } else if (function_exists(dbg_on) && dbg_on(DBG_FLOW)) {
            show_debug_message("PASTE: updated existing line number " + string(line_num) + " (idx=" + string(idx) + ")");
        }

        applied = true;
    }

    if (applied) {
        basic_show_message("Program pasted successfully.");
    } else {
        // Nothing matched the `<num> <code>` pattern; keep parity with Windows behavior:
        // do not show success if nothing was applied.
        show_message("Clipboard is empty or not in '<line> <code>' format.");
    }
    return applied;
}
