function basic_evaluate_expression(expr) {
    expr = string_trim(expr);

    // Variable lookup
    if (ds_map_exists(global.basic_variables, string_upper(expr))) {
        return global.basic_variables[? string_upper(expr)];
    }

    // Handle MOD
    if (string_pos("MOD", string_upper(expr)) > 0) {
        var parts = string_split(string_upper(expr), "MOD");
        if (array_length(parts) == 2) {
            var a = real(basic_evaluate_expression_v2(parts[0]));
            var b = real(basic_evaluate_expression_v2(parts[1]));
            return a mod b;
        }
    }

    // Handle RND(n)
    if (string_upper(string_copy(expr, 1, 4)) == "RND(" && string_char_at(expr, string_length(expr)) == ")") {
        var inner = string_copy(expr, 5, string_length(expr) - 5);
        return irandom(real(basic_evaluate_expression_v2(inner)));
    }

    // Handle ABS(x)
    if (string_upper(string_copy(expr, 1, 4)) == "ABS(" && string_char_at(expr, string_length(expr)) == ")") {
        var inner = string_copy(expr, 5, string_length(expr) - 5);
        return abs(real(basic_evaluate_expression_v2(inner)));
    }

    // Fallback to real()
    return real(expr);
}
