/// basic_cmd_print_file(arg)
/// Syntax: PRINT #n, expr [; expr ...]
/// Leading "#" on arg is already present from the dispatcher (_rest).
function basic_cmd_print_file(arg) {
    var _s = string_trim(arg);

    // Strip leading #
    if (string_length(_s) > 0 && string_char_at(_s, 1) == "#") {
        _s = string_copy(_s, 2, string_length(_s) - 1);
    }

    // Find first comma separating channel from content
    var _comma = string_pos(",", _s);
    if (_comma == 0) {
        basic_syntax_error("PRINT#: missing comma after channel number", global.current_line_number, 0, "PRINT_FILE_SYNTAX");
        return;
    }

    var _chan_str  = string_trim(string_copy(_s, 1, _comma - 1));
    var _content   = string_trim(string_copy(_s, _comma + 1, string_length(_s)));
    var _chan      = floor(real(basic_evaluate_expression_v2(_chan_str)));

    if (!ds_map_exists(global.basic_file_handles, _chan)) {
        basic_syntax_error("PRINT#: channel " + string(_chan) + " not open", global.current_line_number, 0, "PRINT_FILE_CHAN");
        return;
    }
    var _handle = global.basic_file_handles[? _chan];

    // Split on top-level semicolons (no newline between) and build output string
    var _out       = "";
    var _newline   = true;  // whether to write newline at end
    var _parts     = _split_print_args(_content);

    for (var _pi = 0; _pi < array_length(_parts); _pi++) {
        var _piece = string_trim(_parts[_pi]);
        if (_piece == ";") { _newline = false; continue; }
        if (_piece == ",") { _out += "  "; _newline = true; continue; }
        _newline = true;
        var _val = basic_evaluate_expression_v2(_piece);
        _out += string(_val);
    }

    file_text_write_string(_handle, _out);
    if (_newline) file_text_writeln(_handle);
    dbg_log(DBG_FLOW, "PRINT#" + string(_chan) + ": wrote '" + _out + "'");
}

/// Split a PRINT argument string on top-level ; and , separators.
/// Returns an array of alternating [expr, sep, expr, sep, ...].
function _split_print_args(s) {
    var _result = [];
    var _len    = string_length(s);
    var _start  = 1;
    var _inq    = false;
    var _depth  = 0;

    for (var _i = 1; _i <= _len; _i++) {
        var _c = string_char_at(s, _i);
        if (_c == "\"") { _inq = !_inq; continue; }
        if (_inq) continue;
        if (_c == "(") { _depth++; continue; }
        if (_c == ")") { _depth = max(0, _depth - 1); continue; }
        if (_depth == 0 && (_c == ";" || _c == ",")) {
            var _tok = string_trim(string_copy(s, _start, _i - _start));
            if (_tok != "") array_push(_result, _tok);
            array_push(_result, _c);
            _start = _i + 1;
        }
    }
    var _last = string_trim(string_copy(s, _start, _len - _start + 1));
    if (_last != "") array_push(_result, _last);
    return _result;
}
