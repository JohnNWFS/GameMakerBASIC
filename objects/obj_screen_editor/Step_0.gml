/// @file objects/obj_screen_editor/Step_0.gml
/// @event Step
/// Final corrected horizontal scrolling implementation

// Handle ESC key - exit screen editor
if (keyboard_check_pressed(vk_escape)) {
    show_debug_message("SCREEN_EDITOR: ESC pressed - exiting");
    screen_editor_exit(id);
    exit;
}

// Initialize line_modified flag if it doesn't exist
if (!variable_instance_exists(id, "line_modified")) {
    line_modified = false;
}

// Initialize key repeat timer for smoother arrow key movement
if (!variable_instance_exists(id, "arrow_repeat_timer")) {
    arrow_repeat_timer = 0;
}

// Handle cursor movement with horizontal scrolling
if (keyboard_check(vk_left)) {
    if (arrow_repeat_timer <= 0) {
        if (cursor_x > 0) {
            cursor_x--;
        } else if (horizontal_offset > 0) {
            // At left edge of screen, scroll left
            horizontal_offset--;
            screen_editor_load_program(id);
            show_debug_message("SCREEN_EDITOR: Scrolled left - new h_offset=" + string(horizontal_offset));
        }
        show_debug_message("SCREEN_EDITOR: Cursor left to (" + string(cursor_x) + "," + string(cursor_y) + "), h_offset=" + string(horizontal_offset));
        arrow_repeat_timer = 4; // 4-frame delay between movements
    }
}

if (keyboard_check(vk_right)) {
    if (arrow_repeat_timer <= 0) {
        // Get the FULL line content directly from program storage, not from screen buffer
        var line_index = cursor_y + scroll_offset;
        var full_line_text = "";
        
        if (line_index < ds_list_size(global.line_numbers)) {
            var line_num = ds_list_find_value(global.line_numbers, line_index);
            var code = ds_map_find_value(global.program_lines, line_num);
            full_line_text = string(line_num) + " " + code;
        }
        
        var actual_cursor_pos = cursor_x + horizontal_offset;
        var full_line_length = string_length(full_line_text);
        
        show_debug_message("SCREEN_EDITOR: Right arrow - cursor_x=" + string(cursor_x) + ", h_offset=" + string(horizontal_offset) + ", actual_pos=" + string(actual_cursor_pos) + ", full_line_len=" + string(full_line_length));
        
        // Allow scrolling through the entire line content
        if (actual_cursor_pos < full_line_length && actual_cursor_pos < 200) {
            if (cursor_x < 79) {  // Use 79 for your 80-character screen
                cursor_x++;
            } else {
                // At right edge of screen, scroll right
                horizontal_offset++;
                screen_editor_load_program(id);
                show_debug_message("SCREEN_EDITOR: Scrolled right - new h_offset=" + string(horizontal_offset));
            }
        }
        show_debug_message("SCREEN_EDITOR: After right - cursor(" + string(cursor_x) + "," + string(cursor_y) + "), h_offset=" + string(horizontal_offset));
        arrow_repeat_timer = 4; // 4-frame delay between movements
    }
}

// Decrement the arrow key repeat timer
if (arrow_repeat_timer > 0) {
    arrow_repeat_timer--;
}

if (keyboard_check_pressed(vk_up)) {
    // If current line was modified, commit it first
    if (line_modified) {
        screen_editor_commit_row(id, cursor_y);
        line_modified = false;
        show_debug_message("SCREEN_EDITOR: Auto-committed modified line before moving up");
    }
    
    // Store the desired horizontal position
    var desired_x = cursor_x + horizontal_offset;
    
    // Clear ALL keyboard input to prevent character leakage
    keyboard_string = "";
    keyboard_lastchar = "";
    keyboard_lastkey = 0;
    
    // Reset horizontal scrolling - always show left edge of new line
    horizontal_offset = 0;
    
    if (cursor_y > 0) {
        cursor_y--;
    } else if (scroll_offset > 0) {
        scroll_offset--;
        screen_editor_load_program(id);
        show_debug_message("SCREEN_EDITOR: Scrolled up - scroll_offset=" + string(scroll_offset));
    }
    
    // Smart cursor positioning for new line
    var new_line_text = screen_editor_get_row_text(id, cursor_y);
    var new_line_length = string_length(new_line_text);
    var target_pos = min(desired_x, new_line_length);
    cursor_x = min(target_pos, 79);
    
    screen_editor_load_program(id);
    show_debug_message("SCREEN_EDITOR: Up - cursor(" + string(cursor_x) + "," + string(cursor_y) + "), cleared input");
}

