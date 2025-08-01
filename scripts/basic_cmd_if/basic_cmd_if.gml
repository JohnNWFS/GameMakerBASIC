function basic_cmd_if(arg) {
    show_debug_message("IF START — Raw arg: '" + arg + "'");

    var cond_str = string_trim(arg);
    var then_pos = string_pos("THEN", string_upper(cond_str));

    if (then_pos <= 0) {
        show_debug_message("?IF ERROR: Missing THEN in '" + cond_str + "'");
        return;
    }

    var condition = string_trim(string_copy(cond_str, 1, then_pos - 1));
    var action = string_trim(string_copy(cond_str, then_pos + 4, string_length(cond_str)));

    show_debug_message("Parsed condition: '" + condition + "'");
    show_debug_message("Parsed action: '" + action + "'");

    // Find operator
    var ops = ["<=", ">=", "<", ">", "==", "="];
    var op = "";
    for (var i = 0; i < array_length(ops); i++) {
        if (string_pos(ops[i], condition) > 0) {
            op = ops[i];
            break;
        }
    }

    if (op == "") {
        show_debug_message("?IF ERROR: No valid operator in '" + condition + "'");
        return;
    }

    var parts = string_split(condition, op);
    if (array_length(parts) != 2) {
        show_debug_message("?IF ERROR: Malformed condition: '" + condition + "'");
        return;
    }

    var left = string_trim(parts[0]);
    var right = string_trim(parts[1]);

    var left_eval = basic_evaluate_expression_v2(left);
    var right_eval = basic_evaluate_expression_v2(right);

    var a = real(left_eval);
    var b = real(right_eval);

    show_debug_message("Evaluating: " + string(a) + " " + op + " " + string(b));

    var result = false;
    switch (op) {
        case "<":  result = a < b;  break;
        case ">":  result = a > b;  break;
        case "<=": result = a <= b; break;
        case ">=": result = a >= b; break;
        case "==":
        case "=":  result = a == b; break;
    }

    show_debug_message("Condition result: " + string(result));

    if (result) {
        var prefix = string_upper(string_copy(action, 1, 4));
        var target = string_trim(string_copy(action, 6, string_length(action)));

        show_debug_message("THEN command: " + prefix + ", target: " + target);

        if (prefix == "GOTO") {
            var line_target = real(target);
            var index = ds_list_find_index(global.line_list, line_target);

            if (index >= 0) {
                interpreter_next_line = index;
                show_debug_message("GOTO from IF → line " + string(line_target) + " (index " + string(index) + ")");
            } else {
                show_debug_message("?IF ERROR: GOTO target line not found: " + string(line_target));
            }
        } else {
            show_debug_message("?IF ERROR: THEN action not supported yet: '" + action + "'");
        }
    } else {
        show_debug_message("IF condition was FALSE — no action taken.");
    }
}
