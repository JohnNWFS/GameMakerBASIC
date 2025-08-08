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
    show_debug_message(">> GRID FILL START: char=" + string(char) + ", fg=" + string(fg) + ", bg=" + string(bg));
    show_debug_message(">> Grid array length: " + string(array_length(grid)));
    
    for (var i = 0; i < array_length(grid); i++) {
        grid[i].char = char;
        grid[i].fg = fg;
        grid[i].bg = bg;
    }
    
    // Check first few tiles to verify they were set
    for (var i = 0; i < 3; i++) {
        show_debug_message(">> Tile[" + string(i) + "]: char=" + string(grid[i].char) + ", fg=" + string(grid[i].fg) + ", bg=" + string(grid[i].bg));
    }
    show_debug_message(">> GRID FILL END");
}

drewfont = 0;//temp var

