/// @description Insert description here
// You can write your code in this editor
// obj_basic_interpreter Create event
show_debug_message("INTERPRETER CREATE - color is: " + string(global.current_draw_color));
show_debug_message("INTERPRETER CREATE - basic_text_color is: " + string(global.basic_text_color));  // ← ADD THIS
global.current_draw_color = global.basic_text_color;
show_debug_message("INTERPRETER CREATE AFTER RESET - color is: " + string(global.current_draw_color));

program_map  = ds_map_create();
ds_map_copy(program_map, global.basic_program);

line_list    = ds_list_create();
ds_list_copy(line_list, global.basic_line_numbers);

line_index   = 0;         // current line being executed
output_lines = ds_list_create(); // stores text printed by the program
font_height = 16;

current_input = "";
cursor_pos = 0;

last_keyboard_string = "";
interpreter_current_line_index = 0;

interpreter_current_program = ds_list_create();
interpreter_next_line = -1;

