function basic_output_transcript_path() {
    return get_save_directory() + "autotest_output.txt";
}

function basic_output_transcript_reset() {
    global.autotest_transcript_enabled = false;
    global.autotest_transcript_path = basic_output_transcript_path();
    global.autotest_transcript_finalized = false;
    global.autotest_screenshot_requested = false;

    if (os_browser != browser_not_a_browser) return;

    var autotest_path = get_save_directory() + "autotest.bas";
    global.autotest_transcript_enabled = file_exists(autotest_path);
    if (!global.autotest_transcript_enabled) return;

    var src = file_text_open_read(autotest_path);
    while (!file_text_eof(src)) {
        var line_text = string_upper(file_text_read_string(src));
        file_text_readln(src);
        if (string_pos("AUTOTEST_SCREENSHOT", line_text) > 0) {
            global.autotest_screenshot_requested = true;
        }
    }
    file_text_close(src);

    if (file_exists(global.autotest_transcript_path)) {
        file_delete(global.autotest_transcript_path);
    }

    var f = file_text_open_write(global.autotest_transcript_path);
    file_text_write_string(f, "# NW-BASIC AUTOTEST TRANSCRIPT");
    file_text_writeln(f);
    file_text_write_string(f, global.autotest_screenshot_requested ? "# MODE=SCREENSHOT" : "# MODE=TEXT");
    file_text_writeln(f);
    file_text_write_string(f, global.autotest_screenshot_requested ? "# SCREENSHOT=REQUESTED" : "# SCREENSHOT=OPTIONAL");
    file_text_writeln(f);
    file_text_writeln(f);
    file_text_close(f);
}

function basic_output_transcript_append(_line) {
    if (os_browser != browser_not_a_browser) return;
    if (!variable_global_exists("autotest_transcript_enabled") || !global.autotest_transcript_enabled) return;

    var path = global.autotest_transcript_path;
    if (is_undefined(path) || path == "") path = basic_output_transcript_path();

    var line_out = string(_line);
    while (string_length(line_out) > 0 && string_char_at(line_out, string_length(line_out)) == " ") {
        line_out = string_delete(line_out, string_length(line_out), 1);
    }

    var f = file_exists(path) ? file_text_open_append(path) : file_text_open_write(path);
    file_text_write_string(f, line_out);
    file_text_writeln(f);
    file_text_close(f);
}

function basic_output_commit(_line, _color) {
    ds_list_add(global.output_lines, _line);
    ds_list_add(global.output_colors, _color);
    basic_output_transcript_append(_line);
}

function basic_output_transcript_finalize() {
    if (!variable_global_exists("autotest_transcript_enabled") || !global.autotest_transcript_enabled) return;
    if (variable_global_exists("autotest_transcript_finalized") && global.autotest_transcript_finalized) return;

    global.autotest_transcript_finalized = true;
    basic_output_transcript_append("");
    basic_output_transcript_append("Program has ended - ESC or ENTER to return");
}
