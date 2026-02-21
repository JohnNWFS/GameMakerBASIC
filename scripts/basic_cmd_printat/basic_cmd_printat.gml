/// MODE 1 COMMAND
/// PRINTAT col, row, "text" [, fg [, bg]]
function basic_cmd_printat(arg) {
    if (dbg_on(DBG_FLOW)) show_debug_message("=== PRINTAT DEBUG START ===");
    if (dbg_on(DBG_FLOW)) show_debug_message("Raw arg: '" + string(arg) + "'");

    // Parse arguments (x, y, "string" [, fg [, bg]])
    var args = basic_parse_csv_args(arg);
    if (dbg_on(DBG_FLOW)) show_debug_message("Parsed " + string(array_length(args)) + " arguments");
    if (array_length(args) < 3) {
        if (dbg_on(DBG_FLOW)) show_debug_message("❌ PRINTAT ERROR: Not enough arguments.");
        return;
    }

    // Evaluate x and y using the SAME expression engine your FOR header uses
    var x_expr = string_trim(args[0]);
    var y_expr = string_trim(args[1]);
    var _x     = floor(real(basic_evaluate_expression_v2(x_expr)));
    var _y     = floor(real(basic_evaluate_expression_v2(y_expr)));
    if (dbg_on(DBG_FLOW)) show_debug_message("PRINTAT: start=(" + string(_x) + "," + string(_y) + ")");

    // 3rd argument: literal if quoted, otherwise evaluate expression → string
    var str_expr = string_trim(args[2]);
    var str;

    if (string_length(str_expr) >= 2) {
        var first = string_char_at(str_expr, 1);
        var last  = string_char_at(str_expr, string_length(str_expr));
        if ((first == "\"" || first == "'") && first == last) {
            // literal
            str = string_copy(str_expr, 2, string_length(str_expr) - 2);
        } else {
            // expression (supports variables, STR$, concatenation, etc.)
            var _val = basic_evaluate_expression_v2(str_expr);
            str  = string(_val);
        }
    } else {
        str = string(basic_evaluate_expression_v2(str_expr));
    }

    // Optional colors: parse if present; otherwise PRESERVE existing cell colors
    var fg = undefined;
    var bg = undefined;
    if (array_length(args) > 3) fg = basic_parse_color(string_trim(args[3]));
    if (array_length(args) > 4) bg = basic_parse_color(string_trim(args[4]));
    if (dbg_on(DBG_FLOW)) {
        show_debug_message("PRINTAT colors → fg=" + (is_undefined(fg) ? "<preserve>" : string(fg))
            + " bg=" + (is_undefined(bg) ? "<preserve>" : string(bg)));
    }

    // Grid and bounds
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("PRINTAT: No grid; creating now");
        instance_create_layer(0, 0, "Instances", obj_mode1_grid);
        grid_obj = instance_find(obj_mode1_grid, 0);
        if (!instance_exists(grid_obj)) {
            if (dbg_on(DBG_FLOW)) show_debug_message("PRINTAT: still no grid after create; abort");
            return;
        }
    }
    var cols = grid_obj.grid_cols;
    var rows = grid_obj.grid_rows;
    if (_x < 0 || _y < 0 || _x >= cols || _y >= rows) {
        if (dbg_on(DBG_FLOW)) show_debug_message("PRINTAT: start out of bounds"); 
        return;
    }

    // Write characters, clamped to right edge
    var max_len = min(string_length(str), cols - _x);
    if (dbg_on(DBG_FLOW)) show_debug_message("PRINTAT: str len=" + string(string_length(str)) + " -> max_len=" + string(max_len));
    for (var j = 0; j < max_len; j++) {
        var ch = ord(string_char_at(str, j + 1));
        // IMPORTANT: pass fg/bg as parsed, or undefined to PRESERVE existing colors
        mode1_grid_set(_x + j, _y, ch, fg, bg);
    }

    if (dbg_on(DBG_FLOW)) show_debug_message("✅ PRINTAT complete");
    if (dbg_on(DBG_FLOW)) show_debug_message("=== PRINTAT DEBUG END ===");
}
