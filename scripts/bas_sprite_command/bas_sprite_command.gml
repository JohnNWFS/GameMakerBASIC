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
        var _r0 = basic_eval_number_arg(args[0], "SPRITE DEF", "slot"); if (!_r0.ok) break;
        var slot = clamp(floor(_r0.value) - 1, 0, 63);
        var hexstr = string_trim(args[1]);
        if (string_length(hexstr) >= 2 && string_char_at(hexstr,1) == "\"")
            hexstr = string_copy(hexstr, 2, string_length(hexstr) - 2);
        var is_color = (array_length(args) >= 3 && string_upper(string_trim(args[2])) == "COLOR");
        if (is_color) {
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
        var _r0 = basic_eval_number_arg(args[0], "SPRITE ROW", "slot"); if (!_r0.ok) break;
        var _r1 = basic_eval_number_arg(args[1], "SPRITE ROW", "row");  if (!_r1.ok) break;
        var slot   = clamp(floor(_r0.value) - 1, 0, 63);
        var row    = clamp(floor(_r1.value), 1, 16);
        var hexstr = string_trim(args[2]);
        if (string_length(hexstr) >= 2 && string_char_at(hexstr,1) == "\"")
            hexstr = string_copy(hexstr, 2, string_length(hexstr) - 2);
        bas_sprite_slot(slot).mode = 1;
        bas_sprite_def_color_row(slot, row, hexstr);
        break;
    }

    // ── SPRITE COLOR n  — switch slot to colour mode (clears pixels) ─────
    case "COLOR": {
        var _r0 = basic_eval_number_arg(rest, "SPRITE COLOR", "slot"); if (!_r0.ok) break;
        var slot = clamp(floor(_r0.value) - 1, 0, 63);
        var spr_slot = bas_sprite_slot(slot);
        spr_slot.pixels  = array_create(256, 0);
        spr_slot.mode    = 1;
        spr_slot.defined = true;
        break;
    }

    // ── SPRITE FG n, colour ───────────────────────────────────────────────
    case "FG": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 2) { show_error_message("SPRITE FG: expected slot, colour"); break; }
        var _r0 = basic_eval_number_arg(args[0], "SPRITE FG", "slot");   if (!_r0.ok) break;
        var _r1 = basic_eval_number_arg(args[1], "SPRITE FG", "colour"); if (!_r1.ok) break;
        var slot = clamp(floor(_r0.value) - 1, 0, 63);
        var spr_slot = bas_sprite_slot(slot);
        spr_slot.fg = bas_palette(clamp(floor(_r1.value), 1, 15));
        if (spr_slot.defined) bas_sprite_build(slot);
        break;
    }

    // ── SPRITE BG n, colour  (0 = transparent) ────────────────────────────
    case "BG": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 2) { show_error_message("SPRITE BG: expected slot, colour"); break; }
        var _r0 = basic_eval_number_arg(args[0], "SPRITE BG", "slot");   if (!_r0.ok) break;
        var _r1 = basic_eval_number_arg(args[1], "SPRITE BG", "colour"); if (!_r1.ok) break;
        var slot = clamp(floor(_r0.value) - 1, 0, 63);
        var ci   = floor(_r1.value);
        var spr_slot = bas_sprite_slot(slot);
        spr_slot.bg = (ci <= 0) ? -1 : bas_palette(clamp(ci, 1, 15));
        if (spr_slot.defined) bas_sprite_build(slot);
        break;
    }

    // ── SPRITE SHOW n, x, y [, angle] ────────────────────────────────────
    case "SHOW": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 3) { show_error_message("SPRITE SHOW: expected slot, x, y"); break; }
        var _r0 = basic_eval_number_arg(args[0], "SPRITE SHOW", "slot"); if (!_r0.ok) break;
        var _r1 = basic_eval_number_arg(args[1], "SPRITE SHOW", "x");    if (!_r1.ok) break;
        var _r2 = basic_eval_number_arg(args[2], "SPRITE SHOW", "y");    if (!_r2.ok) break;
        var slot = clamp(floor(_r0.value) - 1, 0, 63);
        var wx   = _r1.value;
        var wy   = _r2.value;
        var ang  = 0;
        if (array_length(args) >= 4) {
            var _r3 = basic_eval_number_arg(args[3], "SPRITE SHOW", "angle"); if (!_r3.ok) break;
            ang = _r3.value;
        }

        var spr_slot = bas_sprite_slot(slot);
        if (!spr_slot.defined) { show_error_message("SPRITE " + string(slot+1) + " not defined"); break; }

        spr_slot.x       = wx;
        spr_slot.y       = wy;
        spr_slot.angle   = ang;
        spr_slot.visible = true;

        if (!instance_exists(spr_slot.inst)) {
            var inst = instance_create_depth(wx, wy, -100, obj_bas_sprite);
            inst.bas_slot  = slot;
            inst.bas_angle = ang;
            inst.bas_scale = spr_slot.scale;
            spr_slot.inst = inst;
        } else {
            var inst = spr_slot.inst;
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
            var _r0 = basic_eval_number_arg(rest, "SPRITE HIDE", "slot"); if (!_r0.ok) break;
            var slot = clamp(floor(_r0.value) - 1, 0, 63);
            bas_sprite_hide(slot);
        }
        break;
    }

    // ── SPRITE MOVE n, x, y ──────────────────────────────────────────────
    case "MOVE": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 3) { show_error_message("SPRITE MOVE: expected slot, x, y"); break; }
        var _r0 = basic_eval_number_arg(args[0], "SPRITE MOVE", "slot"); if (!_r0.ok) break;
        var _r1 = basic_eval_number_arg(args[1], "SPRITE MOVE", "x");    if (!_r1.ok) break;
        var _r2 = basic_eval_number_arg(args[2], "SPRITE MOVE", "y");    if (!_r2.ok) break;
        var slot = clamp(floor(_r0.value) - 1, 0, 63);
        var wx   = _r1.value;
        var wy   = _r2.value;
        var spr_slot = bas_sprite_slot(slot);
        spr_slot.x = wx;
        spr_slot.y = wy;
        if (instance_exists(spr_slot.inst)) {
            spr_slot.inst.x = wx;
            spr_slot.inst.y = wy;
        }
        break;
    }

    // ── SPRITE ANGLE n, angle ─────────────────────────────────────────────
    case "ANGLE": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 2) { show_error_message("SPRITE ANGLE: expected slot, angle"); break; }
        var _r0 = basic_eval_number_arg(args[0], "SPRITE ANGLE", "slot");  if (!_r0.ok) break;
        var _r1 = basic_eval_number_arg(args[1], "SPRITE ANGLE", "angle"); if (!_r1.ok) break;
        var slot = clamp(floor(_r0.value) - 1, 0, 63);
        var ang  = _r1.value;
        var spr_slot = bas_sprite_slot(slot);
        spr_slot.angle = ang;
        if (instance_exists(spr_slot.inst))
            spr_slot.inst.bas_angle = ang;
        break;
    }

    // ── SPRITE SCALE n, factor  (game pixels per BASIC pixel, default 4) ─
    case "SCALE": {
        var args = basic_parse_csv_args(rest);
        if (array_length(args) < 2) { show_error_message("SPRITE SCALE: expected slot, factor"); break; }
        var _r0 = basic_eval_number_arg(args[0], "SPRITE SCALE", "slot");   if (!_r0.ok) break;
        var _r1 = basic_eval_number_arg(args[1], "SPRITE SCALE", "factor"); if (!_r1.ok) break;
        var slot = clamp(floor(_r0.value) - 1, 0, 63);
        var spr_slot = bas_sprite_slot(slot);
        spr_slot.scale = max(1, _r1.value);
        if (instance_exists(spr_slot.inst))
            spr_slot.inst.bas_scale = spr_slot.scale;
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
    var spr_slot = bas_sprite_slot(slot);
    spr_slot.visible = false;
    if (instance_exists(spr_slot.inst)) {
        instance_destroy(spr_slot.inst);
    }
    spr_slot.inst = noone;
}

/// bas_sprite_clear_all() — release all instances and GML sprite assets.
function bas_sprite_clear_all() {
    for (var si = 0; si < 64; si++) {
        bas_sprite_hide(si);
        var spr_slot = bas_sprite_slot(si);
        if (spr_slot.gmspr != -1) {
            sprite_delete(spr_slot.gmspr);
        }
        global.bas_sprites[si] = bas_sprite_slot_default();
    }
}