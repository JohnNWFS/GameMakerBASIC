/// @function basic_cmd_dim(rest)
/// @description DIM NAME(d1[,d2,...]) or multiple declarations comma-separated at top level.
/// Stores flat native GML array with row-major layout; dimension sizes in global.basic_array_dims.
/// Inclusive upper bound per dimension: DIM A(3,4) => valid indices (1..3, 1..4) with OPTION BASE 1.
function basic_cmd_dim(rest) {
    var s = string_trim(rest);
    if (s == "") {
        dbg_log(DBG_FLOW, "DIM ERROR: Missing arguments");
        return;
    }

    basic_memory_ensure_map("basic_arrays");
    basic_memory_ensure_map("basic_array_dims");

    // Split on top-level commas (ignore commas inside parentheses)
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
        if (start <= string_length(s)) {
            array_push(defs, string_trim(string_copy(s, start, string_length(s) - start + 1)));
        }
    }

    for (var d = 0; d < array_length(defs); d++) {
        var item = defs[d];
        if (item == "") continue;

        var openPos  = string_pos("(", item);
        var closePos = string_last_pos(")", item);

        if (openPos <= 0 || closePos <= openPos) {
            dbg_log(DBG_FLOW, "DIM ERROR: Expected NAME(expr[,...]), got: " + item);
            continue;
        }

        var nm     = string_upper(string_trim(string_copy(item, 1, openPos - 1)));
        var inside = string_copy(item, openPos + 1, closePos - openPos - 1);

        // Parse comma-separated dimension expressions
        var dim_exprs = string_split(inside, ",");
        var dims = [];
        var total = 1;
        var ok = true;
        for (var di = 0; di < array_length(dim_exprs); di++) {
            var dexpr = string_trim(dim_exprs[di]);
            var dval  = basic_evaluate_expression_v2(dexpr);
            if (!is_real(dval)) {
                dbg_log(DBG_FLOW, "DIM ERROR: Non-numeric dimension for " + nm + ": " + dexpr);
                ok = false; break;
            }
            var n = floor(max(0, dval));
            array_push(dims, n + 1);
            total *= (n + 1);
        }
        if (!ok || total <= 0) continue;

        if (ds_map_exists(global.basic_arrays, nm)) {
            basic_array_release_storage(global.basic_arrays[? nm]);
        }

        global.basic_arrays[? nm]     = array_create(total, 0);
        global.basic_array_dims[? nm] = dims;

        if (dbg_on(DBG_FLOW)) {
            var _dstr = "";
            for (var di = 0; di < array_length(dims); di++) {
                if (di > 0) _dstr += ",";
                _dstr += string(dims[di]);
            }
            show_debug_message("DIM: " + nm + " dims=[" + _dstr + "] total=" + string(total));
        }
    }
}