function autotest_bootstrap() {
    if (os_type == os_gxgames || os_browser != browser_not_a_browser) return false;
    if (!variable_global_exists("config") || !ds_exists(global.config, ds_type_map)) return false;

    if (!variable_global_exists("autotest_bootstrapped")) {
        global.autotest_bootstrapped = false;
    }
    if (global.autotest_bootstrapped) return false;
    global.autotest_bootstrapped = true;

    var filename = "autotest.bas";
    var path = get_save_directory() + filename;
    if (!file_exists(path)) {
        dbg_log(DBG_FLOW, "AUTOTEST: no " + path);
        return false;
    }

    dbg_log(DBG_FLOW, "AUTOTEST: loading " + path);

    global.autotest_run_active = true;
    global.autotest_source_text = "";
    var src = file_text_open_read(path);
    while (!file_text_eof(src)) {
        global.autotest_source_text += file_text_read_string(src) + "\n";
        file_text_readln(src);
    }
    file_text_close(src);

    load_program_from(filename);

    if (string_pos("AUTOTEST_TILEEDIT", string_upper(global.autotest_source_text)) > 0) {
        basic_output_transcript_reset();
        autotest_seed_tile_editor_demo();
        global.autotest_tileedit_capture = true;
        start_tile_editor();
        if (file_exists(path)) {
            file_delete(path);
            dbg_log(DBG_FLOW, "AUTOTEST: consumed and deleted " + path);
        }
        dbg_log(DBG_FLOW, "AUTOTEST: launched TILEEDIT for screenshot");
        return true;
    }

    if (file_exists(path)) {
        file_delete(path);
        dbg_log(DBG_FLOW, "AUTOTEST: consumed and deleted " + path);
    }

    if (ds_exists(global.line_list, ds_type_list) && ds_list_size(global.line_list) > 0) {
        dbg_log(DBG_FLOW, "AUTOTEST: running " + filename);
        run_program();
        return true;
    }

    dbg_log(DBG_FLOW, "AUTOTEST: load produced no runnable lines");
    return false;
}
