/// Load a selected file (by 1-based index or exact filename) into program_lines/line_numbers
function editor_html_dir_open(which) {
    if (os_browser == browser_not_a_browser) {
        show_error_message("HTML DIR is only available in browser builds.");
        return false;
    }
    if (!variable_global_exists("html_dir_files") || ds_list_size(global.html_dir_files) == 0) {
        show_message("No files selected. Use DIR to choose files first.");
        return false;
    }

    var idx = -1, n = ds_list_size(global.html_dir_files);
    var w = string_trim(which), W = string_upper(w);

    // numeric index (1-based)
    if (string_digits(w) == w) {
        var k = real(w);
        if (k >= 1 && k <= n) idx = k - 1;
    }
    // filename match
    if (idx < 0) {
        for (var i = 0; i < n; i++) {
            var rec_i = global.html_dir_files[| i];
            if (string_upper(ds_map_find_value(rec_i, "name")) == W) { idx = i; break; }
        }
    }
    if (idx < 0) { show_message("Not found. Use DIR SHOW to see indexes."); return false; }

    var rec = global.html_dir_files[| idx];
    var text = editor_html_decode_data_url_to_text(ds_map_find_value(rec, "data"));
    if (string_length(text) <= 0) {
        show_message("Unable to read file text.");
        return false;
    }

    // Parse exactly like your paste/Windows path
    var lines = string_split(text, "\n");
   if (dbg_on(DBG_FLOW)) show_debug_message("LOAD(HTML): captured " + string(array_length(lines)) + " raw lines");

    for (var j = 0; j < array_length(lines); j++) {
        var line = string_trim(lines[j]);
        if (string_length(line) == 0) continue;

        var space_pos = string_pos(" ", line);
        if (space_pos > 0) {
            var ln_str = string_copy(line, 1, space_pos - 1);
            var code   = string_copy(line, space_pos + 1, string_length(line) - space_pos);

            if (string_length(code) > 0 && string_char_at(code, string_length(code)) == chr(13)) {
                code = string_copy(code, 1, string_length(code) - 1);
            }

            if (string_digits(ln_str) == ln_str) {
                var _ln = real(ln_str);
                if (_ln > 0 && string_length(code) > 0) {
                    ds_map_set(global.program_lines, _ln, code);
                    var found = ds_list_find_index(global.line_numbers, _ln);
                    if (found == -1) { ds_list_add(global.line_numbers, _ln); ds_list_sort(global.line_numbers, true); }
                }
            }
        }
    }

    basic_show_message("Program loaded: " + ds_map_find_value(rec, "name"));
    return true;
}
