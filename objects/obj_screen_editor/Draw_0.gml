/// @file objects/obj_screen_editor/Draw_0.gml  
/// @event Draw

// Clear background to black
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);

// Set font and color
draw_set_font(fnt_basic);
draw_set_color(make_color_rgb(255, 191, 64)); // C64 yellow

// Draw screen buffer
for (var _y = 0; _y < screen_rows; _y++) {
    for (var _x = 0; _x < screen_cols; _x++) {
        var ch = chr(screen_editor_get_char_at(id, _x, _y));
        if (ch != " ") {
            var draw_x = margin_x + (_x * char_width);
            var draw_y = margin_y + (_y * char_height);
            draw_text(draw_x, draw_y, ch);
        }
    }
}

// Draw cursor
if (cursor_visible) {
    draw_set_color(c_white);
    var cursor_draw_x = margin_x + (cursor_x * char_width);
    var cursor_draw_y = margin_y + (cursor_y * char_height);
    draw_text(cursor_draw_x, cursor_draw_y, "_");
}

// Draw status line
draw_set_color(c_lime);
draw_text(margin_x, room_height - 40, "SCREEN EDIT - ESC to exit, ENTER to commit line");

// Reset draw color
draw_set_color(c_white);