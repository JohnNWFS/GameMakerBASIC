/// @event obj_basic_interpreter/Create

    global.debug_mask        = DBG_ALL;//0;//DBG_ALL;   // start verbose; you can trim later
    global.dbg_frame_quota   = 0;      // 1200 is ~20 logs per ms at 60fps is ok; tune as needed
    global.dbg_frame_count   = 0;
    global.dbg_dropped_count = 0;

// Set the current draw color
global.current_draw_color = global.basic_text_color;

// program_map / line_list / line_index_map are set by run_program → basic_program_sync_runtime()

// Interpreter control variables
line_index = 0;                         // current line being executed
font_height = 16;

current_input = "";
cursor_pos = 0;
last_keyboard_string = "";

// Only reset the program counter when no program is already running.
// Room transitions (MODE switches) must preserve the current line index.
if (!variable_global_exists("interpreter_running") || !global.interpreter_running) {
    global.interpreter_current_line_index = 0;
    global.interpreter_next_line = -1;
    line_index = 0;
} else {
    // Restore the local line_index from the global so Step doesn't clobber it on first frame.
    line_index = global.interpreter_current_line_index;
}

// Local list to hold current run if needed
interpreter_current_program = ds_list_create(); // OK to keep local

basic_run_to_console_flag = false;

if (!variable_global_exists("help_topics") || !ds_exists(global.help_topics, ds_type_list)) {
    global.help_topics = ds_list_create();
} else {
    ds_list_clear(global.help_topics);
}

// PRINT tab stop width (classic BASIC style)
if (is_undefined(global.print_zone)) global.print_zone = 14;


