function editor_handle_paste_command() {
    if (os_browser != browser_not_a_browser) {
        show_error_message("Use :PASTE to open paste box in browser.");
        return;
    }

    var raw_clip = clipboard_get_text();
    editor__apply_pasted_text(raw_clip);
}