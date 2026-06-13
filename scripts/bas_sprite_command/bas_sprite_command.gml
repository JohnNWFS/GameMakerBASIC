/// bas_sprite_command(params) — dispatcher for the SPRITE command.
/// Called from handle_command with everything after "SPRITE".
function bas_sprite_command(params) {
    params = string_trim(params);
    var space = string_pos(" ", params);
    var sub, rest;
    if (space > 0) {
        sub  = string_upper(string_trim(string_copy(params, 1, space - 1)));
        rest = string_trim(string_copy(params, space + 1, string_length(params)));
    } else {
        sub  = string_upper(params);
        rest = "";
    }

    switch (sub) {

    // ── SPRITE DEF n, "hexstring"  [, COLOR] ─────────────────────────────
    case "DEF": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 2) { show_error_message("SPRITE DEF: expected slot, hexstring"); break; }
        var slot = clamp(floor(real(args[0])) - 1, 0, 63);
        var hexstr = string_trim(args[1]);
        // Strip optional surrounding quotes
        if (string_length(hexstr) >= 2 && string_char_at(hexstr,1) == "\"")
            hexstr = string_copy(hexstr, 2, string_length(hexstr) - 2);
        var is_color = (array_length(args) >= 3 && string_upper(string_trim(args[2])) == "COLOR");
        if (is_color) {
            // COLOR mode: treat hexstring as row 1 of a colour sprite
            bas_sprite_def_color_row(slot, 1, hexstr);
        } else {
            bas_sprite_def_mono(slot, hexstr);
        }
        break;
    }

    // ── SPRITE ROW n, row, "hexstring"  (colour sprites, one row at a time) ──
    case "ROW": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 3) { show_error_message("SPRITE ROW: expected slot, row, hexstring"); break; }
        var slot   = clamp(floor(real(args[0])) - 1, 0, 63);
        var row    = clamp(floor(real(args[1])), 1, 16);
        var hexstr = string_trim(args[2]);
        if (string_length(hexstr) >= 2 && string_char_at(hexstr,1) == "\"")
            hexstr = string_copy(hexstr, 2, string_length(hexstr) - 2);
        global.bas_spr_mode[slot] = 1;  // ensure colour mode
        bas_sprite_def_color_row(slot, row, hexstr);
        break;
    }

    // ── SPRITE COLOR n  — switch slot to colour mode (clears pixels) ─────
    case "COLOR": {
        var slot = clamp(floor(real(rest)) - 1, 0, 63);
        global.bas_spr_pixels[slot]  = array_create(256, 0);
        global.bas_spr_mode[slot]    = 1;
        global.bas_spr_defined[slot] = true;
        break;
    }

    // ── SPRITE FG n, colour ───────────────────────────────────────────────
    case "FG": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 2) { show_error_message("SPRITE FG: expected slot, colour"); break; }
        var slot = clamp(floor(real(args[0])) - 1, 0, 63);
        global.bas_spr_fg[slot] = bas_palette(clamp(floor(real(args[1])), 1, 15));
        if (global.bas_spr_defined[slot]) bas_sprite_build(slot);
        break;
    }

    // ── SPRITE BG n, colour  (0 = transparent) ────────────────────────────
    case "BG": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 2) { show_error_message("SPRITE BG: expected slot, colour"); break; }
        var slot = clamp(floor(real(args[0])) - 1, 0, 63);
        var ci   = floor(real(args[1]));
        global.bas_spr_bg[slot] = (ci <= 0) ? -1 : bas_palette(clamp(ci, 1, 15));
        if (global.bas_spr_defined[slot]) bas_sprite_build(slot);
        break;
    }

    // ── SPRITE SHOW n, x, y [, angle] ────────────────────────────────────
    case "SHOW": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 3) { show_error_message("SPRITE SHOW: expected slot, x, y"); break; }
        var slot  = clamp(floor(real(args[0])) - 1, 0, 63);
        var wx    = real(args[1]);
        var wy    = real(args[2]);
        var ang   = (array_length(args) >= 4) ? real(args[3]) : 0;

        if (!global.bas_spr_defined[slot]) { show_error_message("SPRITE " + string(slot+1) + " not defined"); break; }

        global.bas_spr_x[slot]       = wx;
        global.bas_spr_y[slot]       = wy;
        global.bas_spr_angle[slot]   = ang;
        global.bas_spr_visible[slot] = true;

        // Reuse existing instance or create a new one
        if (!instance_exists(global.bas_spr_inst[slot])) {
            var inst = instance_create_depth(wx, wy, -100, obj_bas_sprite);
            inst.bas_slot  = slot;
            inst.bas_angle = ang;
            global.bas_spr_inst[slot] = inst;
        } else {
            var inst = global.bas_spr_inst[slot];
            inst.x         = wx;
            inst.y         = wy;
            inst.bas_angle = ang;
        }
        break;
    }

    // ── SPRITE HIDE n  (or HIDE ALL) ─────────────────────────────────────
    case "HIDE": {
        var upper = string_upper(string_trim(rest));
        if (upper == "ALL") {
            for (var si = 0; si < 64; si++) bas_sprite_hide(si);
        } else {
            var slot = clamp(floor(real(rest)) - 1, 0, 63);
            bas_sprite_hide(slot);
        }
        break;
    }

    // ── SPRITE MOVE n, x, y ──────────────────────────────────────────────
    case "MOVE": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 3) { show_error_message("SPRITE MOVE: expected slot, x, y"); break; }
        var slot = clamp(floor(real(args[0])) - 1, 0, 63);
        var wx   = real(args[1]);
        var wy   = real(args[2]);
        global.bas_spr_x[slot] = wx;
        global.bas_spr_y[slot] = wy;
        if (instance_exists(global.bas_spr_inst[slot])) {
            global.bas_spr_inst[slot].x = wx;
            global.bas_spr_inst[slot].y = wy;
        }
        break;
    }

    // ── SPRITE ANGLE n, angle ─────────────────────────────────────────────
    case "ANGLE": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 2) { show_error_message("SPRITE ANGLE: expected slot, angle"); break; }
        var slot = clamp(floor(real(args[0])) - 1, 0, 63);
        var ang  = real(args[1]);
        global.bas_spr_angle[slot] = ang;
        if (instance_exists(global.bas_spr_inst[slot]))
            global.bas_spr_inst[slot].bas_angle = ang;
        break;
    }

    // ── SPRITE SCALE n, factor  (game pixels per BASIC pixel, default 4) ─
    case "SCALE": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 2) { show_error_message("SPRITE SCALE: expected slot, factor"); break; }
        var slot = clamp(floor(real(args[0])) - 1, 0, 63);
        global.bas_spr_scale[slot] = max(1, real(args[1]));
        if (instance_exists(global.bas_spr_inst[slot]))
            global.bas_spr_inst[slot].bas_scale = global.bas_spr_scale[slot];
        break;
    }

    // ── SPRITE CLEAR  — destroy all instances and free all GML sprites ────
    case "CLEAR": {
        bas_sprite_clear_all();
        break;
    }

    default:
        show_error_message("Unknown SPRITE sub-command: " + sub);
    }
}

/// bas_sprite_hide(slot) — hide a single sprite slot.
function bas_sprite_hide(slot) {
    global.bas_spr_visible[slot] = false;
    if (instance_exists(global.bas_spr_inst[slot])) {
        instance_destroy(global.bas_spr_inst[slot]);
    }
    global.bas_spr_inst[slot] = noone;
}

/// bas_sprite_clear_all() — release all instances and GML sprite assets.
function bas_sprite_clear_all() {
    for (var si = 0; si < 64; si++) {
        bas_sprite_hide(si);
        if (global.bas_spr_gmspr[si] != -1) {
            sprite_delete(global.bas_spr_gmspr[si]);
            global.bas_spr_gmspr[si] = -1;
        }
        global.bas_spr_defined[si]  = false;
        global.bas_spr_visible[si]  = false;
        global.bas_spr_pixels[si]   = undefined;
        global.bas_spr_mode[si]     = 0;
        global.bas_spr_fg[si]       = c_white;
        global.bas_spr_bg[si]       = -1;
        global.bas_spr_angle[si]    = 0;
        global.bas_spr_scale[si]    = 4;
    }
}
