/// Draw obj_bas_sprite — renders the BASIC sprite using draw_sprite_ext.
/// The GML sprite has its origin at (8,8) = sprite centre, so rotation and
/// scale are applied around the centre automatically.
var slot = bas_slot;
if (slot < 0 || slot >= 64) exit;
if (!global.bas_spr_defined[slot]) exit;

var spr = global.bas_spr_gmspr[slot];
if (spr == -1 || !sprite_exists(spr)) {
    // Sprite asset lost (e.g. surface purged) — rebuild it
    bas_sprite_build(slot);
    spr = global.bas_spr_gmspr[slot];
    if (spr == -1) exit;
}

var sc = bas_scale / 1;  // game pixels per BASIC pixel, already a plain number
draw_sprite_ext(spr, 0, x, y, sc, sc, bas_angle, c_white, 1);
