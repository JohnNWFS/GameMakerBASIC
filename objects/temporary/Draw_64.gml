/// Draw Event - obj_sprite_grid
/// Covers the room with black then draws every subimage of spr_charactersheet_special
/// Designed for a 1280x800 room (uses room_width/room_height so it still adapts if changed)

/// --- full black cover ---
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false); // filled black background
draw_set_color(c_white); // for outlines / sprites

/// --- sprite + layout info ---
var spr       = spr_charactersheet_16x16_special;
var nframes   = sprite_get_number(spr);
if (nframes <= 0) {
    // nothing to draw other than the black cover
    exit;
}

var fw        = sprite_get_width(spr);
var fh        = sprite_get_height(spr);

// layout tuning (tuned for 1280x800 but will adapt)
var padding   = 12;          // pixels of inner padding inside each cell
var margin    = 16;          // outer margin around the whole grid

// compute available drawing area (leave margin around edges)
var avail_w = max(1, room_width  - margin * 2);
var avail_h = max(1, room_height - margin * 2);

// choose number of columns so sprites are reasonably large but fit
// start with a guess based on unscaled frames+padding
var try_cols = floor(avail_w / (fw + padding));
var cols = max(1, min(nframes, try_cols));

// if try_cols is 0 (very small room), force 1 column
if (cols <= 0) cols = 1;

var rows = ceil(nframes / cols);

// compute cell sizes
var cell_w = floor(avail_w / cols);
var cell_h = floor(avail_h / rows);

// compute scale that preserves aspect and fits inside cell (leave padding)
var scale = min( (cell_w - padding) / fw, (cell_h - padding) / fh );

// clamp scale to sensible range so sprites are visible but not grotesque
if (scale < 0.5) scale = 0.5;
if (scale > 6)   scale = 6;

// draw sprites and cell outlines
draw_set_alpha(1);
draw_set_color(c_white);
for (var i = 0; i < nframes; i++) {
    var col = i mod cols;
    var row = floor(i / cols);

    // top-left of this cell (include margin)
    var cell_x = margin + col * cell_w;
    var cell_y = margin + row * cell_h;

    // center the scaled sprite inside the cell (origin assumed top-left)
    var draw_w = fw * scale;
    var draw_h = fh * scale;
    var draw_x = cell_x + (cell_w - draw_w) / 2;
    var draw_y = cell_y + (cell_h - draw_h) / 2;

    // draw the sprite subimage
    draw_sprite_ext(spr, i, draw_x, draw_y, scale, scale, 0, c_white, 1);

    // draw cell outline for clarity
    draw_rectangle(cell_x, cell_y, cell_x + cell_w, cell_y + cell_h, true);
}

// restore defaults (optional)
draw_set_color(c_white);
draw_set_alpha(1);
