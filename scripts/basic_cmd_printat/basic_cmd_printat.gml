function basic_cmd_printat(arg) {
    if (dbg_on(DBG_FLOW)) show_debug_message("=== PRINTAT DEBUG START ===");
    if (dbg_on(DBG_FLOW)) show_debug_message("Raw arg: '" + string(arg) + "'");
    
    var args = basic_parse_csv_args(arg);
    if (dbg_on(DBG_FLOW)) show_debug_message("Parsed " + string(array_length(args)) + " arguments");
    
    if (array_length(args) < 3) {
        if (dbg_on(DBG_FLOW)) show_debug_message("❌ PRINTAT ERROR: Not enough arguments.");
        return;
    }

    for (var i = 0; i < array_length(args); i++) {
        if (dbg_on(DBG_FLOW)) show_debug_message("Arg[" + string(i) + "]: '" + string(args[i]) + "'");
    }

    // Evaluate x and y coordinates
    var _x = basic_evaluate_expression_v2(string_trim(args[0]));
    var _y = basic_evaluate_expression_v2(string_trim(args[1]));
    
    if (dbg_on(DBG_FLOW)) show_debug_message("Coordinates: x=" + string(_x) + ", y=" + string(_y));

    // Handle the string argument - DON'T evaluate it as an expression
    var str = string_trim(args[2]);
    if (dbg_on(DBG_FLOW)) show_debug_message("String before quote removal: '" + str + "'");

    // Remove quotes from string if present
    if (string_length(str) >= 2 && string_char_at(str, 1) == "\"" && string_char_at(str, string_length(str)) == "\"") {
        str = string_copy(str, 2, string_length(str) - 2);
        if (dbg_on(DBG_FLOW)) show_debug_message("String after quote removal: '" + str + "'");
    }

    // Parse colors if provided
    var fg = (array_length(args) > 3) ? basic_parse_color(string_trim(args[3])) : c_white;
    var bg = (array_length(args) > 4) ? basic_parse_color(string_trim(args[4])) : c_black;

    if (dbg_on(DBG_FLOW)) show_debug_message("Colors: fg=" + string(fg) + ", bg=" + string(bg));
    if (dbg_on(DBG_FLOW)) show_debug_message("Will place " + string(string_length(str)) + " characters starting at (" + string(_x) + "," + string(_y) + ")");

    // Place each character individually
    for (var i = 0; i < string_length(str); i++) {
        var ch = ord(string_char_at(str, i + 1));
        if (dbg_on(DBG_FLOW)) show_debug_message("Setting char[" + string(i) + "]: '" + string_char_at(str, i + 1) + "' (code " + string(ch) + ") at (" + string(_x + i) + "," + string(_y) + ")");
        mode1_grid_set(_x + i, _y, ch, fg, bg);
    }

    if (dbg_on(DBG_FLOW)) show_debug_message("✅ PRINTAT complete");
    if (dbg_on(DBG_FLOW)) show_debug_message("=== PRINTAT DEBUG END ===");
}