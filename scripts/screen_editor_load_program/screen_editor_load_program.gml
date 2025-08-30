// FILE: scripts/screen_editor_load_program/screen_editor_load_program.gml
/// @function screen_editor_load_program(editor_inst)
function screen_editor_load_program(editor_inst) {
    with (editor_inst) {
        //show_debug_message("SCREEN_EDITOR: Loading program to screen (scroll_offset=" + string(scroll_offset) + ")");
        
        // Clear screen first
        for (var i = 0; i < array_length(screen_buffer); i++) {
            screen_buffer[i] = ord(" ");
        }
        
        // Load program lines with scroll offset
        var total_lines = ds_list_size(global.line_numbers);
        var screen_row = 0;
        
        // Start from scroll_offset instead of 0
		for (var i = scroll_offset; i < total_lines && screen_row < screen_rows; i++) {
		    var line_num = ds_list_find_value(global.line_numbers, i);
		    var code = ds_map_find_value(global.program_lines, line_num);
		    var line_text = string(line_num) + " " + code;
    
		    // Apply horizontal offset ONLY to the current cursor line
		    var display_text = line_text;
		if (screen_row == cursor_y && horizontal_offset > 0) {
		    // Only scroll the line where the cursor currently is
		    display_text = string_copy(line_text, horizontal_offset + 1, screen_cols);
		    //show_debug_message("SCREEN_EDITOR: Applying h_offset=" + string(horizontal_offset) + " to cursor line " + string(cursor_y));
		}
            
		// Place line text on screen
		var text_len = min(string_length(display_text), screen_cols);  // Use display_text
		for (var j = 1; j <= text_len; j++) {
		    var ch = string_char_at(display_text, j);  // Use display_text
		    screen_editor_set_char_at(id, j - 1, screen_row, ord(ch));
		}
            
            screen_row++;
        }
        
        //show_debug_message("SCREEN_EDITOR: Loaded " + string(screen_row) + " lines starting from offset " + string(scroll_offset));
    }
}