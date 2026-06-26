/// MODE 1 Draw - renders the MODE1 grid (uses global.active_font_sprite)
var tile_w    = global.mode1_cell_px;
var tile_h    = global.mode1_cell_px;
var cols      = grid_cols;
var rows      = grid_rows;
var max_chars = sprite_get_number(global.active_font_sprite);

if (global.grid_refresh_needed) {
    global.grid_refresh_needed = false;
    for (var row = 0; row < rows; row++) {
        for (var col = 0; col < cols; col++) {
            if (mode1_grid_in_bounds(self, col, row)) {
                grid[col][row].char = global.grid_refresh_char;
            }
        }
    }
}

gpu_set_blendmode(bm_normal);
draw_set_alpha(1.0);

function _mode1_valid_subimg(idx) {
    return is_real(idx) && idx >= 0 && idx < max_chars;
}

for (var _y = 0; _y < rows; _y++) {
    for (var _x = 0; _x < cols; _x++) {
        if (!mode1_grid_in_bounds(self, _x, _y)) continue;
        var tile = grid[_x][_y];

        var x0 = _x * tile_w;
        var y0 = _y * tile_h;
        var x1 = (_x + 1) * tile_w;
        var y1 = (_y + 1) * tile_h;

        draw_set_color(tile.bg);
        draw_rectangle(x0, y0, x1, y1, false);

        if (custom_tile_draw(tile.char, x0, y0, tile_w, tile_h, tile.fg)) {
            continue;
        }

        var intent_subimg = clamp(tile.char, 0, max_chars - 1);

        if (tile.char == 32) {
            if (variable_global_exists("mode1_space_subimg")) {
                var sidx = global.mode1_space_subimg;
                if (_mode1_valid_subimg(sidx)) {
                    intent_subimg = sidx;
                } else {
                    intent_subimg = undefined;
                }
            } else {
                intent_subimg = undefined;
            }
        }

        if (intent_subimg != undefined) {
            intent_subimg = clamp(intent_subimg, 0, max_chars - 1);
            draw_sprite_ext(
                global.active_font_sprite,
                intent_subimg,
                x0, y0,
                1, 1, 0,
                tile.fg,
                1.0
            );
        }
    }
}

draw_set_color(c_white);
gpu_set_blendmode(bm_normal);

if (global.program_has_ended) {
    var msg = "Program ended - ESC or ENTER to return";
    var msg_chars = string_length(msg);
    var start_col = max(0, floor((cols - msg_chars) / 2));
    var msg_row = rows - 2;

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