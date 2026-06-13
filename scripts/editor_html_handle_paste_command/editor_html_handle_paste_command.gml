/// @function editor_html_handle_paste_command
// === BEGIN: editor_html_handle_paste_command ===
function editor_html_handle_paste_command() {
    // Desktop: not needed (Ctrl+V handled in Step event)
    if (os_browser == browser_not_a_browser) {
        editor_handle_paste_command();
        return;
    }
    // Browser: persistent Ctrl+V handler is always active from editor creation.
    // Just remind the user — no binding needed here.
    basic_show_message("Ctrl+V (Cmd+V on Mac) pastes at any time — URLs go into the command line; numbered BASIC programs are imported.");
    dbg_log(DBG_FLOW, "[PASTE] persistent handler already active");
}
// === END: editor_html_handle_paste_command ===
