// FILE: objects/obj_screen_editor/Create_0.gml
// CHANGE: Make screen dimensions dynamic based on room size

show_debug_message("SCREEN_EDITOR: Create start");

// Display settings - calculate from room dimensions
char_width = 16;   // pixels per character
char_height = 24;  // pixels per character  
margin_x = 8;      // left margin
margin_y = 8;      // top margin

// NEW: Calculate screen dimensions dynamically from room size
screen_cols = floor((room_width - (margin_x * 2)) / char_width);   // Dynamic width
screen_rows = floor((room_height - (margin_y * 2) - 40) / char_height); // Dynamic height (40px for status)

show_debug_message("SCREEN_EDITOR: Calculated screen size - " + string(screen_cols) + "x" + string(screen_rows) + 
                  " (room: " + string(room_width) + "x" + string(room_height) + ")");

// Create character buffer - 2D array stored as 1D
screen_buffer = array_create(screen_cols * screen_rows, ord(" "));

// Cursor position
cursor_x = 0;
cursor_y = 0;

// Add after existing cursor variables
horizontal_offset = 0;  // How many characters scrolled left
scroll_margin = 5;      // Start scrolling when cursor is this close to edge


// Add scrolling support
scroll_offset = 0;  // Which line is at the top of the display

// Cursor blink
blink_timer = 0;
cursor_visible = true;

// Load existing program into screen buffer using helper script
screen_editor_load_program(id);

show_debug_message("SCREEN_EDITOR: Create complete - " + string(screen_cols) + "x" + string(screen_rows) + " buffer");