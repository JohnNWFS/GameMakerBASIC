function editor_html_save_program_as(filename) {
    if (os_browser == browser_not_a_browser) {
        show_error_message("HTML save is only available in browser builds.");
        return false;
    }

    // Initialize the extension (safe to call each time; no-op if already inited)
    browser_file_tools_init();

    // --- Normalize filename (parity with desktop)
    filename = string_trim(filename);
    if (string_length(filename) == 0) { show_error_message("NO FILENAME PROVIDED"); return false; }
    if (string_char_at(filename, 1) == "\"" && string_char_at(filename, string_length(filename)) == "\"") {
        filename = string_copy(filename, 2, string_length(filename) - 2);
    }
    filename = string_replace_all(filename, "/",  "_");
    filename = string_replace_all(filename, "\\", "_");
    filename = string_replace_all(filename, "..", "_");
    filename = string_replace_all(filename, ".bas", "");
    filename = filename + ".bas";

    // --- Build program text
    var text = editor_html_build_program_text();
    if (string_length(text) == 0) {
        show_error_message("NOTHING TO SAVE — no program lines found");
        return false;
    }

    // --- Create byte buffer (CRLF preserved)
    var n = string_length(text);
    var buf = buffer_create(n, buffer_fixed, 1);
    for (var i = 1; i <= n; i++) {
        buffer_write(buf, buffer_u8, ord(string_char_at(text, i)));
    }
    buffer_seek(buf, buffer_seek_start, 0);

    // --- Call the YAL wrapper directly (wrapper is present in your build)
    browser_show_save_dialog(buf, filename, "text/plain; charset=utf-8", n);

    buffer_delete(buf);
    return true;
}
