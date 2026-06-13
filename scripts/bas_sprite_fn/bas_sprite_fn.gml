/// bas_sprite_fn — BASIC functions that query sprite state.
/// These are called from evaluate_postfix for SPRITEX, SPRITEY, SPRITEHIT.

/// SPRITEX(n) — x position of BASIC sprite n
function bas_sprite_fn_x(slot1) {
    var s = clamp(floor(slot1) - 1, 0, 63);
    return global.bas_spr_x[s];
}

/// SPRITEY(n) — y position of BASIC sprite n
function bas_sprite_fn_y(slot1) {
    var s = clamp(floor(slot1) - 1, 0, 63);
    return global.bas_spr_y[s];
}

/// SPRITEHIT(n, m) — 1 if sprites n and m overlap, 0 otherwise.
/// Uses circular distance check: sprites are 16x16 BASIC pixels at scale 4 = 64x64 game pixels.
/// Collision radius = half of 64 = 32 game pixels.
function bas_sprite_fn_hit(slot1, slot2) {
    var sa = clamp(floor(slot1) - 1, 0, 63);
    var sb = clamp(floor(slot2) - 1, 0, 63);
    if (!global.bas_spr_visible[sa] || !global.bas_spr_visible[sb]) return 0;
    var ax = global.bas_spr_x[sa];
    var ay = global.bas_spr_y[sa];
    var bx = global.bas_spr_x[sb];
    var by = global.bas_spr_y[sb];
    var ra = global.bas_spr_scale[sa] * 8; // half of 16 BASIC pixels
    var rb = global.bas_spr_scale[sb] * 8;
    var dist2 = (ax - bx) * (ax - bx) + (ay - by) * (ay - by);
    var rsum  = ra + rb;
    return (dist2 <= rsum * rsum) ? 1 : 0;
}
