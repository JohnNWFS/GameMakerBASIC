/// Rebuild cached grid surface when needs_redraw is set.
function mode1_grid_redraw_surface(_grid_obj) {
    if (!instance_exists(_grid_obj)) return;

    with (_grid_obj) {
        var tile_w    = global.mode1_cell_px;
        var tile_h    = global.mode1_cell_px;
        var _cols     = grid_cols;
        var _rows     = grid_rows;
        var max_chars = sprite_get_number(global.active_font_sprite);
        var surf_w    = _cols * tile_w;
        var surf_h    = _rows * tile_h;

        if (global.grid_refresh_needed) {
            global.grid_refresh_needed = false;
            for (var row = 0; row < _rows; row++) {
                for (var col = 0; col < _cols; col++) {
                    if (mode1_grid_in_bounds(self, col, row)) {
                        grid[col][row].char = global.grid_refresh_char;
                    }
                }
            }
        }

        if (!surface_exists(grid_surface) || surface_get_width(grid_surface) != surf_w || surface_get_height(grid_surface) != surf_h) {
            if (surface_exists(grid_surface)) surface_free(grid_surface);
            grid_surface = surface_create(surf_w, surf_h);
        }

        surface_set_target(grid_surface);
        draw_clear_alpha(c_black, 1);
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1.0);

        for (var _y = 0; _y < _rows; _y++) {
            for (var _x = 0; _x < _cols; _x++) {
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
                        if (is_real(sidx) && sidx >= 0 && sidx < max_chars) {
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

        surface_reset_target();
        needs_redraw = false;
    }
}

/// Blit cached grid surface; rebuild first when dirty.
function mode1_grid_draw(_grid_obj) {
    if (!instance_exists(_grid_obj)) return;

    with (_grid_obj) {
        if (needs_redraw || !surface_exists(grid_surface)) {
            mode1_grid_redraw_surface(id);
        }
        if (surface_exists(grid_surface)) {
            draw_surface(grid_surface, 0, 0);
        }
    }
}