/// @event obj_editor/Step
// Pause regular editor when screen editor is active
if (global.screen_edit_mode) {
    //if (dbg_on(DBG_FLOW)) show_debug_message("EDITOR: Screen edit mode active, pausing regular editor");
    exit;
}

if (global.justreturned == 1) {
    current_input = "";
    cursor_pos = 0;
    keyboard_string = "";
    global.justreturned = 0;
    exit; // skip the rest of this Step event
}

// === DIRECTORY OVERLAY INPUT (ASCII) ===
if (showing_dir_overlay) {

    // Close overlay on ESC (unless confirm is up)
    if (!dir_confirm_active && keyboard_check_pressed(vk_escape)) {
        showing_dir_overlay = false;
        dir_listing = [];
        if (dbg_on(DBG_FLOW)) show_debug_message("[DIR] close overlay (ESC)");
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
            // Delete (desktop only)
            if (os_type != os_browser) {
                var _name = dir_listing[dir_confirm_index];
                var _path = dir_save_dir + _name;
                if (file_exists(_path)) {
                    if (dbg_on(DBG_IO)) show_debug_message("[DIR] delete " + _path);
                    file_delete(_path);
                }
                // refresh list
                list_saved_programs(); // re-enter overlay with fresh state
            } else {
                if (dbg_on(DBG_IO)) show_debug_message("[DIR] delete disabled on HTML5");
                dir_confirm_active = false;
            }
        }
        if (keyboard_check_pressed(ord("N")) || keyboard_check_pressed(vk_escape)) {
            if (dbg_on(DBG_FLOW)) show_debug_message("[DIR] delete cancelled");
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
        if (os_browser != browser_not_a_browser && variable_global_exists("html_dir_files") && ds_list_size(global.html_dir_files) > 0) {
            // HTML version - load from memory
            if (dbg_on(DBG_IO)) show_debug_message("[DIR] HTML load: " + _name + " at index " + string(dir_sel + 1));
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
                if (dbg_on(DBG_IO)) show_debug_message("[DIR] load " + _path);
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

    // Delete on 'D', 'X', or Delete key (desktop only)
    if (os_browser != browser_not_a_browser) {
        if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_delete)) {
            if (_count > 0 && dir_listing[dir_sel] != "No .bas files found.") {
                dir_confirm_active = true;
                dir_confirm_index  = dir_sel;
                if (dbg_on(DBG_FLOW)) show_debug_message("[DIR] confirm delete idx=" + string(dir_sel));
            }
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
    display_start_line = max(0, display_start_line - lines_per_screen);
 }
 else if (keyboard_check_pressed(vk_pagedown)) {
    var max_start = max(0, ds_list_size(global.line_numbers) - lines_per_screen);
    display_start_line = min(max_start, display_start_line + lines_per_screen);
 }
 else if (keyboard_check(vk_control) && keyboard_check_pressed(ord("Z"))) {
    undo_last_change();
 }
 else if (keyboard_check(vk_f5)) {
    dump_program_to_console();
	basic_show_message("Dumped program to Console");	 
 }
 else {
    // Handle character input with repeat
    handle_character_input();
 }
 
  // In Step Event
 if (message_timer > 0) {
    message_timer--;
    if (message_timer <= 0) {
        message_text = "";
    }
 }
 
