function dump_program_to_console() {
    dbg_log(DBG_FLOW, "==== BASIC PROGRAM DUMP ====");

    var lines = global.line_numbers; // numeric line numbers
    var prog = global.program_lines;

    for (var i = 0; i < ds_list_size(lines); i++) {
        var linenum = ds_list_find_value(lines, i); // numeric
        if (ds_map_exists(prog, linenum)) {
            var code = ds_map_find_value(prog, linenum);
            dbg_log(DBG_FLOW, string(linenum) + " " + code);
        } else {
            dbg_log(DBG_FLOW, "Missing entry for key: " + string(linenum));
        }
    }

    dbg_log(DBG_FLOW, "==== END OF DUMP ====");
}
