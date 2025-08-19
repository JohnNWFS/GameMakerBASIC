// =================================================================
// MODE 1 Enhanced CLS - clear screen and reset cursor
// =================================================================
/// @function basic_cmd_cls_mode1()
/// @description MODE 1 version of CLS that clears the grid and resets cursor
function basic_cmd_cls_mode1() {
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (instance_exists(grid_obj)) {
        with (grid_obj) {
            mode1_grid_fill(32, c_white, c_black); // Clear with spaces
        }
        if (dbg_on(DBG_FLOW)) show_debug_message("CLS MODE1: Grid cleared");
    }
    
    // Reset cursor to top-left
    global.mode1_cursor_x = 0;
    global.mode1_cursor_y = 0;
    
    if (dbg_on(DBG_FLOW)) show_debug_message("CLS MODE1: Cursor reset to (0,0)");
}