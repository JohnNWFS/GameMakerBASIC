/// MODE 1 Draw - renders the MODE1 grid (uses global.active_font_sprite)
var tile_w    = global.mode1_cell_px; // 32 (default), 16, or 8
var tile_h    = global.mode1_cell_px;
var cols      = floor(room_width  / tile_w);
var rows      = floor(room_height / tile_h);
var max_chars = sprite_get_number(global.active_font_sprite);

// Optional grid refresh (unchanged)
if (global.grid_refresh_needed) {
    global.grid_refresh_needed = false;
    for (var row = 0; row < rows; row++) {
        for (var col = 0; col < cols; col++) {
            var i = col + row * cols;
            if (i < array_length(grid)) {
                grid[i].char = global.grid_refresh_char;
            }
        }
    }
}

// Set stable draw state once
gpu_set_blendmode(bm_normal);
draw_set_alpha(1.0);

// local helper: check if a candidate subimage index is usable for current font
function _mode1_valid_subimg(idx) {
    return is_real(idx) && idx >= 0 && idx < max_chars;
}

for (var _y = 0; _y < rows; _y++) {
    for (var _x = 0; _x < cols; _x++) {
        var i = _x + _y * cols;
        if (i < array_length(grid)) {
            var tile = grid[i];

            // Precompute cell bounds
            var x0 = _x * tile_w;
            var y0 = _y * tile_h;
            var x1 = (_x + 1) * tile_w;
            var y1 = (_y + 1) * tile_h;

            // 1) ALWAYS paint background (even if char == 32 and sprite is transparent)
            draw_set_color(tile.bg);
            draw_rectangle(x0, y0, x1, y1, false);

            // 2) Decide whether to draw a glyph and which subimage to use
            var intent_subimg = clamp(tile.char, 0, max_chars - 1);

            // Special-case SPACE (32): if a substitute subimage is configured, use it.
            if (tile.char == 32) {
                if (variable_global_exists("mode1_space_subimg")) {
                    var sidx = global.mode1_space_subimg;
                    if (_mode1_valid_subimg(sidx)) {
                        intent_subimg = sidx;
                    } else {
                        // invalid configured subimg -> skip drawing glyph (space stays invisible)
                        intent_subimg = undefined;
                    }
                } else {
                    // no substitute provided -> skip drawing glyph for space
                    intent_subimg = undefined;
                }
            }

            // Finally draw glyph if we have a valid subimage index
            if (intent_subimg != undefined) {
                // ensure subimg is in range
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
}

// Reset draw state
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);

// === END MESSAGE (MODE 1 style) ===
if (global.program_has_ended) {
    var msg = "Program ended - ESC or ENTER to return";
    var msg_chars = string_length(msg);
    var start_col = max(0, floor((cols - msg_chars) / 2));
    var msg_row = rows - 2;

    for (var i = 0; i < msg_chars; i++) {
        var char_code = ord(string_char_at(msg, i + 1));
        var char_x = (start_col + i) * tile_w;
        var char_y = msg_row * tile_h;

        // Background highlight behind message char
        draw_set_color(c_black);
        draw_rectangle(char_x, char_y, char_x + tile_w, char_y + tile_h, false);

        // Lime text glyph
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
