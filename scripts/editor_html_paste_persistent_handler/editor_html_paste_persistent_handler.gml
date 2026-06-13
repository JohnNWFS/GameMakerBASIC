/// @function editor_html_paste_persistent_handler(_data, _name, _type)
/// Persistent Ctrl+V handler for the browser build.
/// Auto-detects BASIC programs (numbered lines) vs. plain text (URLs, commands).
function editor_html_paste_persistent_handler(_data, _name, _type) {
    // File items have a real name; text items have name == undefined
    if (!is_undefined(_name)) return;
    // Guard against undefined/non-string data (empty clipboard)
    if (is_undefined(_data)) return;
    if (!is_string(_data)) return;
    // Skip file data URLs (image/file pastes)
    if (string_copy(_data, 1, 5) == "data:") return;

    var raw = _data;
    if (string_length(raw) == 0) return;

    // Normalize line endings
    raw = string_replace_all(string_replace_all(raw, "\r\n", "\n"), "\r", "\n");

    // Find first non-empty line to decide what kind of paste this is
    var lines = string_split(raw, "\n");
    var _first = "";
    var _fi = 0;
    for (_fi = 0; _fi < array_length(lines); _fi++) {
        _first = string_trim(lines[_fi]);
        if (string_length(_first) > 0) break;
    }

    // A BASIC program starts with a line number followed by a space
    var _sp = string_pos(" ", _first);
    var _looks_like_program = (_sp > 0) && is_line_number(string_copy(_first, 1, _sp - 1));

    if (_looks_like_program) {
        // Multi-line BASIC program — import all numbered lines
        var count = editor_import_text_to_program(raw);
        basic_show_message("Pasted " + string(count) + " line(s) into program.");
        dbg_log(DBG_FLOW, "[CTRLV] pasted BASIC program, " + string(count) + " lines");
    } else {
        // Plain text (URL, command, etc.) — insert first non-empty line at cursor
        var _text = _first;  // already trimmed first non-empty line from above
        if (string_length(_text) == 0) return;

        with (obj_editor) {
            var _before = string_copy(current_input, 1, cursor_pos);
            var _after  = string_copy(current_input, cursor_pos + 1, string_length(current_input) - cursor_pos);
            current_input = _before + _text + _after;
            cursor_pos += string_length(_text);
        }
        dbg_log(DBG_FLOW, "[CTRLV] inserted into command line: " + _text);
    }
}
