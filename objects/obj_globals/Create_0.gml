/// @event obj_globals/Create
// obj_globals → Create Event



var save_dir = get_save_directory();
if (save_dir != "") {
    if (!directory_exists(save_dir)) {
        directory_create(save_dir);
    }
}

global.debug_mask = DBG_FLOW | DBG_IO | DBG_ARRAY;
//global.debug_mask = DBG_ALL; //Very verbose: parser/evaluator tracing
//global.debug_mask = 0; //No Debug

global.debug_to_file = true;
global.debug_file_path = "";
global.dbg_frame_quota = 10000;
global.dbg_frame_count = 0;
global.dbg_dropped_count = 0;

global.justreturned = 0;
global.program_filename = "";
global.username = "";
global.editor_spawned = false;

// Program and source management
global.program_map  = ds_map_create();
global.line_index_map = ds_map_create();

// Line tracking (sorted line numbers; shares storage with runtime)
global.line_list    = ds_list_create();
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

global.config = ds_map_create();
global.config[? "max_line_number"] = 65535;
global.config[? "max_history_size"] = 50;
global.config[? "show_error_hints"] = true; // show compact help lines under syntax errors

// obj_editor is placed in rm_editor; do not create a second instance here.

// Initialize variable store
global.basic_variables = {};

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
global.input_ignore_enter_until_release = false;
global.input_guard_frames = 0;
global.interpreter_running = false;
global.last_interpreter_string = "";
global.program_has_ended = false;
global.pause_in_effect = false;
global.input_expected = false;
global.pause_mode = false;

// Scrolling control
global.scroll_offset = 0;
global.scroll_lock = false;

// Named colors (struct — shared by basic_parse_color and expression evaluator)
basic_colors_init();

// MODE control
// Public BASIC modes: 0/1 = text, 2 = tile graphics, 3 = pixel graphics.
// MODE 0 remains as a compatibility alias for text mode.
global.current_mode = 0;
global.mode_rooms = ds_map_create();
if (os_type == os_gxgames || os_browser != browser_not_a_browser) {
    global.mode_rooms[? 0] = rm_html5_basic_interpreter; // Text + on-screen keyboard
    global.mode_rooms[? 1] = rm_html5_basic_interpreter; // Text + on-screen keyboard
    global.mode_rooms[? 2] = rm_html5_mode1_graphics;    // Tile graphics + on-screen keyboard
    global.mode_rooms[? 3] = rm_html5_mode2_pixel;       // Pixel graphics + on-screen keyboard
} else {
    global.mode_rooms[? 0] = rm_basic_interpreter; // Text
    global.mode_rooms[? 1] = rm_basic_interpreter; // Text
    global.mode_rooms[? 2] = rm_mode1_graphics;    // Tile graphics
    global.mode_rooms[? 3] = rm_mode2_pixel;       // Pixel graphics
}

// MODE 1 sprite sheet container
// FONT registry for MODE 1
global.font_sheets = ds_map_create();
global.custom_tile_defs = ds_map_create();

// Base character sheet
ds_map_add(global.font_sheets, "DEFAULT", spr_charactersheet);

// Special 32×32 or alt glyphs
ds_map_add(global.font_sheets, "SPECIAL", spr_charactersheet_special);

// 16×16 set
ds_map_add(global.font_sheets, "16x16", spr_charactersheet_16x16);
ds_map_add(global.font_sheets, "16x16_SPECIAL", spr_charactersheet_16x16_special);

// 8×8 set
ds_map_add(global.font_sheets, "8x8", spr_charactersheet_8x8);
ds_map_add(global.font_sheets, "DEFAULT_32", spr_charactersheet);
ds_map_add(global.font_sheets, "DEFAULT_16", spr_charactersheet_16x16);
ds_map_add(global.font_sheets, "DEFAULT_8",  spr_charactersheet_8x8);

ds_map_add(global.font_sheets, "SPECIAL_16", spr_charactersheet_16x16_special);

// Initialize active sheet
global.mode1_active_sprite   = global.font_sheets[? "DEFAULT_32"];
global.mode1_active_font_key = "DEFAULT_32";
global.mode1_cell_px         = 32;

global.active_font_name = "DEFAULT";
global.active_font_sprite = global.font_sheets[? global.active_font_name];

global.grid_refresh_needed = false;
global.grid_refresh_char = 32;

global.basic_arrays = ds_map_create();      // name → native GML array (flat row-major storage)
global.basic_array_dims = ds_map_create(); // name → GML array of dimension sizes
global.basic_file_handles = ds_map_create(); // channel# → GML file handle
global.basic_file_modes   = ds_map_create(); // channel# → "INPUT"/"OUTPUT"/"APPEND"

global.interpreter_target_line = -1;
global.interpreter_target_stmt = 0;
global.interpreter_use_stmt_jump = false;
global.interpreter_resume_stmt_index = 0;

global.interpreter_current_stmt_index = 0;

// === DATA/READ globals ===
// Create once; the builder will clear/reuse it each run.
if (!variable_global_exists("data_streams") || !ds_exists(global.data_streams, ds_type_map)) {
    global.data_streams = ds_map_create();
    dbg_log(DBG_FLOW, "globals: created global.data_streams");
}


if (!variable_global_exists("__inkey_queue")) {
    global.__inkey_queue = ds_queue_create();
}

global.inkey_mode = false; 
global.pause_in_effect = false; 
global.inkey_waiting    = false;
global.inkey_captured   = "";
global.inkey_target_var = "";
global.inkey_release_guard = false;
global.interpreter_current_line_index = 0; 


global._syntax_error_just_emitted = false;

// optional, if you use these
global._validator_header_emitted = false;
global._abort_after_validation   = false;

// Where to return when leaving the interpreter
global.editor_return_room = room; // whatever room the editor lives in at startup

global.screen_edit_mode = false; //for scree editing

global.stop_breakpoint_active = false;
global.stop_resume_line_index   = 0;
global.stop_resume_stmt_index   = 0;
global.on_error_goto_line       = 0;
global.error_trap_active        = false;
global.err_last_line            = 0;
global.err_fault_line_index     = -1;
global.err_fault_stmt_index     = -1;
global.err_last_code            = 0;
dbg_log(DBG_FLOW, "GLOBALS: screen_edit_mode initialized to false");


/// Put near your other globals the first time you use them:
if (!variable_global_exists("__html_dir_opening")) global.__html_dir_opening = false;
if (!variable_global_exists("__html_dir_open_time")) global.__html_dir_open_time = 0;

if (!variable_global_exists("DEBUG_INPUT")) global.DEBUG_INPUT = false;

if (!variable_global_exists("help_topics") || !ds_exists(global.help_topics, ds_type_list)) {
        global.help_topics = ds_list_create();
    } else {
        ds_list_clear(global.help_topics);
    }
	
global.print_zone = 14; // width
global.print_tab_mode = 1; 
// 0 = zones (BASIC default), 1 = fixed-width tabs
// === Beep subsystem ===
global.beep_tempo = 120; // BPM
global.beep_volume = 0.35; // Generated tone amplitude; low notes get a small perceptual boost.
global.beep_note_gate = 0.90; // Note sound length as a fraction of its rhythmic duration.
global.beep_sample_rate = 44100;
global.beep_waiting = false;
global.beep_release_time = 0;
global.beep_instance = -1;
global.beep_generated_sound = -1;
global.beep_generated_buffer = -1;
global.beep_seq_active = 0;
global.beep_break_requested = false;

 global.gosub_targets = ds_map_create();
global.option_base = 1; // default: arrays are 1-based (OPTION BASE 1)

bas_sprite_init();
