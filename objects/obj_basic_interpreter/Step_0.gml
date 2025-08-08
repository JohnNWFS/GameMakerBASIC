// obj_basic_interpreter → Step Event

// WATCHDOG: are output buffers DS lists this frame?
/*var _ol = global.output_lines;
var _oc = global.output_colors;
show_debug_message(
    "WATCH: out_lines=" + string(_ol) +
    " is_real=" + string(is_real(_ol)) +
    " exists=" + string(is_real(_ol) && ds_exists(_ol, ds_type_list)) +
    " | out_colors=" + string(_oc) +
    " is_real=" + string(is_real(_oc)) +
    " exists=" + string(is_real(_oc) && ds_exists(_oc, ds_type_list))
);

*/

// ==============================
// Sort program lines in ascending order
// ==============================
if (ds_exists(global.line_list, ds_type_list)) {
    ds_list_sort(global.line_list, true);
}

// ==============================
// === Program Ended: Wait for user action ===
// ==============================
if (global.program_has_ended) {
    if (keyboard_check_pressed(vk_pageup)) {
        global.scroll_offset = max(global.scroll_offset - 1, 0);
    }
    if (keyboard_check_pressed(vk_pagedown)) {
        var font_height = string_height("A");
        var visible_lines = floor(room_height / font_height) - 2;
        var total_lines = ds_list_size(global.output_lines);
        global.scroll_offset = min(global.scroll_offset + 1, max(0, total_lines - visible_lines));
    }

    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape)) {
        global.program_has_ended = false;
        global.current_mode = 0;
        room_goto(global.editor_return_room);
    }
    return;
}

// ==============================
// === Handle INPUT or PAUSE ===
// ==============================
if (global.awaiting_input) {
    if (global.pause_mode) {
        if (keyboard_check_pressed(vk_enter)) {
            global.awaiting_input = false;
            global.pause_mode = false;
            global.input_target_var = "";
            global.interpreter_input = "";
        }
    } else {
        for (var _k = 32; _k <= 126; _k++) {
            if (keyboard_check_pressed(_k)) handle_interpreter_character_input(_k);
        }
        if (keyboard_check_pressed(vk_enter))     handle_interpreter_character_input(vk_enter);
        if (keyboard_check_pressed(vk_backspace)) handle_interpreter_character_input(vk_backspace);
    }
    return;
}

// ==============================
// === Synchronize for structured IF…ELSE handling ===
// Ensure handlers read the correct current line index
// ==============================
global.interpreter_current_line_index = line_index;

// ==============================
// === Handle Jumps (statement-first, then legacy line jump) ===
// These are set by commands like IF/GOTO (line jump) and NEXT (stmt jump, new)
// ==============================
if (global.interpreter_use_stmt_jump && global.interpreter_target_line >= 0) {
    show_debug_message("JUMP: Using statement-level jump → line="
        + string(global.interpreter_target_line) + ", stmt="
        + string(global.interpreter_target_stmt));

    // Jump to requested line
    line_index = global.interpreter_target_line;
    global.interpreter_current_line_index = global.interpreter_target_line;

    // Tell the dispatcher which statement on that line to resume at
    global.interpreter_resume_stmt_index = max(0, global.interpreter_target_stmt);

    // Clear stmt-jump flags
    global.interpreter_use_stmt_jump = false;
    global.interpreter_target_line = -1;
    global.interpreter_target_stmt = 0;

    // Ensure legacy jump is cleared when stmt-jump is used
    global.interpreter_next_line = -1;

} else if (global.interpreter_next_line >= 0) {
    show_debug_message("JUMP: Using legacy line jump → line="
        + string(global.interpreter_next_line));

    // Legacy behavior: jump to a new line, start at first statement
    line_index = global.interpreter_next_line;
    global.interpreter_current_line_index = global.interpreter_next_line;

    global.interpreter_resume_stmt_index = 0;
    global.interpreter_next_line = -1;
}

