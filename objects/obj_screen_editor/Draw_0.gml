// Clear background
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);

// Font/color
if (font_exists(fnt_basic)) draw_set_font(fnt_basic);
draw_set_color(make_color_rgb(255,191,64)); // your C64 yellow

// Draw any backing buffer you still use (safe-guarded)
if (is_array(screen_buffer)) {
    for (var _y = 0; _y < screen_rows; _y++) {
        for (var _x = 0; _x < screen_cols; _x++) {
            var idx = _x + _y * screen_cols;
            if (idx < array_length(screen_buffer)) {
                var ch = chr(screen_buffer[idx]);
                if (ch != " ") {
                    var draw_x = margin_x + (_x * char_width);
                    var draw_y = margin_y + (_y * char_height);
                    draw_text(draw_x, draw_y, ch);
                }
            }
        }
    }
}

// Draw caret on top of the existing buffer (no row_text/current_row)
if (cursor_visible) {
    draw_set_color(c_white);
    var caret_x = margin_x + (cursor_x * char_width);
    var caret_y = margin_y + (cursor_y * char_height);
    draw_text(caret_x, caret_y, "_");
}
