/// Handles a single virtual key press from obj_mobile_kb.
/// Caps/shift state lives on obj_mobile_kb; input state lives on obj_editor.
function mobile_kb_handle_key(key) {
    var _kb = id;  // keyboard instance that received the tap

    if (key == "CAPS") {
        _kb.kb_caps  = !_kb.kb_caps;
        _kb.kb_shift = false;
        exit;
    }
    if (key == "SHIFT") {
        _kb.kb_shift = !_kb.kb_shift;
        exit;
    }

    var _send = key;
    if (string_length(key) == 1 && key >= "A" && key <= "Z") {
        var _lower = _kb.kb_caps ? !_kb.kb_shift : _kb.kb_shift;
        _send = _lower ? string_lower(key) : key;
        if (_kb.kb_shift) _kb.kb_shift = false;
    }

    // Editor room: edit the READY prompt directly.
    if (instance_exists(obj_editor)) with (obj_editor) {
        switch (key) {
            case "ENTER":
                add_to_history(current_input);
                process_input_line(current_input);
                current_input = "";
                cursor_pos    = 0;
                global.history_index = -1;
                break;

            case "BACKSPACE":
                if (cursor_pos > 0) {
                    current_input = string_delete(current_input, cursor_pos, 1);
                    cursor_pos--;
                }
                break;

            case "ESC":
                current_input = "";
                cursor_pos    = 0;
                break;

            case "CLR":
                current_input = "";
                cursor_pos    = 0;
                break;

            case "LEFT":
                cursor_pos = max(0, cursor_pos - 1);
                break;

            case "RIGHT":
                cursor_pos = min(string_length(current_input), cursor_pos + 1);
                break;

            case "SPACE":
                var _b = string_copy(current_input, 1, cursor_pos);
                var _a = string_copy(current_input, cursor_pos + 1, string_length(current_input) - cursor_pos);
                current_input = _b + " " + _a;
                cursor_pos++;
                break;

            case "F1": process_input_line("LIST");   break;
            case "F2": process_input_line("RUN");    break;
            case "F3":
                current_input = "NEW";
                cursor_pos    = string_length(current_input);
                break;
            case "F4": process_input_line("DIR");    break;
            case "F5": process_input_line(":DEMOS"); break;

            default:
                if (string_length(key) == 1) {
                    var _before = string_copy(current_input, 1, cursor_pos);
                    var _after  = string_copy(current_input, cursor_pos + 1, string_length(current_input) - cursor_pos);
                    current_input = _before + _send + _after;
                    cursor_pos++;
                }
                break;
        }
        exit;
    }

    // Interpreter rooms: feed INPUT, PAUSE, INKEY$, and end-of-program controls.
    if (global.program_has_ended) {
        if (key == "ENTER" || key == "ESC") {
            if (variable_global_exists("help_active") && global.help_active) {
                help_restore_program();
                global.help_active = false;
            }
            global.program_has_ended = false;
            global.current_mode = 0;
            var _ret = variable_global_exists("editor_return_room") ? global.editor_return_room : room_first;
            room_goto(_ret);
        }
        exit;
    }

    if (global.awaiting_input) {
        if (global.pause_mode) {
            if (key == "ENTER" || key == "ESC") {
                global.awaiting_input   = false;
                global.pause_mode       = false;
                global.pause_in_effect  = false;
                global.input_target_var = "";
                global.interpreter_input = "";
                global.interpreter_resume_stmt_index = global.interpreter_current_stmt_index + 1;
            }
            exit;
        }

        switch (key) {
            case "ENTER":
                var _name = basic_normvar(global.input_target_var);
                var _val  = global.interpreter_input;
                var _val_trim = string_trim(string(_val));

                if (string_length(_name) > 0 && string_char_at(_name, string_length(_name)) == "$") {
                    global.basic_variables[? _name] = _val;
                } else {
                    if (is_numeric_string(_val_trim)) global.basic_variables[? _name] = real(_val_trim);
                    else global.basic_variables[? _name] = _val;
                }

                var _echo = (global.input_show_qmark ? "? " : global.input_prompt) + _val;
                basic_output_commit(_echo, global.basic_text_color);

                global.awaiting_input    = false;
                global.input_expected    = false;
                global.input_target_var  = "";
                global.input_prompt      = "";
                global.input_show_qmark  = true;
                global.interpreter_input = "";
                global.interpreter_cursor_pos = 0;
                global.input_ignore_enter_until_release = false;
                global.input_guard_frames = 0;
                break;

            case "BACKSPACE":
                if (global.interpreter_cursor_pos > 0) {
                    global.interpreter_input = string_delete(global.interpreter_input, global.interpreter_cursor_pos, 1);
                    global.interpreter_cursor_pos--;
                }
                break;

            case "ESC":
            case "CLR":
                global.interpreter_input = "";
                global.interpreter_cursor_pos = 0;
                break;

            case "LEFT":
                global.interpreter_cursor_pos = max(0, global.interpreter_cursor_pos - 1);
                break;

            case "RIGHT":
                global.interpreter_cursor_pos = min(string_length(global.interpreter_input), global.interpreter_cursor_pos + 1);
                break;

            case "SPACE":
                global.interpreter_input = string_insert(" ", global.interpreter_input, global.interpreter_cursor_pos + 1);
                global.interpreter_cursor_pos++;
                break;

            default:
                if (string_length(_send) == 1) {
                    global.interpreter_input = string_insert(_send, global.interpreter_input, global.interpreter_cursor_pos + 1);
                    global.interpreter_cursor_pos++;
                }
                break;
        }
        exit;
    }

    if (!variable_global_exists("__inkey_queue") || !ds_exists(global.__inkey_queue, ds_type_queue)) {
        global.__inkey_queue = ds_queue_create();
    }

    if (key == "ENTER") {
        inkey_enq(chr(13), 10);
    } else if (key == "ESC") {
        global.current_mode = 0;
        if (variable_global_exists("editor_return_room")) room_goto(global.editor_return_room);
    } else if (string_length(_send) == 1) {
        inkey_enq(_send, 10);
    }
}
