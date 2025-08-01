/// obj_basic_interpreter → Create Event

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

interpreter_current_line_index = 0;
interpreter_next_line = -1;

// Local list to hold current run if needed
interpreter_current_program = ds_list_create(); // OK to keep local

