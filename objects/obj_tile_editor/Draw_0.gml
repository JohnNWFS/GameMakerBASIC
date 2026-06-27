/// @event obj_tile_editor/Draw

draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);

var amber = make_color_rgb(255, 191, 64);
var layout = tile_editor_grid_layout(tile_w, tile_h, 16);
var gx0 = layout.margin;
var gy0 = layout.margin + 28;

if (font_exists(fnt_basic)) draw_set_font(fnt_basic);
draw_set_color(amber);

var def = custom_tile_get_def(tile_code);
var size_txt = is_undefined(def) ? string(tile_w) + "x" + string(tile_h)
    : string(def.w) + "x" + string(def.h);
draw_text(16, 8, "TILE EDITOR  code " + string(tile_code) + "  (" + size_txt + ")  "
    + tile_editor_color_name_at(color_index) + (erase_mode ? "  [ERASE]" : "  [PAINT]"));

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

// Cursor
draw_set_color(c_lime);
var ccx = gx0 + cursor_x * layout.zoom;
var ccy = gy0 + cursor_y * layout.zoom;
draw_rectangle(ccx, ccy, ccx + layout.zoom - 1, ccy + layout.zoom - 1, true);

// Live preview at cell scale
var pv = layout.preview_cell;
var px0 = layout.preview_x;
var py0 = layout.preview_y;
draw_set_color(c_white);
draw_text(px0, py0 - 22, "PREVIEW");
draw_set_color(bg_color);
draw_rectangle(px0, py0, px0 + pv - 1, py0 + pv - 1, false);
custom_tile_draw(tile_code, px0, py0, pv, pv, fg_color);

// Help line
draw_set_color(c_lime);
var help_y = room_height - 56;
draw_text(16, help_y, "Arrows move  Space paint  B erase  C color  N/P code  F/V flip");
draw_text(16, help_y + 20, "S save  L load  R restore font  X clear  ESC exit");

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

    var title = (ui_mode == "file_save") ? "SAVE .nwtile — type name or pick file, Enter confirm"
                                         : "LOAD .nwtile — Enter confirm, ESC cancel";
    draw_text(24, 24, title);

    if (ui_mode == "file_save") {
        draw_text(24, 52, "Filename: " + filename_input + "_");
    }

    var total = array_length(file_list);
    var row_y = 88;
    if (total <= 0) {
        draw_text(32, row_y, "(no existing .nwtile files — type a name and press Enter)");
    } else {
        for (var i = 0; i < total; i++) {
            var prefix = (i == file_sel) ? "> " : "  ";
            draw_text(32, row_y + i * 18, prefix + file_list[i]);
        }
    }
}