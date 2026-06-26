/// File read helpers for INPUT# and LINE INPUT# commands.

/// basic_cmd_input_file(arg)
/// Syntax: INPUT #n, var   (reads one value — whole line — assigns to var)
function basic_cmd_input_file(arg) {
    var _s = string_trim(arg);
    if (string_length(_s) > 0 && string_char_at(_s, 1) == "#") {
        _s = string_copy(_s, 2, string_length(_s) - 1);
    }

    var _comma = string_pos(",", _s);
    if (_comma == 0) {
        basic_syntax_error("INPUT#: missing comma after channel", global.current_line_number, 0, "INPUT_FILE_SYNTAX");
        return;
    }

    var _chan_str = string_trim(string_copy(_s, 1, _comma - 1));
    var _var_name = string_upper(string_trim(string_copy(_s, _comma + 1, string_length(_s))));
    var _chan_arg = basic_eval_int_arg(_chan_str, "INPUT#", "channel");
    if (!_chan_arg.ok) return;
    var _chan = _chan_arg.value;

    if (!ds_map_exists(global.basic_file_handles, _chan)) {
        basic_syntax_error("INPUT#: channel " + string(_chan) + " not open", global.current_line_number, 0, "INPUT_FILE_CHAN");
        return;
    }

    var _handle = global.basic_file_handles[? _chan];
    var _line   = _file_read_line(_handle);

    // Assign: string vars get string; numeric vars get real
    if (string_length(_var_name) > 0 && string_char_at(_var_name, string_length(_var_name)) == "$") {
        basic_var_set(_var_name, _line);
    } else {
        basic_var_set(_var_name, (basic_looks_numeric(_line)) ? real(_line) : 0);
    }
    dbg_log(DBG_FLOW, "INPUT#" + string(_chan) + " → " + _var_name + " = '" + _line + "'");
}

/// basic_cmd_line_input_file(arg)
/// Syntax: LINE INPUT #n, var$   (reads whole line as string, no type conversion)
function basic_cmd_line_input_file(arg) {
    var _s = string_trim(arg);
    if (string_length(_s) > 0 && string_char_at(_s, 1) == "#") {
        _s = string_copy(_s, 2, string_length(_s) - 1);
    }

    var _comma = string_pos(",", _s);
    if (_comma == 0) {
        basic_syntax_error("LINE INPUT#: missing comma after channel", global.current_line_number, 0, "LINE_INPUT_FILE_SYNTAX");
        return;
    }

    var _chan_str = string_trim(string_copy(_s, 1, _comma - 1));
    var _var_name = string_upper(string_trim(string_copy(_s, _comma + 1, string_length(_s))));
    var _chan_arg = basic_eval_int_arg(_chan_str, "LINE INPUT#", "channel");
    if (!_chan_arg.ok) return;
    var _chan = _chan_arg.value;

    if (!ds_map_exists(global.basic_file_handles, _chan)) {
        basic_syntax_error("LINE INPUT#: channel " + string(_chan) + " not open", global.current_line_number, 0, "LINE_INPUT_FILE_CHAN");
        return;
    }

    var _handle = global.basic_file_handles[? _chan];
    var _line   = _file_read_line(_handle);
    basic_var_set(_var_name, _line);
    dbg_log(DBG_FLOW, "LINE INPUT#" + string(_chan) + " → " + _var_name + " = '" + _line + "'");
}

/// Internal helper: read one line from a GML text file handle, stripping trailing CR/LF.
function _file_read_line(handle) {
    var _line = file_text_readln(handle);
    // Strip trailing \r and \n
    while (string_length(_line) > 0) {
        var _last = string_char_at(_line, string_length(_line));
        if (_last == "\n" || _last == "\r") {
            _line = string_copy(_line, 1, string_length(_line) - 1);
        } else break;
    }
    return _line;
}
