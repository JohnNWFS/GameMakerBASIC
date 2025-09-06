/// handle_interpreter_character_input(key)
/// Processes editor keystrokes while awaiting BASIC INPUT.
/// Assumes helpers basic_normvar(name) and basic_looks_numeric(s) exist,
/// and global.basic_variables (ds_map) is initialized.
function handle_interpreter_character_input(key) {
    // --- PRINTABLE ASCII (uses keyboard_lastchar) ---
    if (key >= 32 && key <= 126) {
        var ch = string(keyboard_lastchar); // ensure string
        if (string_length(ch) > 0) {
            global.interpreter_input = string_insert(ch, global.interpreter_input, global.interpreter_cursor_pos + 1);
            global.interpreter_cursor_pos += 1;
        }
        return;
    }

    // --- BACKSPACE ---
    if (key == vk_backspace) {
        if (global.interpreter_cursor_pos > 0) {
            // Delete the character just to the left of the cursor
            global.interpreter_input = string_delete(global.interpreter_input, global.interpreter_cursor_pos, 1);
            global.interpreter_cursor_pos -= 1;
        }
        return;
    }

    // --- SPACE ---
    if (key == vk_space) {
        global.interpreter_input = string_insert(" ", global.interpreter_input, global.interpreter_cursor_pos + 1);
        global.interpreter_cursor_pos += 1;
        return;
    }

    // --- LEFT ARROW ---
    if (key == vk_left) {
        if (global.interpreter_cursor_pos > 0) {
            global.interpreter_cursor_pos -= 1;
        }
        return;
    }

    // --- RIGHT ARROW ---
    if (key == vk_right) {
        if (global.interpreter_cursor_pos < string_length(global.interpreter_input)) {
            global.interpreter_cursor_pos += 1;
        }
        return;
    }

    // --- ENTER: finalize INPUT and resume execution ---
    if (key == vk_enter) {
        var raw = string_trim(string(global.interpreter_input));
        var k   = basic_normvar(global.input_target_var);

        // String var if the normalized name ends with '$'
        var ends_with_dollar = (string_length(k) > 0) && (string_char_at(k, string_length(k)) == "$");

        var val;
        if (ends_with_dollar) {
            // String variable: commit exactly what the user typed
            val = raw;
        } else {
            // Numeric variable: only accept numeric-looking input (prevents silent 0 bugs)
            if (basic_looks_numeric(raw)) {
                val = real(raw);
            } else {
                // Stay in input mode; do not commit or advance
                if (!is_undefined(global.DEBUG_INPUT) && global.DEBUG_INPUT) {
                    show_debug_message("[INPUT] Type mismatch for " + k + " got '" + raw + "'. Still waiting.");
                }
                return;
            }
        }

        // Store under canonical key
        global.basic_variables[? k] = val;

        if (!is_undefined(global.DEBUG_INPUT) && global.DEBUG_INPUT) {
            show_debug_message("[INPUT] commit " + k + " <= '" + string(val) + "'");
        }

        // --- Post-commit housekeeping (keep these consistent with your existing flow) ---
        // Clear the input buffer and cursor
        global.interpreter_input      = "";
        global.interpreter_cursor_pos = 0;

        // Clear input mode flags/targets
        global.awaiting_input   = false;
        global.input_target_var = "";

        // If you echo the entered line to your output, do it here (optional):
        // ds_list_add(global.output_lines, string(val));
        // ds_list_add(global.output_colors, global.current_draw_color);

        return;
    }

    // (Optional) HOME / END support
    // if (key == vk_home) { global.interpreter_cursor_pos = 0; return; }
    // if (key == vk_end)  { global.interpreter_cursor_pos = string_length(global.interpreter_input); return; }
}
