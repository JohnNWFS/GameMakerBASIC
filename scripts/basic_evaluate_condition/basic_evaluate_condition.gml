function basic_evaluate_condition(expr) {
    var tokens = string_split(expr, " ");
	
	
	
    if (array_length(tokens) == 3) {
        var lhs = string_trim(tokens[0]);
        var op  = string_trim(tokens[1]);
        var rhs = string_trim(tokens[2]);

// 1) Evaluate both sides as full expressions
var lhs_val = basic_evaluate_expression_v2(lhs);
var rhs_val = basic_evaluate_expression_v2(rhs);

// 2) Turn them into strings for inspection
var lhs_str = string(lhs_val);
var rhs_str = string(rhs_val);

// 3) Check if each is numeric
var lhs_is_num = is_numeric_string(lhs_str);
var rhs_is_num = is_numeric_string(rhs_str);

// 4) If either side isn’t numeric, do only = / <> string compares
if (!lhs_is_num || !rhs_is_num) {
    switch (op) {
        case "=":  return lhs_str == rhs_str;
        case "<>": return lhs_str != rhs_str;
        default:   return false;  // no ordering on strings
    }
}

// 5) Otherwise both are numeric—coerce and compare
var lhs_num = real(lhs_str);
var rhs_num = real(rhs_str);
switch (op) {
    case "=":  return lhs_num == rhs_num;
    case "<":  return lhs_num <  rhs_num;
    case ">":  return lhs_num >  rhs_num;
    case "<=": return lhs_num <= rhs_num;
    case ">=": return lhs_num >= rhs_num;
    case "MOD": return lhs_num mod rhs_num;
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
