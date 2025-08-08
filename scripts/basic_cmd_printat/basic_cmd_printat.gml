function basic_cmd_printat(arg) {
    // arg: x,y,"string",fgcolor,bgcolor
    var args = basic_parse_csv_args(arg);
    if (array_length(args) < 3) {
        show_debug_message("PRINTAT ERROR: Not enough arguments.");
        return;
    }

    var _x = basic_evaluate_expression_v2(args[0]);
    var _y = basic_evaluate_expression_v2(args[1]);
    var str = string(args[2]); // keep quotes if present
    var fg = (array_length(args) > 3) ? basic_parse_color(args[3]) : c_white;
    var bg = (array_length(args) > 4) ? basic_parse_color(args[4]) : c_black;

    // Remove quotes from string if present
    if (string_length(str) >= 2 && string_char_at(str, 1) == "\"" && string_char_at(str, string_length(str)) == "\"") {
        str = string_copy(str, 2, string_length(str) - 2);
    }

    for (var i = 0; i < string_length(str); i++) {
        var ch = ord(string_char_at(str, i + 1));
        mode1_grid_set(_x + i, _y, ch, fg, bg);
    }

    show_debug_message("PRINTAT → (" + string(_x) + "," + string(_y) + ") = '" + str + "'");
}
