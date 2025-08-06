if (global.justreturned == 1) {
    current_input = "";
    cursor_pos = 0;
    keyboard_string = "";
    global.justreturned = 0;
    exit; // skip the rest of this Step event
}

if (showing_dir_overlay) {
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape)) {
        showing_dir_overlay = false;
        dir_listing = []; // Clear the array
    }
    exit; // prevent editor interaction while overlay is up
}




// Handle Enter key
if (keyboard_check_pressed(vk_enter)) {
    add_to_history(current_input);
    process_input_line(current_input);
    current_input = "";
    cursor_pos = 0;
    global.history_index = -1;
    input_buffer = keyboard_string; // reset keyboard buffer
}

 else if (keyboard_check_released(vk_backspace)) {
    if (cursor_pos > 0) {
        current_input = string_delete(current_input, cursor_pos, 1);
        cursor_pos--;
    }
 }
 else if (keyboard_check_pressed(vk_left)) {
    cursor_pos = max(0, cursor_pos - 1);
 }
 else if (keyboard_check_pressed(vk_right)) {
    cursor_pos = min(string_length(current_input), cursor_pos + 1);
 }
 else if (keyboard_check_pressed(vk_up)) {
    navigate_history_up();
 }
 else if (keyboard_check_pressed(vk_down)) {
    navigate_history_down();
 }
 else if (keyboard_check_pressed(vk_pageup)) {
    display_start_line = max(0, display_start_line - lines_per_screen);
 }
 else if (keyboard_check_pressed(vk_pagedown)) {
    var max_start = max(0, ds_list_size(global.line_numbers) - lines_per_screen);
    display_start_line = min(max_start, display_start_line + lines_per_screen);
 }
 else if (keyboard_check(vk_control) && keyboard_check_pressed(ord("Z"))) {
    undo_last_change();
 }
 else if (keyboard_check(vk_f5)) {
    dump_program_to_console();
	basic_show_message("Dumped program to Console");	 
 }
 else {
    // Handle character input with repeat
    handle_character_input();
 }
 
  // In Step Event
 if (message_timer > 0) {
    message_timer--;
    if (message_timer <= 0) {
        message_text = "";
    }
 }
 
/*  // Add to Step event
 if (drag_enabled && drag_files > 0) {
    var file_path = drag_file[0];
    if (string_pos(".bas", string_lower(file_path)) > 0) {
        // Extract filename without path and extension
        var filename_start = 1;
        for (var i = string_length(file_path); i >= 1; i--) {
            if (string_char_at(file_path, i) == "/" || string_char_at(file_path, i) == "\\") {
                filename_start = i + 1;
                break;
            }
        }
        var full_filename = string_copy(file_path, filename_start, string_length(file_path));
        var dot_pos = string_pos(".", full_filename);
        var filename = string_copy(full_filename, 1, dot_pos - 1);
        
        load_program_from_path(file_path, filename);
    }
    drag_clear();
 }

*/
