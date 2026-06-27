/// @event obj_mode1_grid/Create
tile_width = 32;
tile_height = 32;
drewfont = 0;

grid_cols = floor(room_width  / global.mode1_cell_px);
grid_rows = floor(room_height / global.mode1_cell_px);
grid = mode1_grid_alloc(grid_cols, grid_rows);
needs_redraw = true;
grid_surface = -1;

self.mode1_grid_fill = function(char, fg, bg) {
    dbg_log(DBG_FLOW, ">> GRID FILL START: char=" + string(char) + ", fg=" + string(fg) + ", bg=" + string(bg));
    mode1_grid_fill_all(self, char, fg, bg);
    dbg_log(DBG_FLOW, ">> GRID FILL END");
};

if (is_undefined(global.mode1_active_sprite)) {
    global.mode1_active_sprite = global.font_sheets[? "DEFAULT_32"];
}