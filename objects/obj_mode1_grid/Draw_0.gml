/// @event obj_mode1_grid/Draw
//draw_sprite(spr_charactersheet,10,10,10);
var tile_w    = global.mode1_cell_px; // 32 (default), 16, or 8
var tile_h    = global.mode1_cell_px;
var cols      = floor(room_width  / tile_w);
var rows      = floor(room_height / tile_h);
var max_chars = sprite_get_number(global.active_font_sprite);



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

for (var _y = 0; _y < rows; _y++) {
    for (var _x = 0; _x < cols; _x++) {
        var i = _x + _y * cols;
        if (i < array_length(grid)) {
            var tile = grid[i];
            // Draw background
            draw_set_color(tile.bg);
            draw_rectangle(
                _x * tile_w, _y * tile_h,
                (_x + 1) * tile_w, (_y + 1) * tile_h,
                false
            );
            // Draw foreground (sprite tint)
            draw_set_color(tile.fg);
            // Force proper blending
            gpu_set_blendmode(bm_normal);
            draw_set_alpha(1.0);
            var subimg = clamp(tile.char, 0, max_chars - 1);
            // Draw character sprite
            draw_sprite_ext(
                global.active_font_sprite,
                subimg,
                _x * tile_w,
                _y * tile_h,
                1, 1, 0,
                tile.fg,
                1.0
            );
            // Debug helpers (commented out)
            //if (drewfont < 5000) { show_debug_message(global.active_font_sprite); drewfont++; }
            //draw_text(_x * tile_w, _y * tile_h + tile_h - 12, string(tile.char));
        }
    }
}

//    draw_set_color(c_white);
//	draw_text(4, room_height - 40, "FONT=" + global.active_font_name + "  spr=" + string(global.active_font_sprite) + "  num=" + string(sprite_get_number(global.active_font_sprite)));
	
// Reset draw state after the loop
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);

// === END MESSAGE (MODE 1 style) === //
if (global.program_has_ended) {
    // Find a good position for the message - bottom of screen, centered
    var msg = "Program ended - ESC or ENTER to return";
    var msg_chars = string_length(msg);
    var start_col = max(0, floor((cols - msg_chars) / 2)); // Center horizontally
    var msg_row = rows - 2; // Two rows from bottom
    
    // Draw message character by character using the current font sprite
    for (var i = 0; i < msg_chars; i++) {
        var char_code = ord(string_char_at(msg, i + 1));
        var char_x = (start_col + i) * tile_w;
        var char_y = msg_row * tile_h;
        
        // Draw a background highlight for better visibility
        draw_set_color(c_black);
        draw_rectangle(char_x, char_y, char_x + tile_w, char_y + tile_h, false);
        
        // Draw the character in lime color to match MODE 0
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
    
    // Reset draw state
	
}

//draw_text(10, 24, "Font: " + global.active_font_name);

