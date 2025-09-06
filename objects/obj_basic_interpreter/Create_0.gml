/// @event obj_basic_interpreter/Create

    global.debug_mask        = DBG_ALL;//0;//DBG_ALL;   // start verbose; you can trim later
    global.dbg_frame_quota   = 0;      // 1200 is ~20 logs per ms at 60fps is ok; tune as needed
    global.dbg_frame_count   = 0;
    global.dbg_dropped_count = 0;

// Set the current draw color
global.current_draw_color = global.basic_text_color;

// Use the shared global data structures
global.program_map  = global.basic_program; // optional if you're not modifying
global.line_list    = global.basic_line_numbers;

// Interpreter control variables
line_index = 0;                         // current line being executed
font_height = 16;

current_input = "";
cursor_pos = 0;
last_keyboard_string = "";

global.interpreter_current_line_index = 0;
global.interpreter_next_line = -1;

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


