/// bas_sprite_init() — allocate sprite slot table. Call once from obj_globals Create.
function bas_sprite_init() {
    bas_sprite_purge_instances();
    var N = 64;
    global.bas_sprites = array_create(N);
    for (var i = 0; i < N; i++) {
        global.bas_sprites[i] = bas_sprite_slot_default();
    }
}

/// Default state for one BASIC sprite slot (0-based internal index).
function bas_sprite_slot_default() {
    return {
        defined : false,
        pixels  : undefined, // array[256] when defined
        mode    : 0,         // 0 = mono, 1 = colour
        fg      : c_white,
        bg      : -1,        // -1 = transparent (mono)
        gmspr   : -1,        // GML sprite asset id
        visible : false,
        x       : 0,
        y       : 0,
        angle   : 0,
        scale   : 4,         // game pixels per BASIC pixel
        inst    : noone      // obj_bas_sprite instance while visible
    };
}

/// Clamp and return the slot struct for internal index 0..63.
function bas_sprite_slot(_slot) {
    return global.bas_sprites[clamp(floor(_slot), 0, 63)];
}