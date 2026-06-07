function dbg_timestamp_string() {
    var dt = date_current_datetime();
    var yy = string(date_get_year(dt));
    var mo = string(date_get_month(dt));
    var dd = string(date_get_day(dt));
    var hh = string(date_get_hour(dt));
    var mi = string(date_get_minute(dt));
    var ss = string(date_get_second(dt));

    if (string_length(mo) < 2) mo = "0" + mo;
    if (string_length(dd) < 2) dd = "0" + dd;
    if (string_length(hh) < 2) hh = "0" + hh;
    if (string_length(mi) < 2) mi = "0" + mi;
    if (string_length(ss) < 2) ss = "0" + ss;

    return yy + mo + dd + "_" + hh + mi + ss;
}

function dbg_prepare_file() {
    if (!variable_global_exists("debug_to_file") || !global.debug_to_file) return false;

    if (!variable_global_exists("debug_file_path") || global.debug_file_path == "") {
        var dir = working_directory + "output/debug";
        if (!directory_exists(working_directory + "output")) directory_create(working_directory + "output");
        if (!directory_exists(dir)) directory_create(dir);
        global.debug_file_path = dir + "/nw_basic_debug_" + dbg_timestamp_string() + ".log";
    }

    return true;
}

function dbg_emit(msg) {
    show_debug_message(msg);

    if (!dbg_prepare_file()) return;

    var f = file_text_open_append(global.debug_file_path);
    file_text_write_string(f, string(msg));
    file_text_writeln(f);
    file_text_close(f);
}

function dbg(cat, msg) {
    if ((global.debug_mask & cat) == 0) return;

    if (global.dbg_frame_count >= global.dbg_frame_quota) {
        global.dbg_dropped_count++;
        return;
    }
    global.dbg_frame_count++;

    dbg_emit(msg);
}

function dbg_log(cat, msg) {
    if (!dbg_on(cat)) return;
    if (global.dbg_frame_count >= global.dbg_frame_quota) {
        global.dbg_dropped_count++;
        return;
    }
    global.dbg_frame_count++;
    dbg_emit(msg);
}
