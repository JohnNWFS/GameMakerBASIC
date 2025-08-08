function run_program() {
    show_debug_message("RUN_PROGRAM START - color is: " + string(global.current_draw_color));

    // Guard: no program
    if (ds_list_size(global.line_numbers) == 0) {
        show_error_message("NO PROGRAM");
        return;
    }

    // Deep copy program data to prevent interpreter from modifying editor data
    ds_map_copy(global.basic_program, global.program_lines);

    // Copy line numbers into a working list
    global.basic_line_numbers = ds_list_create();
    ds_list_copy(global.basic_line_numbers, global.line_numbers);

    // Build IF-block map
    build_if_block_map();
    show_debug_message("IF-block map built (" + string(ds_map_size(global.if_block_map)) + " blocks)");

    // ─────────────────────────────────────────────────────────
    // OUTPUT BUFFERS (your original create/clear logic + logs)
    // ─────────────────────────────────────────────────────────
    show_debug_message("RUN_PROGRAM: preparing output buffers…");

    if (!is_real(global.output_lines) || !ds_exists(global.output_lines, ds_type_list)) {
        show_debug_message("RUN_PROGRAM: creating global.output_lines");
        global.output_lines = ds_list_create();
    } else {
        show_debug_message("RUN_PROGRAM: clearing global.output_lines (size="
            + string(ds_list_size(global.output_lines)) + ")");
        ds_list_clear(global.output_lines);
    }

    if (!is_real(global.output_colors) || !ds_exists(global.output_colors, ds_type_list)) {
        show_debug_message("RUN_PROGRAM: creating global.output_colors");
        global.output_colors = ds_list_create();
    } else {
        show_debug_message("RUN_PROGRAM: clearing global.output_colors (size="
            + string(ds_list_size(global.output_colors)) + ")");
        ds_list_clear(global.output_colors);
    }

    // Reset any buffered partial PRINT text so we don't carry over from previous run
    if (is_undefined(global.print_line_buffer)) {
        show_debug_message("RUN_PROGRAM: print_line_buffer was undefined → init to empty");
        global.print_line_buffer = "";
    } else if (string_length(global.print_line_buffer) > 0) {
        show_debug_message("RUN_PROGRAM: print_line_buffer had leftovers → '" 
            + string(global.print_line_buffer) + "' → clearing");
        global.print_line_buffer = "";
    }

    // Interpreter state
    global.interpreter_input  = "";
    global.awaiting_input     = false;
    global.input_target_var   = "";
    global.interpreter_running = true;

    // Set draw color for this run (your existing choice)
    global.current_draw_color = make_color_rgb(255, 191, 64); // Amber

    // Line navigation state
    global.interpreter_current_line_index = 0;
    global.interpreter_next_line = -1;

    // Remember where to return after running
    global.editor_return_room = room;

    // Go to interpreter room
    room_goto(rm_basic_interpreter);
}
