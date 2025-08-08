/// @description All Global Variables
// obj_globals → Create Event

global.justreturned = 0;
global.program_filename = "";
global.username = "";
global.editor_spawned = false;

// Program and source management
global.program_lines = ds_map_create();
global.basic_program = ds_map_create();
global.program_map  = ds_map_create();

// Line tracking
global.line_list    = ds_list_create();
global.line_numbers = ds_list_create();
global.undo_stack = ds_list_create();
global.output_lines = ds_list_create();
global.output_colors = ds_list_create();
global.input_history = ds_list_create();

// Interpreter control stacks
global.gosub_stack = ds_stack_create();
global.for_stack   = ds_stack_create();
global.while_stack = ds_stack_create();
global.history_index = -1;

// IF…ELSE block handling
global.if_block_map = ds_map_create();
global.if_stack     = ds_stack_create();

// Spawn the editor after globals are ready
instance_create_layer(0, 0, "Instances", obj_editor);

// Initialize variable store
if (!variable_global_exists("basic_variables")) {
    global.basic_variables = ds_map_create();
}

// Output buffer
global.print_line_buffer = "";

// Color settings
global.basic_text_color = make_color_rgb(255, 191, 64);
global.current_draw_color = c_green;
global.background_draw_color = c_black;
global.background_draw_enabled = false;

// Input / Pause
global.awaiting_input = false;
global.input_target_var = "";
global.interpreter_input = "";
global.interpreter_cursor_pos = 0;
global.interpreter_running = false;
global.last_interpreter_string = "";
global.program_has_ended = false;
global.pause_in_effect = false;
global.input_expected = false;
global.pause_mode = false;

// Scrolling control
global.scroll_offset = 0;
global.scroll_lock = false;

// Named colors
global.colors = ds_map_create();
global.colors[? "RED"]     = c_red;
global.colors[? "GREEN"]   = c_green;
global.colors[? "BLUE"]    = c_blue;
global.colors[? "CYAN"]    = c_teal;
global.colors[? "MAGENTA"] = c_fuchsia;
global.colors[? "YELLOW"]  = c_yellow;
global.colors[? "WHITE"]   = c_white;
global.colors[? "BLACK"]   = c_black;
global.colors[? "GRAY"]    = c_gray;
global.colors[? "ORANGE"]  = c_orange;
global.colors[? "LIME"]    = c_lime;
global.colors[? "NAVY"] = make_color_rgb(0, 0, 128);
global.colors[? "DKGRAY"] = make_color_rgb(64, 64, 64);

// MODE control
global.current_mode = 0; // 0 = Text, 1 = Tile graphics, 2 = Pixel graphics
global.mode_rooms = ds_map_create();
global.mode_rooms[? 0] = rm_basic_interpreter; // Text
global.mode_rooms[? 1] = rm_mode1_graphics;    // Tile graphics
global.mode_rooms[? 2] = rm_mode2_pixel;       // Pixel graphics

//MODE 1 sprite sheet container
// FONT registry for MODE 1
global.font_sheets = ds_map_create();
ds_map_add(global.font_sheets, "DEFAULT", spr_charactersheet);
ds_map_add(global.font_sheets, "SPECIAL", spr_charactersheet_special);

global.active_font_name = "DEFAULT";
global.active_font_sprite = global.font_sheets[? global.active_font_name];

global.grid_refresh_needed = false;
global.grid_refresh_char = 32;

global.basic_arrays = ds_map_create(); // name (string) → ds_list

global.interpreter_target_line = -1;
global.interpreter_target_stmt = 0;
global.interpreter_use_stmt_jump = false;
global.interpreter_resume_stmt_index = 0;

global.interpreter_current_stmt_index = 0;




