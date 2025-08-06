/// @description ob_mode1_grid Draw Event
//draw_sprite(spr_charactersheet,10,10,10);
var cols = 40;
var rows = 25;
var tile_w = 32;
var tile_h = 32;
var max_chars = sprite_get_number(spr_charactersheet);

if (global.grid_refresh_needed) {
    global.grid_refresh_needed = false;
    
    for (var row = 0; row < 25; row++) {
        for (var col = 0; col < 40; col++) {
            var i = col + row * 40;
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
            draw_rectangle(_x * tile_w, _y * tile_h, (_x + 1) * tile_w, (_y + 1) * tile_h, false);
            
            // Draw foreground (sprite tint)
            draw_set_color(tile.fg);
            
            // ADD THESE LINES TO FORCE PROPER BLENDING:
            gpu_set_blendmode(bm_normal);
            draw_set_alpha(1.0);
            
            var subimg = clamp(tile.char, 0, max_chars - 1);
            
            // Draw character sprite
            draw_sprite_ext(global.active_font_sprite, subimg, _x * tile_w, _y * tile_h, 1, 1, 0, tile.fg, 1.0);
	//if (drewfont  < 5000) {show_debug_message(global.active_font_sprite);drewfont++;}
		//enable the following to debug
		//draw_text(_x * tile_w, _y * tile_h + tile_h - 12, string(tile.char));

		}
    }
}

// Reset draw state after the loop
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);

//draw_text(10, 24, "Font: " + global.active_font_name);
