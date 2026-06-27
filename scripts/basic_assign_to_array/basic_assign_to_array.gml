/// Helper function to assign values to arrays (BASIC-visible index is 1-based by default).
/// Supports 1D (varName="ARR(I)") and multi-D (varName="ARR(I,J)").
function basic_assign_to_array(varName, val) {
    var open_paren  = string_pos("(", varName);
    var close_paren = string_last_pos(")", varName);
    if (open_paren <= 0 || close_paren <= open_paren) {
        basic_syntax_error("Invalid array syntax: " + varName,
                           undefined,
                           global.interpreter_current_stmt_index,
                           "ARRAY_SYNTAX");
        return;
    }

    var arrayName = string_trim(string_copy(varName, 1, open_paren - 1));
    var indexExpr = string_trim(string_copy(varName, open_paren + 1, close_paren - open_paren - 1));
    var nm        = basic_normvar(arrayName);

    var _base = variable_global_exists("option_base") ? global.option_base : 1;

    basic_memory_ensure_map("basic_arrays");
    basic_memory_ensure_map("basic_array_dims");

    var flat_idx;

    if (string_pos(",", indexExpr) > 0) {
        var idx_parts = basic_split_top_commas(indexExpr);
        var ndims = array_length(idx_parts);

        var idx_vals = array_create(ndims, 0);
        for (var di = 0; di < ndims; di++) {
            var iv_tok  = basic_tokenize_expression_v2(string_trim(idx_parts[di]));
            var iv_post = infix_to_postfix(iv_tok);
            var iv_val  = evaluate_postfix(iv_post);
            if (!basic_is_number_val(iv_val)) {
                basic_syntax_error("Invalid array index expression: " + idx_parts[di],
                                   undefined, global.interpreter_current_stmt_index, "ARRAY_INDEX_EVAL");
                return;
            }
            idx_vals[di] = floor(real(iv_val));
        }

        if (!ds_map_exists(global.basic_arrays, nm)) {
            global.basic_arrays[? nm] = [];
            var auto_dims = array_create(ndims, 0);
            for (var di = 0; di < ndims; di++) auto_dims[di] = idx_vals[di] - _base + 1;
            global.basic_array_dims[? nm] = auto_dims;
        }

        var dims = global.basic_array_dims[? nm];
        if (array_length(dims) != ndims) {
            basic_syntax_error("Dimension mismatch for " + arrayName,
                               undefined, global.interpreter_current_stmt_index, "ARRAY_DIM_MISMATCH");
            return;
        }

        flat_idx = 0;
        var stride = 1;
        for (var di = ndims - 1; di >= 0; di--) {
            var iv = idx_vals[di] - _base;
            if (iv < 0) {
                basic_syntax_error("Array index below base for " + arrayName + " dim " + string(di),
                                   undefined, global.interpreter_current_stmt_index, "ARRAY_INDEX_RANGE");
                return;
            }
            flat_idx += iv * stride;
            stride *= dims[di];
        }

        var arr = global.basic_arrays[? nm];
        if (!is_array(arr)) {
            arr = [];
            global.basic_arrays[? nm] = arr;
        }
        var needed = flat_idx + 1;
        var _len = array_length(arr);
        while (_len < needed) {
            arr = array_resize(arr, _len + 1);
            arr[_len] = 0;
            _len++;
        }
        global.basic_arrays[? nm] = arr;

    } else {
        var indexTokens  = basic_tokenize_expression_v2(indexExpr);
        var indexPostfix = infix_to_postfix(indexTokens);
        var indexVal     = evaluate_postfix(indexPostfix);

        if (is_string(indexVal) || is_undefined(indexVal)) {
            basic_syntax_error("Invalid array index expression: " + indexExpr + " (evaluated to " + string(indexVal) + ")",
                               undefined, global.interpreter_current_stmt_index, "ARRAY_INDEX_EVAL");
            return;
        }

        var idx1 = floor(real(indexVal));
        if (!basic_is_number_val(idx1) || idx1 < _base) {
            basic_syntax_error("Array index must be >= " + string(_base) + " for " + arrayName + " (got " + string(indexVal) + ")",
                               undefined, global.interpreter_current_stmt_index, "ARRAY_INDEX_RANGE");
            return;
        }
        flat_idx = idx1 - _base;

        if (!ds_map_exists(global.basic_arrays, nm)) {
            global.basic_arrays[? nm] = [];
        }
        var arr = global.basic_arrays[? nm];
        if (!is_array(arr)) {
            arr = [];
            global.basic_arrays[? nm] = arr;
        }
        var _len = array_length(arr);
        while (_len <= flat_idx) {
            arr = array_resize(arr, _len + 1);
            arr[_len] = 0;
            _len++;
        }
        global.basic_arrays[? nm] = arr;
    }

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("ARRAY ASSIGN: " + nm + " flat_idx=" + string(flat_idx) + " val='" + string(val) + "'");
    }

    var arr = global.basic_arrays[? nm];
    var is_string_array = (string_length(nm) > 0)
                       && (string_char_at(nm, string_length(nm)) == "$");

    if (is_string_array) {
        arr[flat_idx] = string(val);
    } else {
        var numVal = is_real(val) ? val : (basic_looks_numeric(string(val)) ? real(val) : 0);
        arr[flat_idx] = numVal;
    }
    global.basic_arrays[? nm] = arr;
}