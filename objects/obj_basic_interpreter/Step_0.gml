// obj_basic_interpreter Step Event

if (global.program_has_ended) {
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape)) {
        global.program_has_ended = false;
        room_goto(global.editor_return_room);
    }
	//show_debug_message("In the ended block");
	return;
}



// Handle live user input for INPUT command
if (global.interpreter_running) {
    if (global.awaiting_input) {
        for (var k = 32; k <= 126; k++) {
            if (keyboard_check_pressed(k)) {
                show_debug_message("KEY PRESSED: " + string(k));
                handle_interpreter_character_input(k);
            }
        }
        if (keyboard_check_pressed(vk_enter)) {
            show_debug_message("ENTER PRESSED");
            handle_interpreter_character_input(vk_enter);
        }
        if (keyboard_check_pressed(vk_backspace)) {
            show_debug_message("BACKSPACE PRESSED");
            handle_interpreter_character_input(vk_backspace);
        }
        exit;
    }
}

// Handle GOTO jumps from IF/GOTO commands
if (interpreter_next_line >= 0) {
    line_index = interpreter_next_line;
    interpreter_next_line = -1;
}

if (line_index >= ds_list_size(global.line_list)) {
    interpreter_next_line = -1;
    global.interpreter_running = false;
}


// Execute current line using your existing system

if (line_index < ds_list_size(global.line_list)) {
    var ln1 = ds_list_find_value(global.line_list, line_index);
    var code = ds_map_find_value(global.program_map, ln1);
    var trimmed = string_trim(code);
    var sp = string_pos(" ", trimmed); 
    var cmd = (sp > 0) ? string_upper(string_copy(trimmed, 1, sp - 1)) : string_upper(trimmed);
    var arg = (sp > 0) ? string_trim(string_copy(trimmed, sp + 1, string_length(trimmed))) : "";
    // Support for apostrophe shorthand (') as REM
	//if (string_copy(trimmed, 1, 1) == "'") {
	//    cmd = "REM";
	 //   arg = string_delete(trimmed, 1, 1); // Remove the apostrophe
	//}

    handle_basic_command(cmd, arg); // dispatch command
    
    // Only advance if GOTO didn't happen via the new system
    if (interpreter_next_line < 0) {
        line_index++;
    }
} else {
    // Finished execution
    global.interpreter_running = false;
}

// Escape returns to editor immediately
if (keyboard_check_pressed(vk_escape)) {
    room_goto(global.editor_return_room);
}

// F5 dumps BASIC to console
if (keyboard_check_released(vk_f5)) {
    basic_run_to_console();
}

