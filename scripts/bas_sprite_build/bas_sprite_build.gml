/// bas_sprite_build(slot) — (re)create the GML sprite for BASIC sprite slot from stored pixel data.
/// Uses a 16x16 surface → sprite_create_from_surface with centre origin.
function bas_sprite_build(slot) {
    var spr_slot = bas_sprite_slot(slot);
    if (!spr_slot.defined) exit;

    var surf = surface_create(16, 16);
    surface_set_target(surf);
    draw_clear_alpha(c_black, 0);  // fully transparent canvas

    var pixels = spr_slot.pixels;
    var fg     = spr_slot.fg;
    var bg     = spr_slot.bg;
    var mode   = spr_slot.mode;

    for (var py = 0; py < 16; py++) {
        for (var px = 0; px < 16; px++) {
            var val = pixels[py * 16 + px];
            var col;
            if (mode == 0) {             // mono
                if (val == 0) {
                    if (bg < 0) continue;
                    col = bg;
                } else col = fg;
            } else {                     // 4-bit colour  (0 = transparent)
                if (val == 0) continue;
                col = bas_palette(val);
            }
            draw_set_color(col);
            draw_set_alpha(1);
            draw_rectangle(px, py, px + 1, py + 1, false);
        }
    }
    draw_set_alpha(1);
    surface_reset_target();

    // Free old GML sprite
    if (spr_slot.gmspr != -1) {
        sprite_delete(spr_slot.gmspr);
    }

    // Origin at centre (8,8) so draw_sprite_ext rotates around sprite centre
    var spr = sprite_create_from_surface(surf, 0, 0, 16, 16, false, false, 8, 8);
    surface_free(surf);
    spr_slot.gmspr = spr;
}

/// bas_sprite_hex_nibble(ch) — single hex character → 0-15
function bas_sprite_hex_nibble(ch) {
    if (ch >= "0" && ch <= "9") return real(ch);
    ch = string_upper(ch);
    if (ch == "A") return 10;
    if (ch == "B") return 11;
    if (ch == "C") return 12;
    if (ch == "D") return 13;
    if (ch == "E") return 14;
    if (ch == "F") return 15;
    return 0;
}

/// bas_sprite_def_mono(slot, hexstr)
/// Each hex nibble encodes 4 monochrome pixels (MSB first).
/// A 16x16 sprite needs exactly 64 hex chars (32 bytes).
function bas_sprite_def_mono(slot, hexstr) {
    hexstr = string_upper(string_replace_all(hexstr, " ", ""));
    var pixels = array_create(256, 0);
    var pidx = 0;
    var hlen = string_length(hexstr);
    for (var hi = 1; hi <= hlen && pidx < 256; hi++) {
        var nib = bas_sprite_hex_nibble(string_char_at(hexstr, hi));
        pixels[pidx++] = (nib >> 3) & 1;
        if (pidx < 256) pixels[pidx++] = (nib >> 2) & 1;
        if (pidx < 256) pixels[pidx++] = (nib >> 1) & 1;
        if (pidx < 256) pixels[pidx++] =  nib       & 1;
    }
    var spr_slot = bas_sprite_slot(slot);
    spr_slot.pixels  = pixels;
    spr_slot.mode    = 0;
    spr_slot.defined = true;
    bas_sprite_build(slot);
}

/// bas_sprite_def_color_row(slot, row1based, hexstr)
/// Each hex nibble = one pixel colour (0=transparent, 1-15 = palette index).
/// 16 nibbles per row. Call once per row to build up the sprite.
function bas_sprite_def_color_row(slot, row1, hexstr) {
    var spr_slot = bas_sprite_slot(slot);
    if (!spr_slot.defined || spr_slot.mode != 1) {
        spr_slot.pixels  = array_create(256, 0);
        spr_slot.mode    = 1;
        spr_slot.defined = true;
    }
    hexstr = string_upper(string_replace_all(hexstr, " ", ""));
    var base = (row1 - 1) * 16;
    for (var hi = 1; hi <= 16 && base + hi - 1 < 256; hi++) {
        var ch = string_char_at(hexstr, hi);
        spr_slot.pixels[base + hi - 1] = (ch == "" || ch == " ") ? 0 : bas_sprite_hex_nibble(ch);
    }
    bas_sprite_build(slot);
}