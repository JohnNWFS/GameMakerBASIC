/// MODE 1 COMMAND
/// PRINTAT col, row, "text" [, fg [, bg]]
function basic_cmd_printat(arg) {
    dbg_log(DBG_FLOW, "=== PRINTAT DEBUG START ===");
    dbg_log(DBG_FLOW, "Raw arg: '" + string(arg) + "'");

    // Parse arguments (x, y, "string" [, fg [, bg]])
    var args = basic_parse_csv_args(arg);
    dbg_log(DBG_FLOW, "Parsed " + string(array_length(args)) + " arguments");
    if (!basic_require_arg_count(args, "PRINTAT", 3, 5, "col,row,text[,fg[,bg]]")) return;

    // Evaluate x and y using the SAME expression engine your FOR header uses
    var x_expr = string_trim(args[0]);
    var y_expr = string_trim(args[1]);
    var x_arg = basic_eval_int_arg(x_expr, "PRINTAT", "col");
    var y_arg = basic_eval_int_arg(y_expr, "PRINTAT", "row");
    if (!x_arg.ok || !y_arg.ok) return;
    var _x = x_arg.value;
    var _y = y_arg.value;
    dbg_log(DBG_FLOW, "PRINTAT: start=(" + string(_x) + "," + string(_y) + ")");

    // 3rd argument: literal if quoted, otherwise evaluate expression → string
    var str_expr = string_trim(args[2]);
    var str;

    if (string_length(str_expr) >= 2) {
        var first = string_char_at(str_expr, 1);
        var last  = string_char_at(str_expr, string_length(str_expr));
        if (first == "\"" || first == "'") {
            // Literal. Strip the opening quote even if an upstream parser bug
            // left the closing quote off, so PRINTAT never draws a stray quote.
            var literal_len = string_length(str_expr) - 1;
            str = string_copy(str_expr, 2, literal_len);
            if (string_length(str) > 0 && last == first) {
                str = string_copy(str, 1, string_length(str) - 1);
            }
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
        dbg_log(DBG_FLOW, "PRINTAT: start out of bounds"); 
        return;
    }

    str = mode1_ascii_fallback_text(str);
    basic_output_transcript_append("PRINTAT(" + string(_x) + "," + string(_y) + "): " + str);

    // Write characters, clamped to right edge
    var max_len = min(string_length(str), cols - _x);
    dbg_log(DBG_FLOW, "PRINTAT: str len=" + string(string_length(str)) + " -> max_len=" + string(max_len));
    for (var j = 0; j < max_len; j++) {
        var ch = mode1_ascii_fallback_code(ord(string_char_at(str, j + 1)));
        // IMPORTANT: pass fg/bg as parsed, or undefined to PRESERVE existing colors
        mode1_grid_set(_x + j, _y, ch, fg, bg);
    }

    dbg_log(DBG_FLOW, "✅ PRINTAT complete");
    dbg_log(DBG_FLOW, "=== PRINTAT DEBUG END ===");
}
