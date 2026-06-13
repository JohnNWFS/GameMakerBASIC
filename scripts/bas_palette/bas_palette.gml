/// bas_palette(index) — 16-colour BASIC palette (0=transparent sentinel, 1-15 = colours)
/// Returns a GML colour value.
function bas_palette(index) {
    switch (index) {
        case 0:  return c_black;           // transparent (caller handles, but safe fallback)
        case 1:  return c_black;           // black
        case 2:  return c_white;           // white
        case 3:  return make_color_rgb(136,  0,  0); // dark red
        case 4:  return make_color_rgb(170,255,238); // cyan
        case 5:  return make_color_rgb(170, 68,204); // purple
        case 6:  return make_color_rgb(  0,204,  85); // green
        case 7:  return make_color_rgb(  0,  0,170); // blue
        case 8:  return make_color_rgb(238,238,119); // yellow
        case 9:  return make_color_rgb(221,136,  0); // orange
        case 10: return make_color_rgb(255,119,119); // light red / pink
        case 11: return make_color_rgb( 51, 51, 51); // dark grey
        case 12: return make_color_rgb(119,119,119); // mid grey
        case 13: return make_color_rgb(170,255,102); // light green
        case 14: return make_color_rgb( 85,136,255); // light blue
        case 15: return make_color_rgb(187,187,187); // light grey
        default: return c_white;
    }
}
