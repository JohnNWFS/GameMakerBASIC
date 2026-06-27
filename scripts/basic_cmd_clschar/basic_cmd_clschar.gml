/// MODE 1 COMMAND
/// @function basic_cmd_clschar(arg)
/// @desc CLSCHAR charIndex [, fg [, bg]] — paints entire MODE 1 grid using only these args.
function basic_cmd_clschar(arg) {
    dbg_log(DBG_FLOW, "=== CLSCHAR DEBUG START ===");
    dbg_log(DBG_FLOW, "Raw arg: '" + string(arg) + "'");

    var args = basic_parse_csv_args(arg);
    dbg_log(DBG_FLOW, "Split args count: " + string(array_length(args)));
    for (var i = 0; i < array_length(args); i++) {
        show_debug_message("Arg[" + string(i) + "]: '" + string(args[i]) + "'");
    }

    var char_index = 0;
    var fg_color   = c_white;
    var bg_color   = c_black;

    if (!basic_require_arg_count(args, "CLSCHAR", 1, 3, "charIndex[,fg[,bg]]")) return;

    var ch_arg = basic_eval_int_arg(args[0], "CLSCHAR", "charIndex");
    if (!ch_arg.ok) return;
    char_index = ch_arg.value;
    dbg_log(DBG_FLOW, "Parsed char_index: " + string(char_index));

    if (array_length(args) >= 2) {
        fg_color = basic_parse_color(string_trim(args[1]), c_white);
        dbg_log(DBG_FLOW, "CLSCHAR fg color: " + string(fg_color));
    }

    if (array_length(args) >= 3) {
        bg_color = basic_parse_color(string_trim(args[2]), c_black);
        dbg_log(DBG_FLOW, "CLSCHAR bg color: " + string(bg_color));
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
