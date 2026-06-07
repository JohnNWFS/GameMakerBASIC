/// MODE 1 COMMAND
/// @function basic_cmd_clschar(arg)
/// @desc CLSCHAR charIndex [, fg [, bg]] — paints entire MODE 1 grid using only these args.
function basic_cmd_clschar(arg) {
    dbg_log(DBG_FLOW, "=== CLSCHAR DEBUG START ===");
    dbg_log(DBG_FLOW, "Raw arg: '" + string(arg) + "'");

    var args = string_split(arg, ",");
    dbg_log(DBG_FLOW, "Split args count: " + string(array_length(args)));
    for (var i = 0; i < array_length(args); i++) {
        show_debug_message("Arg[" + string(i) + "]: '" + string(args[i]) + "'");
    }

    var char_index = 0;
    var fg_color   = c_white;
    var bg_color   = c_black;

    if (array_length(args) >= 1) {
        char_index = floor(real(string_trim(args[0])));
        dbg_log(DBG_FLOW, "Parsed char_index: " + string(char_index));
    }

    if (array_length(args) >= 2) {
        var fg_str = string_upper(string_trim(args[1]));
        dbg_log(DBG_FLOW, "Looking for fg color: '" + fg_str + "'");
        if (ds_map_exists(global.colors, fg_str)) {
            fg_color = global.colors[? fg_str];
            dbg_log(DBG_FLOW, "Found fg color: " + string(fg_color));
        } else {
            dbg_log(DBG_FLOW, "FG COLOR NOT FOUND!");
        }
    }

    if (array_length(args) >= 3) {
        var bg_str = string_upper(string_trim(args[2]));
        dbg_log(DBG_FLOW, "Looking for bg color: '" + bg_str + "'");
        if (ds_map_exists(global.colors, bg_str)) {
            bg_color = global.colors[? bg_str];
            dbg_log(DBG_FLOW, "Found bg color: " + string(bg_color));
        } else {
            dbg_log(DBG_FLOW, "BG COLOR NOT FOUND!");
        }
    }

    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) {
        dbg_log(DBG_FLOW, "❌ CLSCHAR: No obj_mode1_grid found!");
    } else {
        dbg_log(DBG_FLOW, "✅ CLSCHAR: Found grid obj - calling fill...");
        dbg_log(DBG_FLOW, "Calling fill with: char=" + string(char_index) + ", fg=" + string(fg_color) + ", bg=" + string(bg_color));
        grid_obj.mode1_grid_fill(char_index, fg_color, bg_color);
    }

    dbg_log(DBG_FLOW, "=== CLSCHAR DEBUG END ===");
}
