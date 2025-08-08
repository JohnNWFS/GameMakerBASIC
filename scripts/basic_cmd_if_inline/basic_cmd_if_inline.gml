/// @script basic_cmd_if_inline
/// @description Legacy single-line IF…THEN…ELSE handler
function basic_cmd_if_inline(arg) {
    show_debug_message("INLINE IF — Raw arg: '" + arg + "'");

    var cond_str = string_trim(arg);
    var then_pos = string_pos("THEN", string_upper(cond_str));
    if (then_pos <= 0) {
        show_debug_message("?IF ERROR: Missing THEN in '" + cond_str + "'");
        return;
    }

    var else_pos = string_pos("ELSE", string_upper(cond_str));

    var condition = string_trim(string_copy(cond_str, 1, then_pos - 1));
    var then_action, else_action;

    if (else_pos > 0 && else_pos > then_pos) {
        then_action = string_trim(string_copy(cond_str, then_pos + 4, else_pos - then_pos - 4));
        else_action = string_trim(string_copy(cond_str, else_pos + 4, string_length(cond_str)));
    } else {
        then_action = string_trim(string_copy(cond_str, then_pos + 4, string_length(cond_str)));
        else_action = "";
    }

    show_debug_message("Parsed condition: '" + condition + "'");
    show_debug_message("Parsed THEN: '" + then_action + "'");
    show_debug_message("Parsed ELSE: '" + else_action + "'");

    // Detect and evaluate compound conditions
    var logic_op = "";
    var result = false;
    var upper_cond = string_upper(condition);

    if (string_pos("AND", upper_cond) > 0) logic_op = "AND";
    else if (string_pos("OR", upper_cond) > 0) logic_op = "OR";

    if (logic_op != "") {
        var cond_parts = string_split(condition, logic_op);
        if (array_length(cond_parts) != 2) {
            show_debug_message("?IF ERROR: Malformed " + logic_op + " condition: '" + condition + "'");
            return;
        }

        var res1 = basic_evaluate_condition(string_trim(cond_parts[0]));
        var res2 = basic_evaluate_condition(string_trim(cond_parts[1]));
        result = (logic_op == "AND") ? (res1 && res2) : (res1 || res2);

        show_debug_message("Combined condition (" + logic_op + "): " + string(res1) + " " + logic_op + " " + string(res2) + " = " + string(result));
    } else {
        result = basic_evaluate_condition(condition);
        show_debug_message("Single condition result: " + string(result));
    }

    var final_action = result ? then_action : else_action;
    if (final_action == "") {
        show_debug_message("No action to execute for this branch.");
        return;
    }

    show_debug_message((result ? "THEN" : "ELSE") + " executing: '" + final_action + "'");

    // Parse the action into command and arguments
    var sp = string_pos(" ", final_action);
    var cmd = (sp > 0) ? string_upper(string_copy(final_action, 1, sp - 1)) : string_upper(final_action);
    var action_arg = (sp > 0) ? string_trim(string_copy(final_action, sp + 1, string_length(final_action))) : "";

    show_debug_message("Parsed - cmd: '" + cmd + "', arg: '" + action_arg + "'");

    if (cmd == "GOTO") {
        var line_target = real(action_arg);
        var index = ds_list_find_index(global.line_list, line_target);
        if (index >= 0) {
            interpreter_next_line = index;
            show_debug_message("GOTO from IF → line " + string(line_target) + " (index " + string(index) + ")");
        } else {
            show_debug_message("?IF ERROR: GOTO target line not found: " + string(line_target));
        }
    } else {
        handle_basic_command(cmd, action_arg);
    }
} 