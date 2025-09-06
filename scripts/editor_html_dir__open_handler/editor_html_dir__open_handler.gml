function editor_html_dir__open_handler(data, name, type) {
    if (dbg_on(DBG_FLOW)) show_debug_message("[ENTER] editor_html_dir__open_handler");
    
    // clear the guard immediately on first callback
    if (variable_global_exists("__html_dir_opening")) global.__html_dir_opening = false;

    if (is_undefined(name)) { // defensive
        if (dbg_on(DBG_FLOW)) show_debug_message("[EXIT] editor_html_dir__open_handler (undefined name)");
        return;
    }

    if (!variable_global_exists("html_dir_files")) global.html_dir_files = ds_list_create();
    var rec = ds_map_create();
    ds_map_set(rec, "name", name);
    ds_map_set(rec, "type", type);
    ds_map_set(rec, "data", data);

    // estimate size from base64 length (as before)
    var size_est = 0, comma = string_pos(",", data);
    if (comma > 0) {
        var b64 = string_copy(data, comma + 1, string_length(data) - comma);
        var L = string_length(b64), pad = 0;
        if (L >= 1 && string_char_at(b64, L) == "=") pad++;
        if (L >= 2 && string_char_at(b64, L - 1) == "=") pad++;
        size_est = max(0, floor(L * 3 / 4) - pad);
    }
    ds_map_set(rec, "size", size_est);

    ds_list_add(global.html_dir_files, rec);
    if (dbg_on(DBG_FLOW)) show_debug_message("[DIR/HTML] added '" + name + "' (" + string(size_est) + " bytes)");

    // After all files are loaded, automatically show the directory overlay
    // Use call_later to ensure all files are processed first
    if (!variable_global_exists("__html_dir_auto_show_scheduled") || !global.__html_dir_auto_show_scheduled) {
        global.__html_dir_auto_show_scheduled = true;
        
        // Schedule the directory show for next frame
        call_later(1, time_source_units_frames, function() {
            // Only show if we have .bas files
            if (variable_global_exists("html_dir_files") && ds_list_size(global.html_dir_files) > 0) {
                var has_bas_files = false;
                var n = ds_list_size(global.html_dir_files);
                for (var i = 0; i < n; i++) {
                    var rec = global.html_dir_files[| i];
                    var filename = ds_map_find_value(rec, "name");
                    if (string_pos(".bas", string_lower(filename)) > 0) {
                        has_bas_files = true;
                        break;
                    }
                }
                
                if (has_bas_files) {
                    editor_html_dir_show();
                    basic_show_message("Files loaded. Use arrows to select, Enter to open.");
                } else {
                    basic_show_message("Files selected, but no .bas files found.");
                }
            }
            global.__html_dir_auto_show_scheduled = false;
        });
    }
    
    if (dbg_on(DBG_FLOW)) show_debug_message("[EXIT] editor_html_dir__open_handler");
}