if (keyboard_check_pressed(vk_down)) {
    // If current line was modified, commit it first
    if (line_modified) {
        screen_editor_commit_row(id, cursor_y);
        line_modified = false;
        show_debug_message("SCREEN_EDITOR: Auto-committed modified line before moving down");
    }
    
    // Store the desired horizontal position
    var desired_x = cursor_x + horizontal_offset;
    
    // Clear ALL keyboard input to prevent character leakage
    keyboard_string = "";
    keyboard_lastchar = "";
    keyboard_lastkey = 0;
    
    // Reset horizontal scrolling - always show left edge of new line
    horizontal_offset = 0;
    
    var total_lines = ds_list_size(global.line_numbers);
    var visible_lines = min(screen_rows, total_lines - scroll_offset);
    
    if (cursor_y < visible_lines - 1 && cursor_y < screen_rows - 1) {
        cursor_y++;
    } else if (scroll_offset + screen_rows < total_lines) {
        scroll_offset++;
        screen_editor_load_program(id);
        show_debug_message("SCREEN_EDITOR: Scrolled down - scroll_offset=" + string(scroll_offset));
    }
    
    // Smart cursor positioning for new line
    var new_line_text = screen_editor_get_row_text(id, cursor_y);
    var new_line_length = string_length(new_line_text);
    var target_pos = min(desired_x, new_line_length);
    cursor_x = min(target_pos, 79);
    
    screen_editor_load_program(id);
    show_debug_message("SCREEN_EDITOR: Down - cursor(" + string(cursor_x) + "," + string(cursor_y) + "), cleared input");
}

// Handle Page Up/Down
if (keyboard_check_pressed(vk_pageup)) {
    var old_offset = scroll_offset;
    scroll_offset = max(0, scroll_offset - screen_rows);
    if (scroll_offset != old_offset) {
        horizontal_offset = 0;
        cursor_x = min(cursor_x, 79);
        screen_editor_load_program(id);
        show_debug_message("SCREEN_EDITOR: Page Up - scroll_offset " + string(old_offset) + " -> " + string(scroll_offset));
    }
}

if (keyboard_check_pressed(vk_pagedown)) {
    var old_offset = scroll_offset;
    var total_lines = ds_list_size(global.line_numbers);
    scroll_offset = min(max(0, total_lines - screen_rows), scroll_offset + screen_rows);
    if (scroll_offset != old_offset) {
        horizontal_offset = 0;
        cursor_x = min(cursor_x, 79);
        screen_editor_load_program(id);
        show_debug_message("SCREEN_EDITOR: Page Down - scroll_offset " + string(old_offset) + " -> " + string(scroll_offset));
    }
}

// Home/End key support
if (keyboard_check_pressed(vk_home)) {
    cursor_x = 0;
    horizontal_offset = 0;
    screen_editor_load_program(id);
    show_debug_message("SCREEN_EDITOR: Home pressed - jump to beginning");
}

if (keyboard_check_pressed(vk_end)) {
    var current_line_text = screen_editor_get_row_text(id, cursor_y);
    var line_length = string_length(current_line_text);
    
    if (line_length <= 80) {
        // Line fits on screen
        cursor_x = line_length;
        horizontal_offset = 0;
    } else {
        // Line is longer - scroll to show the end
        horizontal_offset = line_length - 80;
        cursor_x = 79;
    }
    
    screen_editor_load_program(id);
    show_debug_message("SCREEN_EDITOR: End pressed - jump to end, cursor=" + string(cursor_x) + ", h_offset=" + string(horizontal_offset));
}


