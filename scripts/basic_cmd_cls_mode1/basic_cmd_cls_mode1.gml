// =================================================================
// MODE 1 Enhanced CLS - clear screen and reset cursor (auto 8/16/32)
// =================================================================
/// @function basic_cmd_cls_mode1()
/// @description Clears MODE 1 grid using current cell size (8/16/32) and
///              the active MODE 1 background color. Falls back to safe defaults.
///              Lazily creates the grid if missing, then resets the MODE 1 cursor.
function basic_cmd_cls_mode1() {
    // Ensure the grid exists (right after MODE 1 it might not yet)
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("CLS MODE1: No grid; creating");
        instance_create_layer(0, 0, "Instances", obj_mode1_grid);
        grid_obj = instance_find(obj_mode1_grid, 0);
        if (!instance_exists(grid_obj)) {
            if (dbg_on(DBG_FLOW)) show_debug_message("CLS MODE1: grid creation failed; abort");
            return;
        }
    }

    // --- Determine cell size variant (8 / 16 / 32) ---
    var cell_size = 16; // safe default
    if (variable_global_exists("mode1_cell_size") && is_real(global.mode1_cell_size)) {
        cell_size = global.mode1_cell_size;
    } else {
        // Try to read from the grid instance if it stores it
        with (grid_obj) {
            if (variable_instance_exists(id, "cell_size")) {
                cell_size = cell_size; // instance var
            } else if (variable_instance_exists(id, "mode1_cell_size")) {
                cell_size = mode1_cell_size; // alternate naming
            }
        }
    }
    if (cell_size != 8 && cell_size != 16 && cell_size != 32) cell_size = 16;

    // --- Determine colors: prefer current MODE 1 bg; fallback to black ---
    var bg_col = c_black;
    var fg_col = global.basic_text_color; // keep current text default for next draw

    if (variable_global_exists("mode1_bg_color") && is_real(global.mode1_bg_color)) {
        bg_col = global.mode1_bg_color;
    } else {
        // Try to read from the grid if it tracks a bg_color
        with (grid_obj) {
            if (variable_instance_exists(id, "bg_color")) {
                bg_col = bg_color;
            }
        }
    }

    if (variable_global_exists("mode1_fg_color") && is_real(global.mode1_fg_color)) {
        fg_col = global.mode1_fg_color;
    }

    // --- Choose fill char by mode; default SPACE (32) works for all ---
    // You can customize per-size if you prefer (e.g., 0 for 8px glyph planes).
    var fill_char = 32; // SPACE

    // Apply clear to the grid
    with (grid_obj) {
        // If your grid tracks bg_color internally, refresh it first (optional)
        if (variable_instance_exists(id, "bg_color")) bg_color = bg_col;

        mode1_grid_fill(fill_char, fg_col, bg_col);
    }

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("CLS MODE1: Grid cleared (cell_size=" + string(cell_size)
            + ", fill=" + string(fill_char) + ", fg=" + string(fg_col) + ", bg=" + string(bg_col) + ")");
    }

    // Reset cursor to top-left for MODE 1
    global.mode1_cursor_x = 0;
    global.mode1_cursor_y = 0;
    if (dbg_on(DBG_FLOW)) show_debug_message("CLS MODE1: Cursor reset to (0,0)");
}
