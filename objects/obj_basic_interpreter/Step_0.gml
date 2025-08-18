// === BEGIN: obj_basic_interpreter.Step ===
// obj_basic_interpreter → Step Event

// Add this at the very start of obj_basic_interpreter Step event for debugging
/*if (keyboard_check_pressed(vk_enter)) {
    show_debug_message("ENTER pressed - pause_in_effect: " + string(global.pause_in_effect) + 
                      ", awaiting_input: " + string(global.awaiting_input) + 
                      ", pause_mode: " + string(global.pause_mode));
}*/


global.dbg_frame_count = 0;
if (global.dbg_dropped_count > 0) {
    show_debug_message("DBG: dropped " + string(global.dbg_dropped_count) + " lines this frame");
    global.dbg_dropped_count = 0;
}

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
    if (keyboard_check_pressed(vk_pageup))   global.scroll_offset = max(global.scroll_offset - 1, 0);
    if (keyboard_check_pressed(vk_pagedown)) {
        var font_height = string_height("A");
        var visible_lines = floor(room_height / font_height) - 2;
        var total_lines = ds_list_size(global.output_lines);
        global.scroll_offset = min(global.scroll_offset + 1, max(0, total_lines - visible_lines));
    }
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape)) {
        global.program_has_ended = false;
        global.current_mode = 0;
    
		var _ret = variable_global_exists("editor_return_room")
               ? global.editor_return_room
               : room_first; // fallback if something goes weird

    room_goto(_ret);
    }
    return;
}

// ==============================
// === Handle INPUT or PAUSE (existing) ===
// ==============================
if (global.awaiting_input) {
    if (global.pause_mode) {
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape)) {
            show_debug_message("PAUSE: ENTER/ESC detected, resuming...");
            global.awaiting_input = false;
            global.pause_mode = false;
            global.pause_in_effect = false;
            global.input_target_var = "";
            global.interpreter_input = "";
			//
			global.interpreter_resume_stmt_index = global.interpreter_current_stmt_index + 1;
        }
    } else {
        for (var _k = 32; _k <= 126; _k++) if (keyboard_check_pressed(_k)) handle_interpreter_character_input(_k);
        if (keyboard_check_pressed(vk_enter))     handle_interpreter_character_input(vk_enter);
        if (keyboard_check_pressed(vk_backspace)) handle_interpreter_character_input(vk_backspace);
    }
    return;
}

// ------------------------------------------------------------------
// INKEY$ modal wait handler (blocking GET-style for LET ... = INKEY$)
// Armed by basic_cmd_let: pause_in_effect=true & inkey_waiting=true
// Captures ONE printable key (ASCII 32..126) on pressed edge, then resumes.
// ------------------------------------------------------------------
if (is_undefined(global.inkey_waiting))    global.inkey_waiting    = false;
if (is_undefined(global.inkey_captured))   global.inkey_captured   = "";
if (is_undefined(global.inkey_target_var)) global.inkey_target_var = "";

if (global.pause_in_effect && global.inkey_waiting) {
    var _got = "";
    for (var _kc = 32; _kc <= 126; _kc++) {
        if (keyboard_check_pressed(_kc)) { _got = chr(_kc); break; }
    }

    if (_got != "") {
        global.inkey_captured  = _got;
        global.inkey_waiting   = false;
        global.pause_in_effect = false; // allow LET to re-run and assign on next frame
        //show_debug_message("INKEY_WAIT: captured '" + _got + "' — resuming");
    } else {
        //show_debug_message("INKEY_WAIT: paused, waiting for printable key");
    }
    return; // don't advance interpreter while waiting / just after capture
}

// ==============================
// === Synchronize for structured IF…ELSE handling ===
// ==============================
global.interpreter_current_line_index = line_index;

