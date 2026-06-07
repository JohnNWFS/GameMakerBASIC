function autotest_bootstrap() {
    if (os_browser != browser_not_a_browser) return false;
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
    load_program_from(filename);

    if (ds_exists(global.line_numbers, ds_type_list) && ds_list_size(global.line_numbers) > 0) {
        dbg_log(DBG_FLOW, "AUTOTEST: running " + filename);
        run_program();
        return true;
    }

    dbg_log(DBG_FLOW, "AUTOTEST: load produced no runnable lines");
    return false;
}
