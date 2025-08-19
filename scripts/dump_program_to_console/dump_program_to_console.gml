function dump_program_to_console() {
    if (dbg_on(DBG_FLOW)) show_debug_message("==== BASIC PROGRAM DUMP ====");

    var lines = global.line_numbers; // numeric line numbers
    var prog = global.program_lines;

    for (var i = 0; i < ds_list_size(lines); i++) {
        var linenum = ds_list_find_value(lines, i); // numeric
        if (ds_map_exists(prog, linenum)) {
            var code = ds_map_find_value(prog, linenum);
            if (dbg_on(DBG_FLOW)) show_debug_message(string(linenum) + " " + code);
        } else {
            if (dbg_on(DBG_FLOW)) show_debug_message("Missing entry for key: " + string(linenum));
        }
    }

    if (dbg_on(DBG_FLOW)) show_debug_message("==== END OF DUMP ====");
}