// Character input
if (keyboard_check_pressed(vk_anykey)) {
    var k  = keyboard_lastkey;
    var ch = keyboard_lastchar;

    // Is this a printable keystroke (not pure modifier / not control)?
    var _is_printable =
        (k != vk_shift && k != vk_control && k != vk_alt) &&
        (!is_undefined(ch)) && (ch != "") && (ord(ch) >= 32);

    // CRITICAL: Ignore arrow keys and other navigation keys to prevent interference
    var _is_nav =
        keyboard_check(vk_left) || keyboard_check(vk_right) ||
        keyboard_check(vk_up)   || keyboard_check(vk_down)  ||
        keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right) ||
        keyboard_check_pressed(vk_up)   || keyboard_check_pressed(vk_down)  ||
        keyboard_check_pressed(vk_home) || keyboard_check_pressed(vk_end)   ||
        keyboard_check_pressed(vk_pageup) || keyboard_check_pressed(vk_pagedown) ||
        keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_backspace) ||
        keyboard_check_pressed(vk_escape);

    // Only run the INSERT path for printable, non-nav keys.
    if (_is_printable && !_is_nav) {

        if (string_length(ch) == 1) {
            var ascii_code = ord(ch);
            show_debug_message("SCREEN_EDITOR: Key pressed - char '" + ch + "', ASCII " + string(ascii_code));

            if (ascii_code >= 32 && ascii_code <= 126) {
                var current_line_text = screen_editor_get_row_text(id, cursor_y);
                var actual_cursor_pos = cursor_x + horizontal_offset;

                // Preserve intentional trailing spaces up to cursor (since get_row_text trims)
                if (string_length(current_line_text) < actual_cursor_pos) {
                    var pad = actual_cursor_pos - string_length(current_line_text);
                    repeat (pad) { current_line_text += " "; }
                }

                if (string_length(current_line_text) < 200) {
                    // Insert character at actual position
                    var before_cursor = string_copy(current_line_text, 1, actual_cursor_pos);
                    var after_cursor  = string_copy(current_line_text, actual_cursor_pos + 1, string_length(current_line_text));
                    var new_line      = before_cursor + ch + after_cursor;

                    // Update the actual BASIC program line
                    var line_index = cursor_y + scroll_offset;
                    if (line_index < ds_list_size(global.line_numbers)) {
                        var line_num  = ds_list_find_value(global.line_numbers, line_index);
                        var space_pos = string_pos(" ", new_line);
                        if (space_pos > 0) {
                            var code_part = string_copy(new_line, space_pos + 1, string_length(new_line));
                            ds_map_set(global.program_lines, line_num, code_part);
                        }
                    }

                    // Mark line as modified
                    line_modified = true;

                    // Advance cursor
                    if (cursor_x < 79) {
                        cursor_x++;
                    } else {
                        horizontal_offset++;
                    }

                    screen_editor_load_program(id);
                    // keep the live edit visible even if this is a not-yet-committed/new line
                    screen_editor_display_line(id, new_line, cursor_y);

                } else {
                    basic_show_message("Line too long (max 200 chars)");
                }
            }
        }
    }
    // IMPORTANT: do not exit here — lets Enter/Backspace handlers run later in Step
}



// Backspace
if (keyboard_check_pressed(vk_backspace)) {
    var current_line_text = screen_editor_get_row_text(id, cursor_y);
    var actual_cursor_pos = cursor_x + horizontal_offset;
	
	// ADD this padding block (so backspace can delete spaces you just typed):
	if (string_length(current_line_text) < actual_cursor_pos) {
	    var pad = actual_cursor_pos - string_length(current_line_text);
	    repeat (pad) { current_line_text += " "; }
	}
    
    if (actual_cursor_pos > 0) {
        // Delete character
        var before_cursor = string_copy(current_line_text, 1, actual_cursor_pos - 1);
        var after_cursor = string_copy(current_line_text, actual_cursor_pos + 1, string_length(current_line_text));
        var new_line = before_cursor + after_cursor;
        
        // Update program line
        var line_index = cursor_y + scroll_offset;
        if (line_index < ds_list_size(global.line_numbers)) {
            var line_num = ds_list_find_value(global.line_numbers, line_index);
            var space_pos = string_pos(" ", new_line);
            if (space_pos > 0) {
                var code_part = string_copy(new_line, space_pos + 1, string_length(new_line));
                ds_map_set(global.program_lines, line_num, code_part);
            }
        }
        
        // Mark line as modified
        line_modified = true;
        
        // Move cursor back
        if (cursor_x > 0) {
            cursor_x--;
        } else if (horizontal_offset > 0) {
            horizontal_offset--;
        }
        
        screen_editor_load_program(id);
		
		// re-assert the edited row on screen after the reload
		screen_editor_display_line(id, new_line, cursor_y);
    }
}

// Enter key
if (keyboard_check_pressed(vk_enter)) {
    show_debug_message("SCREEN_EDITOR: Enter pressed - committing row " + string(cursor_y));
    screen_editor_commit_row(id, cursor_y);
    
    horizontal_offset = 0;
    cursor_x = 0;
    
    screen_editor_load_program(id);
    
    if (cursor_y < screen_rows - 1) {
        cursor_y++;
    }
}

// Cursor blink
blink_timer++;
if (blink_timer >= 30) {
    cursor_visible = !cursor_visible;
    blink_timer = 0;
}