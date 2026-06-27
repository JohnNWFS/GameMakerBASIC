/// @event obj_tile_editor/Create

tile_code = 200;
tile_w = TILE_EDITOR_DEFAULT_SIZE;
tile_h = TILE_EDITOR_DEFAULT_SIZE;
cursor_x = 0;
cursor_y = 0;
erase_mode = false;
color_index = 2; // CYAN
fg_color = tile_editor_color_at(color_index);
bg_color = c_black;
ui_mode = "edit";
file_list = [];
file_sel = 0;
last_filename = "tiles";
filename_input = "";
filename_kb_prev = "";
undo_has = false;
undo_code = -1;
undo_w = 0;
undo_h = 0;
undo_bits = "";
status_msg = "";
status_timer = 0;
repeat_key = 0;
repeat_timer = 0;
mouse_paint_down = false;

tile_editor_prepare_code(tile_code, tile_w, tile_h);
keyboard_string = "";