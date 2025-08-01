function basic_evaluate_condition(expr) {
    var tokens = string_split(expr, " ");
	
	
	
    if (array_length(tokens) == 3) {
        var lhs = string_trim(tokens[0]);
        var op  = string_trim(tokens[1]);
        var rhs = string_trim(tokens[2]);

		lhs = string_upper(lhs);
		rhs = string_upper(rhs);

		if (ds_map_exists(global.basic_variables, lhs)) lhs = string(global.basic_variables[? lhs]);
		if (ds_map_exists(global.basic_variables, rhs)) rhs = string(global.basic_variables[? rhs]);

		// Evaluate math functions if present
		lhs = string(basic_evaluate_expression_v2(lhs));
		rhs = string(basic_evaluate_expression_v2(rhs));

		lhs = real(lhs);
		rhs = real(rhs);


        switch (op) {
            case "=": return lhs == rhs;
            case "<": return lhs < rhs;
            case ">": return lhs > rhs;
            case "<=": return lhs <= rhs;
            case ">=": return lhs >= rhs;
            case "<>": return lhs != rhs;
			case "MOD": return lhs % rhs;
        }
    }
	
	// Support for unary functions: ABS(x), RND(x)
if (array_length(tokens) == 1) {
    var single = string_upper(string_trim(tokens[0]));

    if (string_pos("ABS(", single) == 1) {
        var inside = string_copy(single, 5, string_length(single) - 5); // strip ABS(
        inside = string_delete(inside, string_length(inside), 1); // remove closing )
        var val = real(inside);
        return abs(val);
    }

    if (string_pos("RND(", single) == 1) {
        var inside = string_copy(single, 5, string_length(single) - 5); // strip RND(
        inside = string_delete(inside, string_length(inside), 1); // remove closing )
        var val = real(inside);
        return irandom(val);
    }
}


    return false;
}
