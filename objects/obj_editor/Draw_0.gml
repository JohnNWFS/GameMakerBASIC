/// @event obj_editor/Draw
// Pause regular editor drawing when screen editor is active
if (global.screen_edit_mode) {
    //if (dbg_on(DBG_FLOW)) show_debug_message("EDITOR: Screen edit mode active, pausing regular editor draw");
    exit;
}


// Set font and calculate actual height
draw_set_font(fnt_basic);
var actual_font_height = string_height("A"); // Get real font height
draw_set_color(make_color_rgb(255, 191, 64));
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);

if (showing_dir_overlay) {
    // Modal backdrop
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);

	draw_set_font(fnt_basic_12); // smaller font for directory overlay
	draw_set_color(c_lime);


    var x_pad = 16;
    var y_pad = 16;

	// Split header across two lines for readability
	var header1 = "DIR: " + dir_save_dir;
	var header2 = "Files: " + string(array_length(dir_listing))
	    + " | Sel: " + string(dir_sel + 1) + "/" + string(max(1, array_length(dir_listing)))
	    + " | Keys: Arrows Move  Enter=>Load  D/X=>Delete  ESC Close";

	draw_text(x_pad, y_pad, header1);
	draw_text(x_pad, y_pad + string_height("A"), header2);


    // Compute rows/page (ASCII)
    var row_h       = string_height("A");
    var top_y       = y_pad + row_h * 3;
    var bottom_y    = room_height - y_pad - row_h * 2;
    var list_height = max(row_h, bottom_y - top_y);
    var rows_per_pg = max(1, floor(list_height / row_h));
    dir_page_size   = rows_per_pg; // expose for Step input

    // Clamp selection and compute page from sel
    var total = array_length(dir_listing);
    dir_sel = clamp(dir_sel, 0, max(0, total - 1));
    var first_index = (dir_sel div rows_per_pg) * rows_per_pg;
    var last_index  = min(total - 1, first_index + rows_per_pg - 1);

    // Borders (ASCII box)
    var left_x  = x_pad;
    var right_x = room_width - x_pad;
    // top border
    draw_text(left_x, top_y - row_h, "+-------------------------------------------+");
    // list rows
    var draw_y = top_y;
    for (var i = first_index; i <= last_index; i++) {
        var idx3 = string_format(string(i + 1), 3, 0); // 001, 002...
        var name = dir_listing[i];

        // Assemble row: index, filename (trim), actions
        var action_txt = "   >  X";
        var max_name_px = (right_x - left_x) - string_width(idx3 + " ") - string_width(action_txt) - 24;
        var name_trim = name;

        // crude pixel trimming to fit line
        while (string_width(name_trim) > max_name_px && string_length(name_trim) > 3) {
            name_trim = string_copy(name_trim, 1, string_length(name_trim) - 1);
        }
        if (name_trim != name) name_trim += "...";

        var row_text = idx3 + " " + name_trim;

        // Selected row highlight (inverse via black rect + lime text)
        if (i == dir_sel) {
            draw_set_color(c_dkgray);
            draw_rectangle(left_x - 6, draw_y - 2, right_x - 6, draw_y + row_h, false);
            draw_set_color(c_lime);
        }

        draw_text(left_x, draw_y, row_text);
        // draw actions at right
        var act_x = right_x - string_width(">  X") - 16;
        draw_text(act_x, draw_y, ">  X");

        draw_y += row_h;
    }
    // bottom border
    draw_text(left_x, draw_y, "+-------------------------------------------+");

    // Paging markers
    if (first_index > 0)      draw_text(right_x - 40, top_y - row_h, "^");
    if (last_index < total-1) draw_text(right_x - 40, draw_y, "v");

    // Confirm dialog (modal)
    if (dir_confirm_active) {
        var cx = room_width  div 2;
        var cy = room_height div 2;
        var w  = 520;
        var h  = row_h * 4;
        var l  = cx - w div 2;
        var t  = cy - h div 2;
        var r  = cx + w div 2;
        var b  = cy + h div 2;

        draw_set_color(c_black);
        draw_rectangle(l, t, r, b, false);
        draw_set_color(c_lime);

        var _nm = (dir_confirm_index >= 0 && dir_confirm_index < total) ? dir_listing[dir_confirm_index] : "";
        draw_text(l + 12, t + row_h, "Delete \"" + _nm + "\" ?");
        draw_text(l + 12, t + row_h * 2, "[Y]es  [N]o");

        // Note: modal—input handled in Step; draw only here
    }

    // Short help/footer
    draw_set_color(c_dkgray);
    draw_text(x_pad, room_height - row_h - y_pad, "(ASCII dir) Load: Enter/>   Delete: D/X (Desktop only)   Close: ESC");

    return; // overlay draws above everything
}


// Draw program lines with proper spacing
var y_pos = 32;
var lines_shown = 0;
var total_lines = ds_list_size(global.line_numbers);

// Calculate how many lines fit on screen
var available_height = room_height - 128; // Leave space for prompt and messages
var max_lines = floor(available_height / actual_font_height);

for (var i = display_start_line; i < total_lines && lines_shown < max_lines; i++) {
    var line_num = ds_list_find_value(global.line_numbers, i);
    var code = ds_map_find_value(global.program_lines, line_num);
    var display_text = string(line_num) + " " + code;
    
    draw_text(16, y_pos, display_text);
    y_pos += actual_font_height; // Use actual font height
    lines_shown++;
}

// Draw input prompt with proper spacing
draw_text(16, room_height - (actual_font_height * 2), "READY");
draw_text(16, room_height - actual_font_height, "> " + current_input);

// Draw cursor
var cursor_x = 16 + string_width("> " + string_copy(current_input, 1, cursor_pos));
if (current_time % 1000 < 500) { // Blinking cursor
    draw_text(cursor_x, room_height - actual_font_height, "_");
}

// Draw message with proper spacing
if (message_text != "") {
    draw_set_color(c_yellow);
    draw_text(16, room_height - (actual_font_height * 3), message_text);
    draw_set_color(make_color_rgb(255, 191, 64)); // Reset color
}