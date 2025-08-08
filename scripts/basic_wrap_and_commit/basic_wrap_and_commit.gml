function basic_wrap_and_commit(_text, _color) {
    show_debug_message("=== basic_wrap_and_commit START ===");
    show_debug_message("Incoming text: " + string(_text));
    show_debug_message("Incoming color: " + string(_color));

    // Do NOT create here — avoid nuking prior output!
    if (is_undefined(global.output_lines) || !ds_exists(global.output_lines, ds_type_list)
    ||  is_undefined(global.output_colors) || !ds_exists(global.output_colors, ds_type_list)) {
        show_debug_message("basic_wrap_and_commit: output buffers not initialized; SKIPPING write.");
        show_debug_message("=== basic_wrap_and_commit END (skipped) ===");
        return;
    }

    var wrap_width = 40;
    var remaining = string(_text);
    show_debug_message("Initial remaining text: " + remaining);

    while (string_length(remaining) > wrap_width) {
        var line = string_copy(remaining, 1, wrap_width);
        show_debug_message("Adding wrapped line: '" + line + "'");
        ds_list_add(global.output_lines, line);
        ds_list_add(global.output_colors, _color);
        remaining = string_copy(remaining, wrap_width + 1, string_length(remaining) - wrap_width);
        show_debug_message("Remaining after wrap: '" + remaining + "'");
    }

    show_debug_message("Adding final line: '" + remaining + "'");
    ds_list_add(global.output_lines, remaining);
    ds_list_add(global.output_colors, _color);

    show_debug_message("=== basic_wrap_and_commit END ===");
}
