// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function basic_cmd_charat(arg) {
    var args = string_split(arg, ",");

    if (array_length(args) < 3) {
        if (dbg_on(DBG_FLOW))  show_debug_message("CHARAT requires 3 arguments: x, y, char");
        return;
    }

    var _x = real(string_trim(args[0]));
    var _y = real(string_trim(args[1]));
    var char_index = real(string_trim(args[2]));

    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (instance_exists(grid_obj)) {
        var cols = 40;
        var rows = 25;
        if (_x >= 0 && _x < cols && _y >= 0 && _y < rows) {
            var index = _x + _y * cols;
            grid_obj.grid[index].char = char_index;
        } else {
            if (dbg_on(DBG_FLOW))  show_debug_message("CHARAT: coordinates out of bounds.");
        }
    }
}
