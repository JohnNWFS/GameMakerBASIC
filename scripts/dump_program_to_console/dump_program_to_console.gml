function dump_program_to_console() {
    var lines = global.line_list;
    var prog = global.program_map;
    if (!ds_exists(prog, ds_type_map) || !ds_exists(lines, ds_type_list)) {
        show_debug_message("No program in memory.");
        return;
    }
    for (var i = 0; i < ds_list_size(lines); i++) {
        var ln = ds_list_find_value(lines, i);
        show_debug_message(string(ln) + " " + string(ds_map_find_value(prog, ln)));
    }
}