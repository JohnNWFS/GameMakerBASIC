/// Helper function to assign values to arrays (BASIC-visible index is 1-based)
function basic_assign_to_array(varName, val) {
    // Parse array name and index from varName like "TOPIC$(I)"
    var open_paren  = string_pos("(", varName);
    var close_paren = string_pos(")", varName);
    if (open_paren <= 0 || close_paren <= open_paren) {
        // 4-arg syntax error: message, line_no, stmt_idx, code
        basic_syntax_error("Invalid array syntax: " + varName,
                           /*line_no*/ undefined,
                           /*stmt_idx*/ global.interpreter_current_stmt_index,
                           "ARRAY_SYNTAX");
        return;
    }

    var arrayName = string_trim(string_copy(varName, 1, open_paren - 1));
    var indexExpr = string_trim(string_copy(varName, open_paren + 1, close_paren - open_paren - 1));

    // Normalize array name used in your maps
    var normalizedArrayName = basic_normvar(arrayName);

    // Evaluate index expression (BASIC-side index, expected 1..N)
    var indexTokens  = basic_tokenize_expression_v2(indexExpr);
    var indexPostfix = infix_to_postfix(indexTokens);
    var indexVal     = evaluate_postfix(indexPostfix);

    // Coerce to integer and enforce 1-based external indexing
    var idx1 = floor(real(indexVal));
    if (!is_real(idx1) || idx1 < 1) {
        basic_syntax_error("Array index must be >= 1 for " + arrayName + " (got " + string(indexVal) + ")",
                           /*line_no*/ undefined,
                           /*stmt_idx*/ global.interpreter_current_stmt_index,
                           "ARRAY_INDEX_RANGE");
        return;
    }

    // Convert to 0-based for ds_list
    var ds_idx = idx1 - 1;

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("ARRAY ASSIGN: Array='" + normalizedArrayName
            + "' BASIC-idx=" + string(idx1) + " (ds_idx=" + string(ds_idx)
            + ") Value='" + string(val) + "'");
    }

    // Ensure the array map/list exists
    if (!ds_map_exists(global.basic_arrays, normalizedArrayName)) {
        global.basic_arrays[? normalizedArrayName] = ds_list_create();
        if (dbg_on(DBG_FLOW)) show_debug_message("ARRAY ASSIGN: Created array '" + normalizedArrayName + "'");
    }

    var arrayList = global.basic_arrays[? normalizedArrayName];

    // Ensure capacity up to ds_idx (0-based)
    while (ds_list_size(arrayList) <= ds_idx) {
        ds_list_add(arrayList, 0); // default fill
    }

    // String arrays end with $, numeric otherwise
    var is_string_array = (string_length(normalizedArrayName) > 0)
                       && (string_char_at(normalizedArrayName, string_length(normalizedArrayName)) == "$");

    if (is_string_array) {
        ds_list_replace(arrayList, ds_idx, string(val));
        if (dbg_on(DBG_FLOW)) show_debug_message("ARRAY ASSIGN: " + normalizedArrayName + "[" + string(idx1) + "] (ds " + string(ds_idx) + ") = '" + string(val) + "' (string)");
    } else {
        var numVal = is_real(val) ? val : (basic_looks_numeric(string(val)) ? real(val) : 0);
        ds_list_replace(arrayList, ds_idx, numVal);
        if (dbg_on(DBG_FLOW)) show_debug_message("ARRAY ASSIGN: " + normalizedArrayName + "[" + string(idx1) + "] (ds " + string(ds_idx) + ") = " + string(numVal) + " (numeric)");
    }
}
