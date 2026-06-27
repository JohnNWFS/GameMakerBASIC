// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function list_program() {
    list_range_active = false;
    display_start_line = 0;
    update_display();
 }
 function list_program_range(range) {
    // Parse range like "10-50" or scroll to a single number like "300"
    var dash_pos = string_pos("-", range);
    if (dash_pos > 0) {
        var start_text = string_trim(string_copy(range, 1, dash_pos - 1));
        var end_text = string_trim(string_copy(range, dash_pos + 1, string_length(range)));
        if (!is_line_number(start_text) || !is_line_number(end_text)) {
            show_error_message("USAGE: LIST <LINE>-<LINE>");
            return;
        }

        var start_line = real(start_text);
        var end_line = real(end_text);
        if (end_line < start_line) {
            show_error_message("LIST RANGE OUT OF ORDER");
            return;
        }

        var start_idx = editor_find_first_line_index_at_or_after(start_line);
        var end_idx = editor_find_last_line_index_at_or_before(end_line);
        if (start_idx < 0 || end_idx < 0 || start_idx > end_idx) {
            show_error_message("NO LINES IN RANGE");
            return;
        }

        list_range_active = true;
        list_range_start_line = start_line;
        list_range_end_line = end_line;
        display_start_line = start_idx;
        update_display();
        basic_show_message("LIST " + string(start_line) + "-" + string(end_line));
    } else {
        go_program_line(range, "LIST");
    }
 }

function go_program_line(line_text, command_name = "GO") {
    var target_text = string_trim(line_text);
    if (!is_line_number(target_text)) {
        show_error_message("USAGE: " + command_name + " <LINE>");
        return;
    }

    var target = real(target_text);
    if (!is_valid_line_number(target)) {
        show_error_message("INVALID LINE NUMBER");
        return;
    }

    var total = ds_list_size(global.line_list);
    if (total <= 0) {
        basic_show_message("NO PROGRAM");
        return;
    }

    list_range_active = false;

    var idx = editor_find_first_line_index_at_or_after(target);
    if (idx < 0) idx = total - 1;
    display_start_line = clamp(idx, 0, max(0, total - 1));
    update_display();

    var shown_line = ds_list_find_value(global.line_list, display_start_line);
    if (shown_line == target) {
        basic_show_message(command_name + " " + string(target));
    } else {
        basic_show_message(command_name + " " + string(target) + " -> " + string(shown_line));
    }
}

function editor_find_first_line_index_at_or_after(target) {
    var total = ds_list_size(global.line_list);
    for (var i = 0; i < total; i++) {
        var line_num = ds_list_find_value(global.line_list, i);
        if (line_num >= target) return i;
    }
    return -1;
}

function editor_find_last_line_index_at_or_before(target) {
    for (var i = ds_list_size(global.line_list) - 1; i >= 0; i--) {
        var line_num = ds_list_find_value(global.line_list, i);
        if (line_num <= target) return i;
    }
    return -1;
}

function editor_scroll_min_index() {
    if (variable_instance_exists(id, "list_range_active") && list_range_active) {
        var idx = editor_find_first_line_index_at_or_after(list_range_start_line);
        return max(0, idx);
    }
    return 0;
}

/// Line-list index for screen editor entry (matches editor LIST/scroll view).
function editor_get_screen_editor_start_index() {
    if (instance_exists(obj_editor)) {
        with (obj_editor) {
            return clamp(display_start_line, 0, max(0, ds_list_size(global.line_list) - 1));
        }
    }
    return 0;
}

function editor_scroll_max_index(page_lines) {
    var total = ds_list_size(global.line_list);
    if (total <= 0) return 0;

    if (variable_instance_exists(id, "list_range_active") && list_range_active) {
        var min_idx = editor_scroll_min_index();
        var last_idx = editor_find_last_line_index_at_or_before(list_range_end_line);
        if (last_idx < min_idx) return min_idx;
        return max(min_idx, last_idx - page_lines + 1);
    }

    return max(0, total - page_lines);
}
