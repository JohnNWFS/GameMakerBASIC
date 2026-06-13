/// @event obj_editor/Step
// Only process input when in the editor room
if (room != rm_editor) exit;
// Pause regular editor when screen editor is active
if (global.screen_edit_mode) {
    //dbg_log(DBG_FLOW, "EDITOR: Screen edit mode active, pausing regular editor");
    exit;
}

if (variable_global_exists("config") && ds_exists(global.config, ds_type_map)) {
    if (autotest_bootstrap()) exit;
}

if (global.justreturned == 1) {
    current_input = "";
    cursor_pos = 0;
    keyboard_string = "";
    global.justreturned = 0;
    exit; // skip the rest of this Step event
}


// === DEMOS OVERLAY INPUT ===
if (showing_demos_overlay) {
    if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_enter)) {
        showing_demos_overlay = false;
        keyboard_string = "";
        current_input   = "";
        cursor_pos      = 0;
        exit;
    }
    // Number keys 1-9 load demo directly
    if (variable_global_exists("demos_manifest")) {
        var _dn = array_length(global.demos_manifest);
        var _is_desktop = (os_type != os_gxgames && os_browser == browser_not_a_browser);
        for (var _dk = 1; _dk <= min(_dn, 9); _dk++) {
            if (keyboard_check_pressed(ord(string(_dk)))) {
                showing_demos_overlay = false;
                keyboard_string = "";
                current_input   = "";
                cursor_pos      = 0;
                if (_is_desktop) {
                    demos_load_file_local(_dk - 1);
                } else {
                    global.__demos_loading = true;
                    import_from_url(global.demos_manifest[_dk - 1][$ "url"]);
                }
                exit;
            }
        }
    }
    exit; // block regular input while overlay is up
}


// === DIRECTORY OVERLAY INPUT (ASCII) ===
if (showing_dir_overlay) {

    // Close overlay on ESC (unless confirm is up)
    if (!dir_confirm_active && keyboard_check_pressed(vk_escape)) {
        showing_dir_overlay = false;
        dir_listing = [];
        dbg_log(DBG_FLOW, "[DIR] close overlay (ESC)");
        exit;
    }

    // Guard page_size (Draw recalculates each frame)
    if (dir_page_size < 1) dir_page_size = 1;

    var _count = array_length(dir_listing);
    if (_count <= 0) { exit; } // nothing to do

    // Clamp selection to list
    dir_sel = clamp(dir_sel, 0, max(0, _count - 1));

    // If confirm dialog active: handle Y/N only; block other inputs
    if (dir_confirm_active) {
        if (keyboard_check_pressed(ord("Y"))) {
            var _name = dir_listing[dir_confirm_index];
            var _path = dir_save_dir + _name;
            if (file_exists(_path)) {
                dbg_log(DBG_IO, "[DIR] delete " + _path);
                file_delete(_path);
            }
            list_saved_programs(); // refresh overlay
        }
        if (keyboard_check_pressed(ord("N")) || keyboard_check_pressed(vk_escape)) {
            dbg_log(DBG_FLOW, "[DIR] delete cancelled");
            dir_confirm_active = false;
        }
        exit; // modal consumes input
    }

    // NAVIGATION
    if (keyboard_check_pressed(vk_home))  dir_sel = 0;
    else if (keyboard_check_pressed(vk_end))   dir_sel = max(0, _count - 1);
    else if (keyboard_check_pressed(vk_up))    dir_sel = max(0, dir_sel - 1);
    else if (keyboard_check_pressed(vk_down))  dir_sel = min(_count - 1, dir_sel + 1);
    else if (keyboard_check_pressed(vk_pageup))   dir_sel = max(0, dir_sel - dir_page_size);
    else if (keyboard_check_pressed(vk_pagedown)) dir_sel = min(_count - 1, dir_sel + dir_page_size);

    // ACTIONS
    // Load on ENTER or '>' key
// Load on ENTER or '>' key
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord(">"))) {
    var _name = dir_listing[dir_sel];
    if (_name != "No .bas files found.") {
        // Check if this is an HTML file list (has global.html_dir_files data)
        if ((os_type == os_gxgames || os_browser != browser_not_a_browser) && variable_global_exists("html_dir_files") && ds_list_size(global.html_dir_files) > 0) {
            // HTML version - load from memory
            dbg_log(DBG_IO, "[DIR] HTML load: " + _name + " at index " + string(dir_sel + 1));
            var success = editor_html_dir_open(string(dir_sel + 1));
            if (success) {
                showing_dir_overlay = false;
                dir_listing = [];
                global.justreturned = 1;
            } else {
                basic_show_message("Failed to load file from memory");
            }
            exit;
        } else {
            // Windows version - load from disk
            var _path = dir_save_dir + _name;
            if (file_exists(_path)) {
                dbg_log(DBG_IO, "[DIR] load " + _path);
                load_program_from_path(_path, _name);
                showing_dir_overlay = false;
                dir_listing = [];
                global.justreturned = 1;
                exit;
            } else {
                basic_show_message("File not found");
            }
        }
    }
}

    // Delete on 'D', 'X', or Delete key
    if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_delete)) {
        if (_count > 0 && dir_listing[dir_sel] != "No .bas files found.") {
            dir_confirm_active = true;
            dir_confirm_index  = dir_sel;
            dbg_log(DBG_FLOW, "[DIR] confirm delete idx=" + string(dir_sel));
        }
    }

    // NOTE: Do not let base editor input run while overlay is active
    exit;
}





