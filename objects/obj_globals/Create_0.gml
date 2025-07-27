	/// @description All Global Variables
	// obj_globals → Create Event
	global.justreturned = 0;
	global.program_filename = "";
	global.username = "";
	// Add any future global state here
	global.editor_spawned = false;

	global.program_lines = ds_map_create();
	global.basic_program = ds_map_create();
	

	global.line_numbers = ds_list_create();
	global.undo_stack = ds_list_create();
	global.output_lines = ds_list_create();
	global.output_colors = ds_list_create();
	
	// obj_globals → Create Event
	global.input_history = ds_list_create();

	global.history_index = -1;


	// Spawn the editor after globals are ready
	instance_create_layer(0, 0, "Instances", obj_editor);

	if (!variable_global_exists("basic_variables")) {
	    global.basic_variables = ds_map_create();
	}

	global.print_line_buffer = "";

	global.basic_text_color = c_green; // default color
	global.current_draw_color = c_green; //current color

	//For Input command
	// Interpreter input state
	global.awaiting_input = false;
	global.input_target_var = "";
	global.interpreter_input = "";
	global.interpreter_cursor_pos = 0;
	global.interpreter_running = false;
	global.last_interpreter_string = "";



