if (showing_dir_overlay) {
    // Basic style
    var W = display_get_gui_width();
    var H = display_get_gui_height();
    var pad = 16;
    var box_w = min(720, W - pad * 2);
    var box_h = min(520, H - pad * 2);
    var bx = (W - box_w) * 0.5;
    var by = (H - box_h) * 0.5;

    // Backdrop
    draw_set_alpha(0.60);
    draw_set_color(c_black);
    draw_rectangle(0, 0, W, H, false);

    // Panel
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(24,24,24));
    draw_roundrect(bx, by, bx + box_w, by + box_h, false);
    draw_set_color(c_white);

    // Title
    var title = "FILES (↑/↓ select, Enter open, Esc close)";
    draw_text(bx + pad, by + pad, title);

    // List - use dir_listing array
    if (variable_instance_exists(id, "dir_listing") && is_array(dir_listing)) {
        var n = array_length(dir_listing);
        var row_h = 22;
        var max_rows = floor((box_h - pad*3) / row_h);
        var start = clamp(dir_sel - floor(max_rows/2), 0, max(0, n - max_rows));
        var _y = by + pad*2;

        for (var i = 0; i < max_rows && (start + i) < n; i++) {
            var idx = start + i;
            var filename = dir_listing[idx];
            
            // For HTML files, get size from global.html_dir_files
            var file_size = "? bytes";
            if (variable_global_exists("html_dir_files") && ds_list_size(global.html_dir_files) > idx) {
                var rec = global.html_dir_files[| idx];
                if (ds_exists(rec, ds_type_map)) {
                    file_size = string(ds_map_find_value(rec, "size")) + " bytes";
                }
            }

            // highlight selected row
            if (idx == dir_sel) {
                draw_set_color(make_color_rgb(48,96,160));
                draw_rectangle(bx + pad - 6, _y - 2, bx + box_w - pad, _y + row_h - 4, false);
                draw_set_color(c_white);
            }

            draw_text(bx + pad, _y, string(idx + 1) + ". " + string(filename) + "  (" + file_size + ")");
            _y += row_h;
        }
    }
}