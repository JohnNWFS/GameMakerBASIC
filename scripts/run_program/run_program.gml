function run_program() {
    dbg_log(DBG_FLOW, "RUN_PROGRAM START - color is: " + string(global.current_draw_color));
	// Always remember where we launched from (editor room)
	global.editor_return_room = rm_editor;

    // ── Guard: no program ────────────────────────────────────────────────
    if (!ds_exists(global.line_list, ds_type_list) || ds_list_size(global.line_list) == 0) {
        show_error_message("NO PROGRAM");
        return;
    }

    // ── Sync editor → canonical runtime program view ────────────────────
    basic_program_sync_runtime();
    // ── Make sure output buffers exist BEFORE validation (errors print into them) ──
    basic_memory_ensure_list("output_lines");
    basic_memory_ensure_list("output_colors");

    // Per-run flag (safe init)
    if (is_undefined(global._syntax_error_just_emitted)) global._syntax_error_just_emitted = false;
    global._syntax_error_just_emitted = false;

    // ── Build helpers that validators/dispatchers rely on ─────────────────
    build_data_streams();     // harvest DATA / prep READ/RESTORE
    build_if_block_map();     // multi-line IF/ELSE structure
    dbg_log(DBG_FLOW, "IF-block map built (" + string(ds_map_size(global.if_block_map)) + " blocks)");

// === GOSUB PRE-SCAN: build call-only subroutine set ===
// ANCHOR: place this immediately after your "IF-block map built (...)" log in run_program

// Ensure the map exists
basic_memory_ensure_map("gosub_targets");
ds_map_clear(global.gosub_targets);

// Walk physical line order used by the interpreter
for (var i = 0; i < ds_list_size(global.line_list); i++) {
    var _ln  = global.line_list[| i];
    var raw  = ds_map_find_value(global.program_map, _ln);
    if (is_undefined(raw)) continue;

    // Split line into colon segments
    var parts = split_on_unquoted_colons(string_trim(raw));
    for (var p = 0; p < array_length(parts); p++) {
        var stmt = string_trim(parts[p]);
        if (stmt == "") continue;

        // Strip inline remark BEFORE tokenizing (handles: GOSUB 1000 ' comment)
        stmt = strip_basic_remark(stmt);
        if (stmt == "") continue;

        // verb/rest
        var sp  = string_pos(" ", stmt);
        var v0  = (sp > 0) ? string_upper(string_copy(stmt, 1, sp - 1)) : string_upper(stmt);
        var r0  = (sp > 0) ? string_trim(string_copy(stmt, sp + 1, string_length(stmt))) : "";

        if (v0 == "DATA") {
            break;
        }

        if (v0 == "GOSUB") {
            // consider only first token after GOSUB for pre-scan (numeric labels)
            var tok = r0;
            var sp2 = string_pos(" ", tok);
            if (sp2 > 0) tok = string_copy(tok, 1, sp2 - 1);
            tok = string_trim(tok);

            if (is_numeric_string(tok)) {
                ds_map_set(global.gosub_targets, string(real(tok)), true);
            }
        }
    }
}
// === end GOSUB PRE-SCAN ===


    // ── VALIDATE: visible errors + correct room ───────────────────────────
    // Assumes basic_validate_program() exists.
    if (!basic_validate_program()) {
        // Validator already printed a visible error & set end flags.
        // Ensure the user can see it.
        var _text_room_for_error = ds_map_find_value(global.mode_rooms, 0);
        if (room != _text_room_for_error) room_goto(_text_room_for_error);
        return;
    }
    dbg_log(DBG_FLOW, "RUN_PROGRAM: validation passed");

    // ── Fresh runtime state (vars, arrays, stacks, files) ───────────────
    basic_runtime_reset_for_run();

    // ── Clean start: clear output buffers for a fresh run ─────────────────
    ds_list_clear(global.output_lines);
    ds_list_clear(global.output_colors);
    global.print_line_buffer = "";
    basic_output_transcript_reset();
    keyboard_string = "";
    if (variable_global_exists("__inkey_queue") && ds_exists(global.__inkey_queue, ds_type_queue)) {
        ds_queue_clear(global.__inkey_queue);
    }

    // ── Interpreter state ─────────────────────────────────────────────────
    global.interpreter_input    = "";
    global.awaiting_input       = false;
    global.input_target_var     = "";
    global.interpreter_running  = true;
    global.program_has_ended    = false;

    global.pause_in_effect      = false;
    global.pause_mode           = false;
    global.input_expected       = false;

    // Reset BEEP/PLAY state so octave, tempo, and volume don't leak between runs
    global.beep_current_oct = 0;
    global.beep_tempo       = 120;
    global.beep_volume      = 0.35;
    global.beep_note_gate   = 0.875;
    global.beep_waiting     = false;
    global.beep_seq_active  = false;

    global.inkey_mode           = false;
    global.inkey_waiting        = false;
    global.inkey_captured       = "";
    global.inkey_target_var     = "";
    global.inkey_release_guard  = false;
    global.inkey_flush_frames   = 6;

    // Set draw color for this run (your existing choice)
    global.current_draw_color = make_color_rgb(255, 191, 64); // Amber

    // Line navigation
    global.interpreter_current_line_index = 0;
    global.interpreter_next_line          = -1;
    global.interpreter_use_stmt_jump      = false;
    global.interpreter_target_line        = -1;
    global.interpreter_target_stmt        = 0;
    global.interpreter_resume_stmt_index  = 0;
    global.current_line_number            = (ds_list_size(global.line_list) > 0)
                                           ? (global.line_list[| 0]) : -1;

    // Go to interpreter room (only if not already there)
    var _text_room = ds_map_find_value(global.mode_rooms, 0);
    if (room != _text_room) {
        dbg_log(DBG_FLOW, "RUN_PROGRAM: room_goto text room from " + room_get_name(room));
        room_goto(_text_room);
    } else {
        dbg_log(DBG_FLOW, "RUN_PROGRAM: already in text room");
    }
}
