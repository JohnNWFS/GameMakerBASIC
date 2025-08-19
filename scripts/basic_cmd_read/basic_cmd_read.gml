/// @func basic_cmd_read(arg)
/// @desc READ [@stream,] var1[, var2 ...]
///       Pulls values from pre-scanned DATA streams into variables (incl. arrays).
function basic_cmd_read(arg) {
    var s = strip_basic_remark(string_trim(arg));
    if (s == "") { show_debug_message("?READ ERROR: missing arguments"); return; }

    // Optional @stream prefix: READ @name, A, B$
    var stream_name = "";
    var dest_text   = s;

    if (string_char_at(s, 1) == "@") {
        var _depth = 0, inq = false, cut = 0, L = string_length(s);
        for (var i = 1; i <= L; i++) {
            var ch = string_char_at(s, i);
            if (ch == "\"") {
                var nxt = (i < L) ? string_char_at(s, i + 1) : "";
                if (inq && nxt == "\"") { i++; continue; }
                inq = !inq; continue;
            }
            if (inq) continue;
            if (ch == "(") { _depth++; continue; }
            if (ch == ")") { _depth = max(0, _depth - 1); continue; }
            if (ch == ",") { cut = i; break; }
        }
        if (cut <= 0) { show_debug_message("?READ ERROR: expected ',' after @name in '" + s + "'"); return; }
        stream_name = string_trim(string_copy(s, 2, cut - 2)); // exclude '@'
        dest_text   = string_trim(string_copy(s, cut + 1, L - cut));
    }

    if (!ds_exists(global.data_streams, ds_type_map) || !ds_map_exists(global.data_streams, stream_name)) {
        show_debug_message("?READ ERROR: stream '" + stream_name + "' not found");
        return;
    }
    var stream = ds_map_find_value(global.data_streams, stream_name);
    var lst    = stream.list;

    var dests = split_on_unquoted_commas(dest_text);
    for (var di = 0; di < array_length(dests); di++) {
        if (stream.ptr >= ds_list_size(lst)) {
            var msg = "?READ ERROR: Out of DATA on stream '" + stream_name + "'";
            if (dbg_on(DBG_FLOW))  show_debug_message(msg);
            // Graceful stop: reuse your END command
            handle_basic_command("END", "");
            return;
        }

        var v = lst[| stream.ptr];
        stream.ptr++;

        var dest = string_trim(dests[di]);
        var rhs;
        if (is_string(v)) {
            var escaped = string_replace_all(v, "\"", "\"\"");
            rhs = "\"" + escaped + "\"";
        } else {
            rhs = string(v);
        }

        if (dbg_on(DBG_FLOW)) show_debug_message("READ: stream='" + stream_name + "' → " + dest + "=" + rhs);
        // Route through the existing LET path so arrays etc. work
        basic_cmd_let(dest + "=" + rhs);
    }
}
