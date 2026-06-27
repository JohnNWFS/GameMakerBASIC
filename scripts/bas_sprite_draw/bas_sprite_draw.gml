/// Destroy legacy per-slot obj_bas_sprite instances (pre-centralized draw path).
function bas_sprite_purge_instances() {
    with (obj_bas_sprite) {
        instance_destroy();
    }
}

/// Draw all visible BASIC sprite slots directly (no per-slot instances).
function bas_sprite_draw_all() {
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);

    for (var si = 0; si < 64; si++) {
        var spr_slot = bas_sprite_slot(si);
        if (!spr_slot.defined || !spr_slot.visible) continue;

        var spr = spr_slot.gmspr;
        if (spr == -1 || !sprite_exists(spr)) {
            bas_sprite_build(si);
            spr = spr_slot.gmspr;
            if (spr == -1) continue;
        }

        var sc = spr_slot.scale;
        draw_sprite_ext(spr, 0, spr_slot.x, spr_slot.y, sc, sc, spr_slot.angle, c_white, 1);
    }
}