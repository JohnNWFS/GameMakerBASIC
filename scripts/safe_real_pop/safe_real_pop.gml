function safe_real_pop(stack) {
    if (array_length(stack) < 1) return 1;

    var raw = array_pop(stack);

    // Pass through real values
    if (is_real(raw)) return raw;

    // Try to convert string safely
    var str = string_trim(string(raw));
    if (!is_numeric_string(str)) {
        dbg_log(DBG_FLOW, "? POSTFIX ERROR: Cannot convert to number: '" + str + "'");
        return 1; // or return 0 if you prefer a neutral fallback
    }

    return real(str);
}

function basic_arg_error(command_name, message, hint_key) {
    if (is_undefined(hint_key)) hint_key = command_name + "_ARGS";
    basic_syntax_error(command_name + ": " + message, global.current_line_number, global.interpreter_current_stmt_index, hint_key);
}

function basic_require_arg_count(args, command_name, min_count, max_count, syntax_text) {
    var count = array_length(args);
    if (count < min_count || (max_count >= 0 && count > max_count)) {
        basic_arg_error(command_name, "expected " + syntax_text, command_name + "_ARGS");
        return false;
    }
    return true;
}

function basic_eval_number_arg(expr, command_name, arg_name) {
    var expr_text = string_trim(string(expr));
    if (expr_text == "") {
        basic_arg_error(command_name, arg_name + " must be numeric");
        return { ok: false, value: 0 };
    }

    var value = basic_evaluate_expression_v2(expr_text);
    if (is_real(value)) {
        return { ok: true, value: value };
    }

    var value_text = string_trim(string(value));
    if (is_numeric_string(value_text)) {
        return { ok: true, value: real(value_text) };
    }

    basic_arg_error(command_name, arg_name + " must be numeric; got '" + expr_text + "'");
    return { ok: false, value: 0 };
}

function basic_eval_int_arg(expr, command_name, arg_name) {
    var result = basic_eval_number_arg(expr, command_name, arg_name);
    if (!result.ok) return result;
    result.value = floor(result.value);
    return result;
}

function basic_eval_bool_arg(expr, command_name, arg_name) {
    var result = basic_eval_number_arg(expr, command_name, arg_name);
    if (!result.ok) return result;
    result.value = (result.value != 0);
    return result;
}
