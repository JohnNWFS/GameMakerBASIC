/// basic_cmd_open(arg)
/// Syntax: OPEN "filename" FOR INPUT|OUTPUT|APPEND AS #n
function basic_cmd_open(arg) {
    var _up = string_upper(arg);

    // Find "FOR" at top level (outside quotes)
    var _for_pos = 0;
    var _inq = false;
    for (var _i = 1; _i <= string_length(arg) - 3; _i++) {
        var _c = string_char_at(arg, _i);
        if (_c == "\"") _inq = !_inq;
        if (!_inq && string_copy(_up, _i, 4) == "FOR ") { _for_pos = _i; break; }
    }
    if (_for_pos == 0) {
        basic_syntax_error("OPEN: missing FOR", global.current_line_number, 0, "OPEN_SYNTAX");
        return;
    }

    var _fname_expr = string_trim(string_copy(arg, 1, _for_pos - 1));
    var _after_for  = string_trim(string_copy(arg, _for_pos + 4, string_length(arg)));

    // After FOR: "INPUT AS #n" / "OUTPUT AS #n" / "APPEND AS #n"
    var _up2    = string_upper(_after_for);
    var _as_pos = string_pos(" AS ", _up2);
    if (_as_pos == 0) {
        basic_syntax_error("OPEN: missing AS", global.current_line_number, 0, "OPEN_SYNTAX");
        return;
    }

    var _mode_str = string_upper(string_trim(string_copy(_after_for, 1, _as_pos - 1)));
    var _chan_str  = string_trim(string_copy(_after_for, _as_pos + 4, string_length(_after_for)));
    if (string_length(_chan_str) > 0 && string_char_at(_chan_str, 1) == "#") {
        _chan_str = string_copy(_chan_str, 2, string_length(_chan_str) - 1);
    }

    var _chan_arg = basic_eval_int_arg(_chan_str, "OPEN", "channel");
    if (!_chan_arg.ok) return;
    var _chan = _chan_arg.value;
    var _fname = string(basic_evaluate_expression_v2(_fname_expr));
    var _fpath = get_save_directory() + _fname;

    // Close existing handle on this channel if open
    if (ds_map_exists(global.basic_file_handles, _chan)) {
        file_text_close(global.basic_file_handles[? _chan]);
        ds_map_delete(global.basic_file_handles, _chan);
        ds_map_delete(global.basic_file_modes, _chan);
    }

    var _handle = -1;
    if (_mode_str == "INPUT") {
        _handle = file_text_open_read(_fpath);
    } else if (_mode_str == "OUTPUT") {
        _handle = file_text_open_write(_fpath);
    } else if (_mode_str == "APPEND") {
        _handle = file_text_open_append(_fpath);
    } else {
        basic_syntax_error("OPEN: unknown mode '" + _mode_str + "'", global.current_line_number, 0, "OPEN_MODE");
        return;
    }

    if (_handle < 0) {
        basic_syntax_error("OPEN failed: " + _fname, global.current_line_number, 0, "OPEN_FAILED");
        return;
    }

    global.basic_file_handles[? _chan] = _handle;
    global.basic_file_modes[? _chan]   = _mode_str;
    dbg_log(DBG_FLOW, "OPEN: '" + _fname + "' mode=" + _mode_str + " chan=" + string(_chan) + " handle=" + string(_handle));
}
