function safe_real_pop(stack) {
    if (array_length(stack) < 1) return 1;

    var raw = array_pop(stack);

    // Pass through real values
    if (is_real(raw)) return raw;

    // Try to convert string safely
    var str = string(raw);
    var tryval = real(str);

    if (is_nan(tryval)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("? safe_real_pop: Cannot convert '" + string(raw) + "' to number. Returning 0.");
        return 0;
    }

    // Handle invalid conversions like real("RND:")
    if (!is_numeric_string(str)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("? POSTFIX ERROR: Cannot convert to number: '" + str + "'");
        return 1; // or return 0 if you prefer a neutral fallback
    }

    return tryval;
}
