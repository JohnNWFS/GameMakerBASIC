function editor_html_dir_show() {
    if (os_browser == browser_not_a_browser) {
        show_error_message("HTML DIR is only available in browser builds.");
        return false;
    }
    if (!variable_global_exists("html_dir_files") || ds_list_size(global.html_dir_files) == 0) {
        basic_show_message("No files selected. Use DIR to choose files first.");
        return false;
    }

    var ed = instance_find(obj_editor, 0);
    if (ed == noone) return false;

    // Initialize directory variables
    ed.dir_listing = [];
    ed.showing_dir_overlay = false;
    ed.dir_save_dir = "";

    // Build listing from html_dir_files
    var n = ds_list_size(global.html_dir_files);
    for (var i = 0; i < n; i++) {
        var rec = global.html_dir_files[| i];
        var filename = ds_map_find_value(rec, "name");
        array_push(ed.dir_listing, filename);
    }
    
    if (n == 0) {
        array_push(ed.dir_listing, "No .bas files found.");
    }

    // Initialize overlay state
    ed.dir_sel = 0;
    ed.dir_page = 0;
    ed.dir_page_size = 1;
    ed.dir_sorted_by = "name";
    ed.dir_filter = "";
    ed.dir_preview_on = false;
    ed.dir_confirm_active = false;
    ed.dir_confirm_index = -1;
    ed.dir_mouse_hover_row = -1;
    ed.dir_mouse_hover_action = "";

    // Show the overlay
    ed.showing_dir_overlay = true;
    return true;
}