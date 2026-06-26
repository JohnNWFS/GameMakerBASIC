/// bas_sprite_fn — BASIC functions that query sprite state.
/// These are called from evaluate_postfix for SPRITEX, SPRITEY, SPRITEHIT.

/// SPRITEX(n) — x position of BASIC sprite n
function bas_sprite_fn_x(slot1) {
    var s = clamp(floor(slot1) - 1, 0, 63);
    return bas_sprite_slot(s).x;
}

/// SPRITEY(n) — y position of BASIC sprite n
function bas_sprite_fn_y(slot1) {
    var s = clamp(floor(slot1) - 1, 0, 63);
    return bas_sprite_slot(s).y;
}

/// SPRITEHIT(n, m) — 1 if sprites n and m overlap, 0 otherwise.
/// Uses circular distance check: sprites are 16x16 BASIC pixels at scale 4 = 64x64 game pixels.
/// Collision radius = half of 64 = 32 game pixels.
function bas_sprite_fn_hit(slot1, slot2) {
    var sa = bas_sprite_slot(clamp(floor(slot1) - 1, 0, 63));
    var sb = bas_sprite_slot(clamp(floor(slot2) - 1, 0, 63));
    if (!sa.visible || !sb.visible) return 0;
    var ra = sa.scale * 8; // half of 16 BASIC pixels
    var rb = sb.scale * 8;
    var dist2 = (sa.x - sb.x) * (sa.x - sb.x) + (sa.y - sb.y) * (sa.y - sb.y);
    var rsum  = ra + rb;
    return (dist2 <= rsum * rsum) ? 1 : 0;
}