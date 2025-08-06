// obj_basic_interpreter → Step Event

// Sort program lines in ascending order
if (ds_exists(global.line_list, ds_type_list)) {
    ds_list_sort(global.line_list, true);
}

// === Program Ended: Wait for user action ===
if (global.program_has_ended) {
    if (keyboard_check_pressed(vk_pageup)) {
        global.scroll_offset = max(global.scroll_offset - 1, 0);
    }
    if (keyboard_check_pressed(vk_pagedown)) {
        var font_height = string_height("A");
        var visible_lines = floor(room_height / font_height) - 2;
        var total_lines = ds_list_size(global.output_lines);
        global.scroll_offset = min(global.scroll_offset + 1, max(0, total_lines - visible_lines));
    }

    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape)) {
        global.program_has_ended = false;
        global.current_mode = 0;  
        room_goto(global.editor_return_room);
    }
    return;
}

// === Handle INPUT or PAUSE ===
if (global.awaiting_input) {
    if (global.pause_mode) {
        if (keyboard_check_pressed(vk_enter)) {
            global.awaiting_input = false;
            global.pause_mode = false;
            global.input_target_var = "";
            global.interpreter_input = "";
        }
    } else {
        for (var k = 32; k <= 126; k++) {
            if (keyboard_check_pressed(k)) handle_interpreter_character_input(k);
        }
        if (keyboard_check_pressed(vk_enter)) handle_interpreter_character_input(vk_enter);
        if (keyboard_check_pressed(vk_backspace)) handle_interpreter_character_input(vk_backspace);
    }
    return;
}

// === Synchronize for structured IF…ELSE handling ===
// Ensure handlers read the correct current line index
global.interpreter_current_line_index = line_index;

// === Handle IF/GOTO Jump ===
if (global.interpreter_next_line >= 0) {
    line_index = global.interpreter_next_line;
    global.interpreter_current_line_index = global.interpreter_next_line;
    global.interpreter_next_line = -1;
}

// === End of Program Check ===
if (line_index >= ds_list_size(global.line_list)) {
    global.interpreter_running = false;
}

// === Execute BASIC Line ===
if (line_index < ds_list_size(global.line_list)) {
    var line_number = ds_list_find_value(global.line_list, line_index);
    var code = ds_map_find_value(global.program_map, line_number);
    var trimmed = string_trim(code);
    var sp = string_pos(" ", trimmed);
    var cmd = (sp > 0) ? string_upper(string_copy(trimmed, 1, sp - 1)) : string_upper(trimmed);
    var arg = (sp > 0) ? string_trim(string_copy(trimmed, sp + 1, string_length(trimmed))) : "";

    global.current_line_number = line_number;
    show_debug_message("Running line " + string(line_number));
    show_debug_message("Command: " + cmd + " | Arg: " + arg);

    // Dispatch to the command handlers (including IF/ELSEIF/ELSE/ENDIF)
    handle_basic_command(cmd, arg);

    // If no jump was requested, advance to next line
    if (global.interpreter_next_line < 0) {
        line_index++;
    }
} else {
    global.interpreter_running = false;
}

// === Escape Returns to Editor ===
if (keyboard_check_pressed(vk_escape)) {
    global.current_mode = 0;
    room_goto(global.editor_return_room);
}

// === F5 Dumps BASIC to Console ===
if (keyboard_check_released(vk_f5) && basic_run_to_console_flag == false) {
    basic_run_to_console_flag = true;
    basic_run_to_console();
}

// === Manual Scroll (Always Available) ===
if (keyboard_check_pressed(vk_pageup)) {
    global.scroll_offset = max(global.scroll_offset - 1, 0);
}
if (keyboard_check_pressed(vk_pagedown)) {
    var font_height = string_height("A");
    var visible_lines = floor(room_height / font_height) - 2;
    var total_lines = ds_list_size(global.output_lines) + (global.awaiting_input ? 1 : 0);
    global.scroll_offset = min(global.scroll_offset + 1, max(0, total_lines - visible_lines));
}
