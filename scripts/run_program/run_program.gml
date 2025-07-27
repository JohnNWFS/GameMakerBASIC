function run_program() {
	  show_debug_message("RUN_PROGRAM START - color is: " + string(global.current_draw_color));
    if (ds_list_size(global.line_numbers) == 0) {
        show_error_message("NO PROGRAM");
        return;
    }

    // Deep copy program data to prevent interpreter from modifying editor data
    ds_map_copy(global.basic_program, global.program_lines);

    global.basic_line_numbers = ds_list_create();
    ds_list_copy(global.basic_line_numbers, global.line_numbers);

    // ✅ Clear previous output
    if (ds_exists(global.output_lines, ds_type_list)) {
        ds_list_clear(global.output_lines);
    } else {
        global.output_lines = ds_list_create();
    }

    if (ds_exists(global.output_colors, ds_type_list)) {
        ds_list_clear(global.output_colors);
    } else {
        global.output_colors = ds_list_create();
    }

    // ✅ Reset interpreter state
    global.interpreter_input = "";
    global.awaiting_input = false;
    global.input_target_var = "";
    global.interpreter_running = true;

    global.current_draw_color = c_green;// global.basic_text_color;
    show_debug_message("RUN_PROGRAM AFTER RESET - color is: " + string(global.current_draw_color));
    
    interpreter_current_line_index = 0;
    interpreter_next_line = -1;

    // Store editor state to return to
    global.editor_return_room = room;

    // Switch to interpreter room
    room_goto(rm_basic_interpreter);
}
