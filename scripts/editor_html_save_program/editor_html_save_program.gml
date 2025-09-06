/// @function editor_html_save_program
/// @desc HTML-only wrapper mirroring save_program()
/// Uses global current_filename (parity with desktop)
function editor_html_save_program() {
    if (os_browser == browser_not_a_browser) {
        show_error_message("HTML save is only available in browser builds.");
        return false;
    }
    if (!variable_global_exists("current_filename") || string_length(current_filename) == 0) {
        show_error_message("NO FILENAME");
        return false;
    }
    return editor_html_save_program_as(current_filename);
}
