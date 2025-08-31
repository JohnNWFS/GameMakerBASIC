show_debug_message("SCREEN_EDITOR: Create start");

// Sizing (keep your existing numbers if different)
char_width  = 16;
char_height = 24;
margin_x    = 8;
margin_y    = 8;

// Dynamic screen size
screen_cols = floor((room_width  - (margin_x * 2)) / char_width);
screen_rows = floor((room_height - (margin_y * 2) - 40) / char_height);

show_debug_message("SCREEN_EDITOR: Calculated screen size - " + string(screen_cols) + "x" + string(screen_rows) +
                   " (room: " + string(room_width) + "x" + string(room_height) + ")");

// Backing char buffer (your renderer already expects this)
screen_buffer = array_create(screen_cols * screen_rows, ord(" "));

// Cursor & scroll
cursor_x = 0;
cursor_y = 0;
horizontal_offset = 0;
scroll_margin = 5;
scroll_offset = 0;

// Caret blink
blink_timer = 0;
cursor_visible = true;

// NEW: live text buffer for the current row in this view
current_input = "";

// Pull program into buffer for display
screen_editor_load_program(id);

keyboard_string = ""; // start clean

show_debug_message("SCREEN_EDITOR: Create complete - " + string(screen_cols) + "x" + string(screen_rows) + " buffer");
