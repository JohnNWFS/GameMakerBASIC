// @description obj_mode1_grid Create Event
//Create 40x25 grid for 32x32 character tiles
grid_cols = 40;
grid_rows = 25;
tile_width = 32;
tile_height = 32;

grid = array_create(grid_cols * grid_rows);

// Each grid cell will be a struct:
function make_tile_struct(char = 32, fg = c_white, bg = c_black) {
    return { char: char, fg: fg, bg: bg };
}

// Initialize all tiles
for (var i = 0; i < array_length(grid); i++) {
    grid[i] = make_tile_struct();
}

self.mode1_grid_fill = function(char, fg, bg) {
    if (dbg_on(DBG_FLOW))  show_debug_message(">> GRID FILL START: char=" + string(char) + ", fg=" + string(fg) + ", bg=" + string(bg));
    if (dbg_on(DBG_FLOW))  show_debug_message(">> Grid array length: " + string(array_length(grid)));
    
    for (var i = 0; i < array_length(grid); i++) {
        grid[i].char = char;
        grid[i].fg = fg;
        grid[i].bg = bg;
    }
    
    // Check first few tiles to verify they were set
    for (var i = 0; i < 3; i++) {
        if (dbg_on(DBG_FLOW))  show_debug_message(">> Tile[" + string(i) + "]: char=" + string(grid[i].char) + ", fg=" + string(grid[i].fg) + ", bg=" + string(grid[i].bg));
    }
    if (dbg_on(DBG_FLOW))  show_debug_message(">> GRID FILL END");
}

	drewfont = 0;//temp var

	// CHANGE: compute cols/rows from cell size

	grid_cols = floor(room_width  / global.mode1_cell_px); // 40 @ 32px in 1280 room
	grid_rows = floor(room_height / global.mode1_cell_px); // 25 @ 32px in 800 room


	grid = array_create(grid_cols * grid_rows);

	for (var i = 0; i < array_length(grid); i++) {
	    grid[i] = { char: 32, fg: c_white, bg: c_black };
	}

	// Ensure sprite active
	if (is_undefined(global.mode1_active_sprite)) {
	    global.mode1_active_sprite = global.font_sheets[? "DEFAULT_32"];
	}

