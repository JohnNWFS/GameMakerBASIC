function basic_cmd_let(arg) {
    var eq_pos = string_pos("=", arg);

    if (eq_pos <= 0) {
        show_debug_message("?LET ERROR: No '=' in expression: " + arg);
        return;
    }

    var varname = string_upper(string_trim(string_copy(arg, 1, eq_pos - 1)));
    var expr = string_trim(string_copy(arg, eq_pos + 1, string_length(arg)));

    // Try evaluating the expression safely
    var tokens = string_split(expr, " ");
    var result = 0;
    
    if (array_length(tokens) == 1) {
        // Simple direct assignment: number or existing variable
        var val = tokens[0];
        if (ds_map_exists(global.basic_variables, string_upper(val))) {
            result = global.basic_variables[? string_upper(val)];
        } else {
            result = real(val);
        }
    } else if (array_length(tokens) == 3) {
        // Simple binary expression: a OP b
        var left = string_upper(tokens[0]);
        var op   = tokens[1];
        var right = string_upper(tokens[2]);

        var a = ds_map_exists(global.basic_variables, left) ? global.basic_variables[? left] : real(left);
        var b = ds_map_exists(global.basic_variables, right) ? global.basic_variables[? right] : real(right);

        switch (op) {
            case "+": result = a + b; break;
            case "-": result = a - b; break;
            case "*": result = a * b; break;
            case "/": result = (b != 0) ? a / b : 0; break;
            case "%": result = a mod b; break;
            default:
                show_debug_message("?LET ERROR: Unknown operator '" + op + "'");
                return;
        }
    } else {
        show_debug_message("?LET ERROR: Unsupported expression format: " + expr);
        return;
    }

    global.basic_variables[? varname] = result;
}
