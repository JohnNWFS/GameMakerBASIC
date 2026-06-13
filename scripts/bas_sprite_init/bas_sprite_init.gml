/// bas_sprite_init() — allocate global sprite tables.  Call once from obj_globals Create.
function bas_sprite_init() {
    var N = 64;
    global.bas_spr_defined  = array_create(N, false);
    global.bas_spr_pixels   = array_create(N, undefined); // array[256] per slot
    global.bas_spr_mode     = array_create(N, 0);         // 0=mono  1=color
    global.bas_spr_fg       = array_create(N, c_white);
    global.bas_spr_bg       = array_create(N, -1);        // -1 = transparent
    global.bas_spr_gmspr    = array_create(N, -1);        // GML sprite index
    global.bas_spr_visible  = array_create(N, false);
    global.bas_spr_x        = array_create(N, 0);
    global.bas_spr_y        = array_create(N, 0);
    global.bas_spr_angle    = array_create(N, 0);
    global.bas_spr_scale    = array_create(N, 4);         // game-pixels per BASIC pixel
    global.bas_spr_inst     = array_create(N, noone);     // obj_bas_sprite instance
}
