/// @description Insert description here
// You can write your code in this editor
 // In Draw Event
 draw_set_font(fnt_basic); // Create a monospace font
 draw_set_color(make_color_rgb(255, 191, 64));  // Classic green text
 draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
 // Draw program lines
 var y_pos = 32;
 var lines_shown = 0;
 var total_lines = ds_list_size(global.line_numbers);
 for (var i = display_start_line; i < total_lines && lines_shown < lines_per_screen; i++) {
    var line_num = ds_list_find_value(global.line_numbers, i);
    var code = ds_map_find_value(global.program_lines, line_num);
    var display_text = string(line_num) + " " + code;
    
    draw_text(16, y_pos, display_text);
    y_pos += font_height;
    lines_shown++;
 }
 // Draw input prompt
 draw_text(16, room_height - 64, "READY");
 draw_text(16, room_height - 32, "> " + current_input);
 // Draw cursor
 var cursor_x = 16 + string_width("> " + string_copy(current_input, 1, cursor_pos));
 if (current_time % 1000 < 500) { // Blinking cursor
    draw_text(cursor_x, room_height - 32, "_");
 }
 
 // In Draw Event (add to display code)
 if (message_text != "") {
    draw_set_color(c_yellow);
    draw_text(16, room_height - 96, message_text);
    draw_set_color(c_green);
 }
 
 