// Handle Enter key
if (keyboard_check_pressed(vk_enter)) {
    add_to_history(current_input);
    process_input_line(current_input);
    current_input = "";
    cursor_pos = 0;
    global.history_index = -1;
    input_buffer = keyboard_string; // reset keyboard buffer
}

 else if (keyboard_check_released(vk_backspace)) {
    if (cursor_pos > 0) {
        current_input = string_delete(current_input, cursor_pos, 1);
        cursor_pos--;
    }
 }
 else if (keyboard_check_pressed(vk_left)) {
    cursor_pos = max(0, cursor_pos - 1);
 }
 else if (keyboard_check_pressed(vk_right)) {
    cursor_pos = min(string_length(current_input), cursor_pos + 1);
 }
 else if (keyboard_check_pressed(vk_up)) {
    navigate_history_up();
 }
 else if (keyboard_check_pressed(vk_down)) {
    navigate_history_down();
 }
 else if (keyboard_check_pressed(vk_pageup)) {
    draw_set_font(fnt_basic);
    var page_lines_up = max(1, floor((room_height - 128) / string_height("A")));
    lines_per_screen = page_lines_up;
    display_start_line = max(editor_scroll_min_index(), display_start_line - page_lines_up);
 }
 else if (keyboard_check_pressed(vk_pagedown)) {
    draw_set_font(fnt_basic);
    var page_lines_down = max(1, floor((room_height - 128) / string_height("A")));
    lines_per_screen = page_lines_down;
    var max_start = editor_scroll_max_index(page_lines_down);
    display_start_line = min(max_start, display_start_line + page_lines_down);
 }
 else if (keyboard_check(vk_control) && keyboard_check_pressed(ord("Z"))) {
    undo_last_change();
 }
 else if (keyboard_check(vk_control) && keyboard_check_pressed(ord("V"))) {
    // Desktop: paste first line of clipboard text at cursor
    if (os_browser == browser_not_a_browser) {
        var _clip = clipboard_get_text();
        if (string_length(_clip) > 0) {
            _clip = string_replace_all(string_replace_all(_clip, "\r\n", "\n"), "\r", "\n");
            var _nl = string_pos("\n", _clip);
            if (_nl > 0) _clip = string_copy(_clip, 1, _nl - 1);
            _clip = string_trim(_clip);
            if (string_length(_clip) > 0) {
                var _before = string_copy(current_input, 1, cursor_pos);
                var _after  = string_copy(current_input, cursor_pos + 1, string_length(current_input) - cursor_pos);
                current_input = _before + _clip + _after;
                cursor_pos += string_length(_clip);
            }
        }
    }
 }
 else if (keyboard_check(vk_f5)) {
    dump_program_to_console();
	basic_show_message("Dumped program to Console");	 
 }
 else {
    // Handle character input with repeat
    handle_character_input();
 }

 draw_set_font(fnt_basic);
 var page_lines_clamp = max(1, floor((room_height - 128) / string_height("A")));
 lines_per_screen = page_lines_clamp;
 display_start_line = clamp(display_start_line, editor_scroll_min_index(), editor_scroll_max_index(page_lines_clamp));
 
  // In Step Event
 if (message_timer > 0) {
    message_timer--;
    if (message_timer <= 0) {
        message_text = "";
    }
 }
 
