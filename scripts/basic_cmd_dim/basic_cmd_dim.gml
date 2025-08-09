/// @function basic_cmd_dim(rest)
/// @description DIM NAME(expr) or DIM NAME1(expr1), NAME2(expr2), ...
/// Allocates 1-D arrays in global.basic_arrays as zero-filled ds_lists.
/// Semantics: inclusive upper bound like C64 — DIM A(10) => valid indices 0..10.
/// Notes:
/// - Safe alongside LET auto-grow: DIM preallocates; LET keeps working the same.
/// - Multiple arrays supported, comma-separated at top level (commas inside () are ignored).
function basic_cmd_dim(rest) {
    var s  = string_trim(rest);
    if (s == "") {
        show_debug_message("DIM ERROR: Missing arguments");
        return;
    }

    // Ensure array registry exists
    if (is_undefined(global.basic_arrays)) {
        global.basic_arrays = ds_map_create();
        show_debug_message("DIM: Created global.basic_arrays map");
    }

    // Split on top-level commas (ignore commas inside parentheses or quotes)
    var defs = [];
    {
        var _depth = 0;
        var in_q  = false;
        var start = 1;
        for (var i = 1; i <= string_length(s); i++) {
            var ch = string_char_at(s, i);
            if (ch == "\"") { in_q = !in_q; }
            if (!in_q) {
                if (ch == "(") _depth++;
                else if (ch == ")") _depth = max(0, _depth - 1);
                else if (ch == "," && _depth == 0) {
                    array_push(defs, string_trim(string_copy(s, start, i - start)));
                    start = i + 1;
                }
            }
        }
        // tail
        if (start <= string_length(s)) {
            array_push(defs, string_trim(string_copy(s, start, string_length(s) - start + 1)));
        }
    }

    // Process each NAME(expr)
    for (var d = 0; d < array_length(defs); d++) {
        var item = defs[d];
        if (item == "") continue;

        var openPos  = string_pos("(", item);
        var closePos = string_last_pos(")", item);

        if (openPos <= 0 || closePos <= openPos) {
            show_debug_message("DIM ERROR: Expected NAME(expr), got: " + item);
            continue;
        }

        var nm_raw  = string_trim(string_copy(item, 1, openPos - 1));
        var nm      = string_upper(nm_raw);
        var lenExpr = string_copy(item, openPos + 1, (closePos - openPos - 1));
        var lenVal  = basic_evaluate_expression_v2(lenExpr);

        if (!is_real(lenVal)) {
            show_debug_message("DIM ERROR: Length expression not numeric for " + nm + " -> [" + lenExpr + "]");
            continue;
        }

        var n    = floor(max(0, lenVal));
        var size = n + 1; // inclusive upper bound (0..n)

        // Replace any existing ds_list to avoid leaks
        if (ds_map_exists(global.basic_arrays, nm)) {
            var _old = global.basic_arrays[? nm];
            if (ds_exists(_old, ds_type_list)) {
                ds_list_destroy(_old);
            }
        }

        // Create and zero-fill list
        var lst = ds_list_create();
        for (var i = 0; i < size; i++) ds_list_add(lst, 0);

        global.basic_arrays[? nm] = lst;

        show_debug_message("DIM: " + nm + " sized to " + string(size) + " (indices 0.." + string(n) + ")"
            + " | lenExpr=[" + lenExpr + "] -> " + string(lenVal));
    }
}