// ==============================
// === Handle Jumps (PREFER LEGACY LINE JUMP) ===
// ==============================
// CHANGED: prefer legacy line jump (GOSUB/GOTO) over statement-level resume,
// and CLEAR any pending statement-level flags when legacy wins.
if (global.interpreter_next_line >= 0) {
    show_debug_message("IFJUMP: legacy line jump wins → line=" + string(global.interpreter_next_line));
    line_index = global.interpreter_next_line;
    global.interpreter_current_line_index = global.interpreter_next_line;
    global.interpreter_resume_stmt_index = 0;

    // --- NEW: clear any stale statement-level jump so it can't fire after the target line runs
    global.interpreter_use_stmt_jump = false;
    global.interpreter_target_line   = -1;
    global.interpreter_target_stmt   = 0;

    global.interpreter_next_line = -1;
} else if (global.interpreter_use_stmt_jump && global.interpreter_target_line >= 0) {
    show_debug_message("IFJUMP: using statement-level jump → line=" + string(global.interpreter_target_line) + ", stmt=" + string(global.interpreter_target_stmt));
    line_index = global.interpreter_target_line;
    global.interpreter_current_line_index = global.interpreter_target_line;
    global.interpreter_resume_stmt_index = max(0, global.interpreter_target_stmt);
    global.interpreter_use_stmt_jump = false;
    global.interpreter_target_line = -1;
    global.interpreter_target_stmt = 0;
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
    var line_number = ds_list_find_value(global.line_list, line_index);
    var code        = ds_map_find_value(global.program_map, line_number);

    var trimmed = string_trim(code);
    var parts   = split_on_unquoted_colons(trimmed);

    global.current_line_number = line_number;
    show_debug_message("Running line " + string(line_number));

    var _start_stmt = 0;
    if (global.interpreter_resume_stmt_index > 0) {
        _start_stmt = global.interpreter_resume_stmt_index;
        show_debug_message("Resuming at statement index " + string(_start_stmt)
            + " on line " + string(line_number));
        global.interpreter_resume_stmt_index = 0;
    }

    for (var p = _start_stmt; p < array_length(parts); p++) {
        var stmt = string_trim(parts[p]);
        if (stmt == "") continue;

        var sp2  = string_pos(" ", stmt);
        var cmd2 = (sp2 > 0) ? string_upper(string_copy(stmt, 1, sp2 - 1)) : string_upper(stmt);
        var arg2 = (sp2 > 0) ? string_trim(string_copy(stmt, sp2 + 1, string_length(stmt))) : "";

        // REM / apostrophe: stop the *physical line*
        if (cmd2 == "REM" || string_char_at(stmt, 1) == "'") {
            if (dbg_on(DBG_FLOW)) {
                show_debug_message("REM/' : stop parsing remainder of line "
                    + string(line_number) + " at part " + string(p) + "/"
                    + string(array_length(parts) - 1));
            }
            break;
        }

        // Strip inline remark then recompute verb/arg
        stmt = strip_basic_remark(stmt);
        sp2  = string_pos(" ", stmt);
        cmd2 = (sp2 > 0) ? string_upper(string_copy(stmt, 1, sp2 - 1)) : string_upper(stmt);
        arg2 = (sp2 > 0) ? string_trim(string_copy(stmt, sp2 + 1, string_length(stmt))) : "";

        global.interpreter_current_stmt_index = p;

        show_debug_message("Command: " + cmd2 + " | Arg: " + arg2);
        handle_basic_command(cmd2, arg2);

        // --- If a pause was armed (e.g., LET ... = INKEY$), stop RIGHT HERE ---
        if (global.pause_in_effect) {
            global.interpreter_resume_stmt_index = p; // retry this colon slot next frame
            show_debug_message("PAUSE: engaged during statement; will retry stmt index " + string(p) + " next frame");
            break;
        }

        // CHANGED ORDER: prefer legacy line jump break over statement-level break,
        // and when legacy is present, also clear any stale statement-level jump flags.
        if (global.interpreter_next_line >= 0) {
            show_debug_message("IFJUMP: breaking line loop for LEGACY LINE jump");
            // --- NEW: clear statement-level flags so they don't redirect after the target line executes
            global.interpreter_use_stmt_jump = false;
            global.interpreter_target_line   = -1;
            global.interpreter_target_stmt   = 0;
            break;
        }
        if (global.interpreter_use_stmt_jump && global.interpreter_target_line >= 0) {
            show_debug_message("IFJUMP: breaking line loop for STATEMENT-LEVEL jump request");
            break;
        }
    }

    // If no jump was requested and we're NOT paused, advance to the next line
    if (!(global.interpreter_use_stmt_jump && global.interpreter_target_line >= 0)
     && !(global.interpreter_next_line >= 0)
     && !global.pause_in_effect) {
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
if (keyboard_check_pressed(vk_pageup))   global.scroll_offset = max(global.scroll_offset - 1, 0);
if (keyboard_check_pressed(vk_pagedown)) {
    var font_height2 = string_height("A");
    var visible_lines2 = floor(room_height / font_height2) - 2;
    var total_lines2 = ds_list_size(global.output_lines) + (global.awaiting_input ? 1 : 0);
    global.scroll_offset = min(global.scroll_offset + 1, max(0, total_lines2 - visible_lines2));
}

// (Legacy path retained; harmless with new flow)
if (global.pause_in_effect && global.inkey_mode) {
    handle_inkey_input();
}
// === END: obj_basic_interpreter.Step ===
