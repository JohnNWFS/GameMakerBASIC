/// @event obj_tile_editor/Draw

draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);

var amber = make_color_rgb(255, 191, 64);
var layout = tile_editor_grid_layout(tile_w, tile_h, 16);
var gx0 = layout.margin;
var gy0 = layout.grid_top;

if (font_exists(fnt_basic)) draw_set_font(fnt_basic);

// Erase-mode banner (high visibility)
if (erase_mode) {
    draw_set_color(make_color_rgb(80, 0, 0));
    draw_rectangle(0, 0, room_width, layout.header_h, false);
    draw_set_color(c_red);
    draw_text(16, 8, "*** ERASE MODE — Space/B click clears pixels — B toggles back to PAINT ***");
} else {
    draw_set_color(amber);
    var def = custom_tile_get_def(tile_code);
    var size_txt = is_undefined(def) ? string(tile_w) + "x" + string(tile_h)
        : string(def.w) + "x" + string(def.h);
    draw_text(16, 8, "TILE EDITOR  tile code " + string(tile_code) + "  (" + size_txt + ")  "
        + tile_editor_color_name_at(color_index) + "  [PAINT]");
    draw_set_color(c_lime);
    draw_text(16, 26, "N = next code   P = prev code   (each code is its own 16x16 drawing)");
}

// Zoomed edit grid
for (var py = 0; py < tile_h; py++) {
    for (var px = 0; px < tile_w; px++) {
        var cx = gx0 + px * layout.zoom;
        var cy = gy0 + py * layout.zoom;
        draw_set_color(make_color_rgb(32, 32, 32));
        draw_rectangle(cx, cy, cx + layout.zoom - 1, cy + layout.zoom - 1, false);
        if (custom_tile_get_bit(tile_code, px, py) == 1) {
            draw_set_color(fg_color);
            draw_rectangle(cx + 1, cy + 1, cx + layout.zoom - 2, cy + layout.zoom - 2, false);
        }
    }
}

// Cursor — red in erase mode, lime in paint mode
var ccx = gx0 + cursor_x * layout.zoom;
var ccy = gy0 + cursor_y * layout.zoom;
draw_set_color(erase_mode ? c_red : c_lime);
draw_rectangle(ccx, ccy, ccx + layout.zoom - 1, ccy + layout.zoom - 1, true);

// Live preview — label on its own row, pixels below (no overlap)
var pv = layout.preview_cell;
var px0 = layout.preview_x;
var label_y = layout.preview_label_y;
var row_h = string_height("PREVIEW");
var py0 = label_y + row_h + 8;
draw_set_color(c_white);
draw_text(px0, label_y, "PREVIEW");
draw_set_color(bg_color);
draw_rectangle(px0, py0, px0 + pv - 1, py0 + pv - 1, false);
custom_tile_draw(tile_code, px0, py0, pv, pv, fg_color);

if (undo_has && undo_code == tile_code) {
    draw_set_color(make_color_rgb(170, 170, 255));
    draw_text(px0, py0 + pv + 8, "R or U = revert last clear");
}

// Help line
draw_set_color(c_lime);
var help_y = room_height - 56;
draw_text(16, help_y, "Arrows move  Space paint  B erase/paint  C color (not clear)  N/P switch code  F/V flip");
draw_text(16, help_y + 20, "X clear  R/U revert clear  G font glyph  S save  L load  ESC exit");

if (status_timer > 0 && status_msg != "") {
    draw_set_color(c_white);
    draw_text(16, help_y - 22, status_msg);
}

// File overlay
if (ui_mode == "file_load" || ui_mode == "file_save") {
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_color(c_lime);
    if (font_exists(fnt_basic_12)) draw_set_font(fnt_basic_12);

    var title = (ui_mode == "file_save")
        ? "SAVE .nwtile — type a new name below, or pick from list, then Enter"
        : "LOAD .nwtile — pick file, Enter confirm, ESC cancel";
    draw_text(24, 24, title);

    if (ui_mode == "file_save") {
        draw_text(24, 52, "Filename (no extension): " + filename_input + "_");
        draw_text(24, 72, "Tip: type letters/numbers, or Up/Down to pick existing file");
    }

    var total = array_length(file_list);
    var row_y = 96;
    if (total <= 0) {
        draw_text(32, row_y, "(no existing .nwtile files — type a name and press Enter)");
    } else {
        for (var i = 0; i < total; i++) {
            var prefix = (i == file_sel) ? "> " : "  ";
            draw_text(32, row_y + i * 18, prefix + file_list[i]);
        }
    }
}