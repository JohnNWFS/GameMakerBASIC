/// @function basic_cmd_mode(arg)
/// @description Sets the mode and switches to the appropriate room
function basic_cmd_mode(arg) {
    var mode = real(string_trim(arg));
    if (!ds_map_exists(global.mode_rooms, mode)) {
        basic_show_message("Invalid MODE: " + string(mode));
        return;
    }

    if (mode == global.current_mode) {
        show_debug_message("MODE already set to " + string(mode) + "; no room switch needed.");
        return;
    }

    global.current_mode = mode;
    show_debug_message("Switching to MODE " + string(mode) + " → room: " + string(global.mode_rooms[? mode]));
    room_goto(global.mode_rooms[? mode]);
}