// ==============================
// === End of Program Check ===
// ==============================
if (line_index >= ds_list_size(global.line_list)) {
    global.interpreter_running = false;
}

// ==============================
// === Execute BASIC Line ===
// ==============================
if (line_index < ds_list_size(global.line_list)) {
    // Fetch the next line of BASIC
    var line_number = ds_list_find_value(global.line_list, line_index);
    var code        = ds_map_find_value(global.program_map, line_number);

    // Trim and split on unquoted, top-level colons
    var trimmed = string_trim(code);
    var parts   = split_on_unquoted_colons(trimmed);

    // Dispatch each sub-statement in turn
    global.current_line_number = line_number;
    show_debug_message("Running line " + string(line_number));

    // NEW: resume at a specific statement index (set by stmt-level jump)
    var _start_stmt = 0;
    if (global.interpreter_resume_stmt_index > 0) {
        _start_stmt = global.interpreter_resume_stmt_index;
        show_debug_message("Resuming at statement index " + string(_start_stmt)
            + " on line " + string(line_number));
        // One-shot consumption: reset after applying
        global.interpreter_resume_stmt_index = 0;
    }

	for (var p = _start_stmt; p < array_length(parts); p++) {
	    var stmt = string_trim(parts[p]);
	    if (stmt == "") continue;

	    // Strip BASIC-style REM
	    stmt = strip_basic_remark(stmt);

	    // Pull off the verb vs. its argument
	    var sp2  = string_pos(" ", stmt);
	    var cmd2 = (sp2 > 0)
	                 ? string_upper(string_copy(stmt, 1, sp2 - 1))
	                 : string_upper(stmt);
	    var arg2 = (sp2 > 0)
	                 ? string_trim(string_copy(stmt, sp2 + 1, string_length(stmt)))
	                 : "";

	    // >>> NEW: tell commands which colon-slot we're on <<<
	    global.interpreter_current_stmt_index = p;

	    show_debug_message("Command: " + cmd2 + " | Arg: " + arg2);
	    handle_basic_command(cmd2, arg2);


        // If any jump was requested, stop processing further parts on this line

        // 1) Statement-level jump (inline FOR/NEXT loop body, etc.)
        if (global.interpreter_use_stmt_jump && global.interpreter_target_line >= 0) {
            show_debug_message("Breaking line loop to honor STATEMENT-LEVEL jump request");
            break;
        }

        // 2) Legacy line jump (IF/GOTO/etc.)
        if (global.interpreter_next_line >= 0) {
            show_debug_message("Breaking line loop to honor LINE jump request");
            break;
        }
    }

    // If no jump was requested, advance to the next line
    if (!(global.interpreter_use_stmt_jump && global.interpreter_target_line >= 0)
     && !(global.interpreter_next_line >= 0)) {
        line_index++;
    }
}
else {
    global.interpreter_running = false;
}

// ==============================
// === Escape Returns to Editor ===
// ==============================
if (keyboard_check_pressed(vk_escape)) {
    global.current_mode = 0;
    room_goto(global.editor_return_room);
}

// ==============================
// === F5 Dumps BASIC to Console ===
// ==============================
if (keyboard_check_released(vk_f5) && basic_run_to_console_flag == false) {
    basic_run_to_console_flag = true;
    basic_run_to_console();
}

// ==============================
// === Manual Scroll (Always Available) ===
// ==============================
if (keyboard_check_pressed(vk_pageup)) {
    global.scroll_offset = max(global.scroll_offset - 1, 0);
}
if (keyboard_check_pressed(vk_pagedown)) {
    var font_height2 = string_height("A");
    var visible_lines2 = floor(room_height / font_height2) - 2;
    var total_lines2 = ds_list_size(global.output_lines) + (global.awaiting_input ? 1 : 0);
    global.scroll_offset = min(global.scroll_offset + 1, max(0, total_lines2 - visible_lines2));
}
