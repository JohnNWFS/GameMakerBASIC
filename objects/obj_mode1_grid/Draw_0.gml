/// MODE 2 Draw — cached surface blit + sprites + end banner
mode1_grid_draw(self);
bas_sprite_draw_all();

if (global.program_has_ended) {
    var tile_w = global.mode1_cell_px;
    var tile_h = global.mode1_cell_px;
    var cols   = grid_cols;
    var rows   = grid_rows;
    var max_chars = sprite_get_number(global.active_font_sprite);
    var msg = "Program ended - ESC or ENTER to return";
    var msg_chars = string_length(msg);
    var start_col = max(0, floor((cols - msg_chars) / 2));
    var msg_row = rows - 2;

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1.0);

    for (var i = 0; i < msg_chars; i++) {
        var char_code = ord(string_char_at(msg, i + 1));
        var char_x = (start_col + i) * tile_w;
        var char_y = msg_row * tile_h;

        draw_set_color(c_black);
        draw_rectangle(char_x, char_y, char_x + tile_w, char_y + tile_h, false);

        var subimg = clamp(char_code, 0, max_chars - 1);
        draw_sprite_ext(
            global.active_font_sprite,
            subimg,
            char_x, char_y,
            1, 1, 0,
            c_lime,
            1.0
        );
    }
}

draw_set_color(c_white);
gpu_set_blendmode(bm_normal);