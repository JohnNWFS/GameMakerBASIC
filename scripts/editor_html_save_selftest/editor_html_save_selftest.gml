/// @function editor_html_save_selftest()
function editor_html_save_selftest() {
    if (function_exists("browser_file_tools_init")) browser_file_tools_init();
    if (!function_exists("browser_show_save_dialog")) {
        show_error_message("Save dialog function not present.");
        return;
    }
    var s = "HELLO\r\n";
    var n = string_length(s);
    var b = buffer_create(n, buffer_fixed, 1);
    for (var i = 1; i <= n; i++) buffer_write(b, buffer_u8, ord(string_char_at(s, i)));
    buffer_seek(b, buffer_seek_start, 0);
    browser_show_save_dialog(b, "selftest.bas", "text/plain; charset=utf-8", n);
    buffer_delete(b);
    basic_show_message("Save self-test offered.");
}
