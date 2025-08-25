// FILE: scripts/basic_cmd_mode.gml
// FUNCTION: basic_cmd_mode(arg)
// BEHAVIOR: MODE 1 optionally accepts a size (8,16,32). Sets global.mode1_cell_px,
//           selects a size-matched default font from global.font_sheets, and switches rooms when needed.
function basic_cmd_mode(arg) {
    var mode    = 0;
    var size_px = -1;
    // --- Parse "1" or "1,16" (CSV-aware) ---
    var s = string_trim(arg);
    if (string_pos(",", s) > 0) {
        var parts = basic_parse_csv_args(s);
        mode = real(string_trim(parts[0]));
        if (array_length(parts) >= 2) size_px = real(string_trim(parts[1]));
    } else {
        mode = real(s);
    }
    // --- Validate mode key in registry ---
    if (!ds_map_exists(global.mode_rooms, mode)) {
        basic_show_message("Invalid MODE: " + string(mode));
        return;
    }
    // --- MODE 1: accept 8/16/32; default 32 for back-compat ---
// --- Only MODE 1 supports size selection (8/16/32), default 32 ---
if (mode == 1) {
    if (size_px != 8 && size_px != 16 && size_px != 32) size_px = 32;
    global.mode1_cell_px = size_px;
    if (dbg_on(DBG_FLOW)) show_debug_message("MODE 1: cell size set to " + string(size_px) + " px");

    // Pick a matching DEFAULT_* only if user hasn't FONTSET-locked a font
    if (!variable_global_exists("font_locked") || !global.font_locked) {
        var _key = "DEFAULT_32";
        if (size_px == 16) _key = "DEFAULT_16";
        else if (size_px == 8) _key = "DEFAULT_8";

        if (ds_map_exists(global.font_sheets, _key)) {
            global.active_font_name   = _key;
            global.active_font_sprite = global.font_sheets[? _key];
            if (dbg_on(DBG_FLOW)) show_debug_message("MODE: active font -> " + _key);
        }
    } else {
        if (dbg_on(DBG_FLOW)) show_debug_message("MODE: font locked by user (" + global.active_font_name + "), leaving as-is");
    }
}

    // --- If mode already active, do not switch rooms (we still updated size/font above) ---
    if (mode == global.current_mode) {
        show_debug_message("MODE already set to " + string(mode) + "; no room switch needed.");
        return;
    }
    // --- Switch to the room for the requested mode ---
    global.current_mode = mode;
    var target_room = ds_map_find_value(global.mode_rooms, mode);
    show_debug_message("Switching to MODE " + string(mode) + " → room: " + string(target_room));
    room_goto(target_room);
}