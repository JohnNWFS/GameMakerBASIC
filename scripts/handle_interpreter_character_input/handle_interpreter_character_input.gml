function handle_interpreter_character_input(key) {
    // Printable ASCII characters
    if (key >= 32 && key <= 126) {
        var ch = keyboard_lastchar;

        global.interpreter_input = string_insert(ch, global.interpreter_input, global.interpreter_cursor_pos + 1);
        global.interpreter_cursor_pos += 1;
        return;
    }

    // BACKSPACE
    if (key == vk_backspace) {
        if (global.interpreter_cursor_pos > 0) {
            global.interpreter_input = string_delete(global.interpreter_input, global.interpreter_cursor_pos, 1);
            global.interpreter_cursor_pos -= 1;
        }
        return;
    }

    // SPACE
    if (key == vk_space) {
        global.interpreter_input = string_insert(" ", global.interpreter_input, global.interpreter_cursor_pos + 1);
        global.interpreter_cursor_pos += 1;
        return;
    }

    // LEFT arrow
    if (key == vk_left) {
        if (global.interpreter_cursor_pos > 0) {
            global.interpreter_cursor_pos -= 1;
        }
        return;
    }

    // RIGHT arrow
    if (key == vk_right) {
        if (global.interpreter_cursor_pos < string_length(global.interpreter_input)) {
            global.interpreter_cursor_pos += 1;
        }
        return;
    }

    // ENTER — finalize the input and resume execution
    if (key == vk_enter) {
        var val = global.interpreter_input;
        var varname = string_upper(global.input_target_var);

        // Store in variable map
        global.basic_variables[? varname] = val;

        // Echo to output
       // ds_list_add(output_lines, val);
       // ds_list_add(global.output_colors, global.current_draw_color);

        // Reset input state
        global.interpreter_input = "";
        global.awaiting_input = false;
        global.input_target_var = "";
        global.interpreter_cursor_pos = 0;
    }
}
