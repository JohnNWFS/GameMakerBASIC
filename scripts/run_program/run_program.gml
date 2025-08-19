function run_program() {
    if (dbg_on(DBG_FLOW)) show_debug_message("RUN_PROGRAM START - color is: " + string(global.current_draw_color));
	// Always remember where we launched from (editor room)
	global.editor_return_room = rm_editor;

    // ── Guard: no program ────────────────────────────────────────────────
    if (!ds_exists(global.line_numbers, ds_type_list) || ds_list_size(global.line_numbers) == 0) {
        show_error_message("NO PROGRAM");
        return;
    }

    // ── Sync editor → runtime structures used by interpreter/validator ──
    // program_map (lineNo -> code)
    if (!ds_exists(global.program_map, ds_type_map)) {
        global.program_map = ds_map_create();
    } else {
        ds_map_clear(global.program_map);
    }
    ds_map_copy(global.program_map, global.program_lines);

    // line_list (sorted list of line numbers)
    if (!ds_exists(global.line_list, ds_type_list)) {
        global.line_list = ds_list_create();
    } else {
        ds_list_clear(global.line_list);
    }
    for (var _i = 0; _i < ds_list_size(global.line_numbers); _i++) {
        ds_list_add(global.line_list, global.line_numbers[| _i]);
    }
    ds_list_sort(global.line_list, true);

    // (Optional archival copies)
    if (!ds_exists(global.basic_program, ds_type_map)) {
        global.basic_program = ds_map_create();
    } else {
        ds_map_clear(global.basic_program);
    }
    ds_map_copy(global.basic_program, global.program_lines);

    if (!variable_global_exists("basic_line_numbers") || !ds_exists(global.basic_line_numbers, ds_type_list)) {
        global.basic_line_numbers = ds_list_create();
    } else {
        ds_list_clear(global.basic_line_numbers);
    }
    ds_list_copy(global.basic_line_numbers, global.line_numbers);

    // ── Make sure output buffers exist BEFORE validation (errors print into them) ──
    if (!is_real(global.output_lines) || !ds_exists(global.output_lines, ds_type_list)) {
        global.output_lines = ds_list_create();
    }
    if (!is_real(global.output_colors) || !ds_exists(global.output_colors, ds_type_list)) {
        global.output_colors = ds_list_create();
    }

    // Per-run flag (safe init)
    if (is_undefined(global._syntax_error_just_emitted)) global._syntax_error_just_emitted = false;
    global._syntax_error_just_emitted = false;

    // ── Build helpers that validators/dispatchers rely on ─────────────────
    build_data_streams();     // harvest DATA / prep READ/RESTORE
    build_if_block_map();     // multi-line IF/ELSE structure
    if (dbg_on(DBG_FLOW)) show_debug_message("IF-block map built (" + string(ds_map_size(global.if_block_map)) + " blocks)");

    // ── VALIDATE: visible errors + correct room ───────────────────────────
    // Assumes basic_validate_program() exists.
    if (!basic_validate_program()) {
        // Validator already printed a visible error & set end flags.
        // Ensure the user can see it.
        if (room != rm_basic_interpreter) room_goto(rm_basic_interpreter);
        return;
    }

    // ── Clean start: clear output buffers for a fresh run ─────────────────
    ds_list_clear(global.output_lines);
    ds_list_clear(global.output_colors);
    global.print_line_buffer = "";

    // ── Interpreter state ─────────────────────────────────────────────────
    global.interpreter_input    = "";
    global.awaiting_input       = false;
    global.input_target_var     = "";
    global.interpreter_running  = true;
    global.program_has_ended    = false;

    global.pause_in_effect      = false;
    global.pause_mode           = false;
    global.input_expected       = false;

    global.inkey_mode           = false;
    global.inkey_waiting        = false;
    global.inkey_captured       = "";
    global.inkey_target_var     = "";

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

    // Where to return when done
    global.editor_return_room = room;

    // Go to interpreter room (only if not already there)
    if (room != rm_basic_interpreter) room_goto(rm_basic_interpreter);
}
