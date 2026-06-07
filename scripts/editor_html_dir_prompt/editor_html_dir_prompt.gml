function editor_html_dir_prompt() {
    dbg_log(DBG_FLOW, "[ENTER] editor_html_dir_prompt");

    if (os_browser == browser_not_a_browser) {
        show_error_message("HTML DIR is only available in browser builds.");
        dbg_log(DBG_FLOW, "[EXIT] editor_html_dir_prompt (not browser)");
        return false;
    }

    // --- Re-entrancy guard: prevent duplicate dialogs for a single DIR dispatch
    if (!variable_global_exists("__html_dir_opening")) global.__html_dir_opening = false;
    if (global.__html_dir_opening) {
        dbg_log(DBG_FLOW, "[DIR/HTML] prompt suppressed (already opening)");
        dbg_log(DBG_FLOW, "[EXIT] editor_html_dir_prompt (guard)");
        return false;
    }
    global.__html_dir_opening = true;

    // --- Init extension (safe to call repeatedly)
    browser_file_tools_init();

    // --- Reset cached list (destroy old maps, clear list)
    editor_html_dir__reset();

    // --- Open dialog (multiselect = true). Accept .bas and text/plain
    browser_show_open_dialog(
        ".bas,text/plain",
        true,
        editor_html_dir__open_handler,   // persistent handler; will clear the guard
        editor_html_dir__open_filter
    );

    // Show the warning message about potential bugs using BASIC interpreter's message system
    basic_show_message("If Load fails, try again: bugs.");

    dbg_log(DBG_FLOW, "[DIR/HTML] open dialog shown");
    dbg_log(DBG_FLOW, "[EXIT] editor_html_dir_prompt");
    return true;
}