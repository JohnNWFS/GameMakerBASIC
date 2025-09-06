function basic_wrap_and_commit(_text, _color) {
    if (dbg_on(DBG_FLOW)) show_debug_message("=== basic_wrap_and_commit START ===");

    // Output buffers must already exist
    if (is_undefined(global.output_lines) || !ds_exists(global.output_lines, ds_type_list)
    ||  is_undefined(global.output_colors) || !ds_exists(global.output_colors, ds_type_list)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("wrap: buffers not initialized; SKIP");
        return;
    }

    // Width: default 64 unless caller set global.wrap_width
    var wrap_width = (variable_global_exists("wrap_width") && is_real(global.wrap_width) && global.wrap_width > 0)
        ? floor(global.wrap_width) : 70;

    var remaining = string(_text);

    while (string_length(remaining) > wrap_width) {
        var len_rem = string_length(remaining);
        var cut = wrap_width;
        var last_space = 0;
        var found_space = false;

        // Find the last space at or before wrap_width
        var p = min(wrap_width, len_rem);
        for (; p >= 1; p--) {
            if (string_char_at(remaining, p) == " ") { last_space = p; break; }
        }

        if (last_space > 0) {
            // Break on that space (exclude it)
            cut = last_space - 1;
            found_space = true;
        } else {
            // Hard break … but avoid dangling punctuation on next line
            var next_char = (wrap_width + 1 <= len_rem) ? string_char_at(remaining, wrap_width + 1) : "";
            if (next_char == ")" || next_char == "]" || next_char == "}" ||
                next_char == "!" || next_char == "?" || next_char == "." ||
                next_char == "," || next_char == ":" || next_char == ";") {
                var back = wrap_width;
                while (back > 1 && string_char_at(remaining, back) != " ") back--;
                if (back > 1) {
                    cut = back - 1;   // exclude that space
                    found_space = true;
                }
            }
        }

        if (cut < 1) cut = wrap_width; // safety for huge first word

        var line = string_copy(remaining, 1, cut);
        ds_list_add(global.output_lines, line);
        ds_list_add(global.output_colors, _color);

        // Advance; skip the space when we broke on a space
        var next_start = cut + (found_space ? 2 : 1);
        if (next_start <= len_rem) {
            remaining = string_copy(remaining, next_start, len_rem - (next_start - 1));
        } else {
            remaining = "";
        }

        // Trim any leading spaces on the next line
        while (string_length(remaining) > 0 && string_char_at(remaining, 1) == " ") {
            remaining = string_copy(remaining, 2, string_length(remaining) - 1);
        }
    }

    // Tail
    ds_list_add(global.output_lines, remaining);
    ds_list_add(global.output_colors, _color);
}
