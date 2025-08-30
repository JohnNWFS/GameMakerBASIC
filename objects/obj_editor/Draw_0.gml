/// @event obj_editor/Draw
// Pause regular editor drawing when screen editor is active
if (global.screen_edit_mode) {
    //if (dbg_on(DBG_FLOW)) show_debug_message("EDITOR: Screen edit mode active, pausing regular editor draw");
    exit;
}


// Set font and calculate actual height
draw_set_font(fnt_basic);
var actual_font_height = string_height("A"); // Get real font height
draw_set_color(make_color_rgb(255, 191, 64));
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);

if (showing_dir_overlay) {
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);

    draw_set_color(c_lime);
    draw_set_font(fnt_basic);
    
    var col_count = 3;
    var row_height = actual_font_height; // Use actual font height
    var col_width = room_width div col_count;
    var x_pad = 16;
    var y_pad = 16;

    for (var i = 0; i < array_length(dir_listing); i++) {
        var col = i mod col_count;
        var row = i div col_count;

        var _x = x_pad + col * col_width;
        var _y = y_pad + row * row_height;

        draw_text(_x, _y, dir_listing[i]);
    }

    draw_text(x_pad, room_height - 32, "Press ENTER or ESC to close");
    return; // skip rest of Draw so editor doesn't draw underneath
}

// Draw program lines with proper spacing
var y_pos = 32;
var lines_shown = 0;
var total_lines = ds_list_size(global.line_numbers);

// Calculate how many lines fit on screen
var available_height = room_height - 128; // Leave space for prompt and messages
var max_lines = floor(available_height / actual_font_height);

for (var i = display_start_line; i < total_lines && lines_shown < max_lines; i++) {
    var line_num = ds_list_find_value(global.line_numbers, i);
    var code = ds_map_find_value(global.program_lines, line_num);
    var display_text = string(line_num) + " " + code;
    
    draw_text(16, y_pos, display_text);
    y_pos += actual_font_height; // Use actual font height
    lines_shown++;
}

// Draw input prompt with proper spacing
draw_text(16, room_height - (actual_font_height * 2), "READY");
draw_text(16, room_height - actual_font_height, "> " + current_input);

// Draw cursor
var cursor_x = 16 + string_width("> " + string_copy(current_input, 1, cursor_pos));
if (current_time % 1000 < 500) { // Blinking cursor
    draw_text(cursor_x, room_height - actual_font_height, "_");
}

// Draw message with proper spacing
if (message_text != "") {
    draw_set_color(c_yellow);
    draw_text(16, room_height - (actual_font_height * 3), message_text);
    draw_set_color(make_color_rgb(255, 191, 64)); // Reset color
}