/// @description Insert description here
// You can write your code in this editor
 // Program storage


 // Input handling
 current_input = "";               // Current line being typed
 cursor_pos = 0;                  // Text cursor position


 input_buffer = "";               // Buffer for key repeat handling
 // Display variables
 display_start_line = 0;          // For scrolling through program
 lines_per_screen = 20;           // How many lines to show
 font_height = 16;                // Adjust based on your font
 screen_width = room_width;
 screen_height = room_height;
 // Syntax highlighting settings
 syntax_highlighting = true;      // Toggle for syntax highlighting
 keyword_color = c_blue;          // Color for BASIC keywords
 text_color = c_green;            // Default text color
 number_color = c_yellow;         // Color for line numbers
 // State management
 editor_mode = "READY";           // States: "READY", "INPUT", "RUNNING"
 current_filename = "";           // For save/load operations
 // Keyboard handling
 last_keyboard_string = "";       // Track keyboard_string changes
 key_repeat_timer = 0;            // For handling key repeat timing
 // Undo system

 max_undo_levels = 20;            // Limit undo history
 // Message system
 message_text = "";
 message_timer = 0;
 
 drag_enabled = true;
 //show_debug_message("Working directory: " + working_directory);
