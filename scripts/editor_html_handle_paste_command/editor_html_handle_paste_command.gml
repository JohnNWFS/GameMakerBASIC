/// @function editor_html_handle_paste_command
// === BEGIN: editor_html_handle_paste_command ===
function editor_html_handle_paste_command() {
    // Only meaningful in browser builds; desktop uses editor_handle_paste_command
    if (os_browser == browser_not_a_browser) {
        show_error_message("Use normal Paste on desktop. :PASTE is for browser builds.");
        return;
    }

    // Gate to avoid double-bind/log spam
    if (is_undefined(global.__editor_html_paste_bound)) global.__editor_html_paste_bound = false;
    if (global.__editor_html_paste_bound) {
        // Already waiting for a Ctrl/Cmd+V from the user
        basic_show_message("Paste is already waiting — click the game, then press Ctrl+V (⌘V on Mac).");
        if (dbg_on(DBG_FLOW)) show_debug_message("[PASTE/HTML] already bound");
        return;
    }

    // Accept text only
    var _filter = function(kind, type) {
        // kind: "string" for text; "file" for files
        return (kind == "string");
    };

    // One-shot handler: identical parsing/mutation to Windows path
    var _handler = function(data, name, type) {
        // For text, YellowAfterLife sets name==undefined
        if (!is_undefined(name)) {
            if (dbg_on(DBG_FLOW)) show_debug_message("[PASTE/HTML] ignored non-text paste: name=" + string(name) + " type=" + string(type));
            // unbind and reset
            browser_paste_bind();
            global.__editor_html_paste_bound = false;
            return;
        }

        var raw_clip = string(data);
        if (string_length(raw_clip) <= 0) {
            show_message("Clipboard is empty.");
            browser_paste_bind();
            global.__editor_html_paste_bound = false;
            return;
        }

        var lines = string_split(raw_clip, "\n");
        if (dbg_on(DBG_FLOW)) show_debug_message("PASTE: captured " + string(array_length(lines)) + " raw lines");

        for (var i = 0; i < array_length(lines); i++) {
            var line = string_trim(lines[i]);
            if (string_length(line) == 0) continue;

            // Expect: <number><space><code>
            var space_pos = string_pos(" ", line);
            if (space_pos > 0) {
                var line_num_str = string_copy(line, 1, space_pos - 1);
                var code_str     = string_copy(line, space_pos + 1, string_length(line) - space_pos);

                // Windows CRLF: trim trailing '\r' if present
                if (string_length(code_str) > 0 && string_char_at(code_str, string_length(code_str)) == chr(13)) {
                    code_str = string_copy(code_str, 1, string_length(code_str) - 1);
                }

                if (string_digits(line_num_str) == line_num_str) {
                    var line_num = real(line_num_str);

                    if (line_num > 0 && string_length(code_str) > 0) {
                        // INSERT or REPLACE program text
                        ds_map_set(global.program_lines, line_num, code_str);
                        if (dbg_on(DBG_FLOW)) show_debug_message("PASTE: set " + string(line_num) + " → '" + code_str + "'");

                        // Maintain ordered line number list — add only if not present
                        var idx = ds_list_find_index(global.line_numbers, line_num);
                        if (idx == -1) {
                            ds_list_add(global.line_numbers, line_num);
                            ds_list_sort(global.line_numbers, true);
                            if (dbg_on(DBG_FLOW)) show_debug_message("PASTE: added line number " + string(line_num));
                        } else if (dbg_on(DBG_FLOW)) {
                            show_debug_message("PASTE: updated existing line number " + string(line_num) + " (idx=" + string(idx) + ")");
                        }
                    }
                }
            }
        }

        basic_show_message("Program pasted successfully.");

        // One-shot: unbind after handling a paste so normal keys resume
        browser_paste_bind();
        global.__editor_html_paste_bound = false;
    };

    // Bind paste; some wrappers don’t return a bool to GML, so don’t trust the return value
    browser_paste_bind(_handler, _filter);
    global.__editor_html_paste_bound = true;

    // Match your existing UX/logging
    if (dbg_on(DBG_FLOW)) show_debug_message("[PASTE] Bound. Click the game, then press Ctrl/Cmd+V.");
    basic_show_message("Paste ready — click the game, then press Ctrl+V (⌘V on Mac).");
}
// === END: editor_html_handle_paste_command ===
