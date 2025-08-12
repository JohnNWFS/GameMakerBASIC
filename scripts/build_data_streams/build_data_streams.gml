/// @func build_data_streams()
/// @desc Pre-scan the loaded program for DATA statements and harvest values
///       into named streams: global.data_streams[stream_name] = { list, ptr }.
///       Default stream name is "" (empty). Named stream: DATA @name: v1, v2, ...
function build_data_streams() {
    // Ensure the container map exists; clear any prior contents safely
    // We rely on obj_globals to have created global.data_streams (a ds_map).
    // Here we only clear/recycle it between runs by destroying per-stream lists.
    if (!ds_exists(global.data_streams, ds_type_map)) {
        // Safety net (shouldn't happen if obj_globals set it up)
        global.data_streams = ds_map_create();
        if (dbg_on(DBG_FLOW)) show_debug_message("DATA: safety-created global.data_streams (missing map)");
    }

    // Destroy any old lists then clear the map for a fresh build
    var _k = ds_map_find_first(global.data_streams);
    while (!is_undefined(_k)) {
        var _st = ds_map_find_value(global.data_streams, _k);
        if (is_struct(_st)) {
            if (ds_exists(_st.list, ds_type_list)) ds_list_destroy(_st.list);
        }
        _k = ds_map_find_next(global.data_streams, _k);
    }
    ds_map_clear(global.data_streams);

    var total_vals = 0, added_lines = 0;

    // Iterate by physical line order using your runtime copies
    // (run_program() already did ds_map_copy → basic_program and ds_list_copy → basic_line_numbers)
    for (var i = 0; i < ds_list_size(global.basic_line_numbers); i++) {
        var line_no = global.basic_line_numbers[| i];
        var raw     = ds_map_find_value(global.basic_program, line_no);
        if (is_undefined(raw)) continue;

        var parts = split_on_unquoted_colons(string_trim(raw));

        for (var p = 0; p < array_length(parts); p++) {
            // *** CHANGE: look at the raw colon slot first (before stripping remarks)
            var stmt_full = string_trim(parts[p]);
            if (stmt_full == "") continue;

            var sp0   = string_pos(" ", stmt_full);
            var verb0 = (sp0 > 0) ? string_upper(string_copy(stmt_full, 1, sp0 - 1)) : string_upper(stmt_full);

            // *** CHANGE: if this part is REM or starts with apostrophe, stop scanning the rest of THIS line
            if (verb0 == "REM" || string_char_at(stmt_full, 1) == "'") {
                if (dbg_on(DBG_FLOW)) show_debug_message("DATA scan: REM/' stops line " + string(line_no) + " at part " + string(p));
                break; // stop processing parts[] for this physical line
            }

            // Now strip inline remarks (so code like: DATA 1,2 'comment keeps "DATA 1,2")
            var part_raw = strip_basic_remark(stmt_full);
            if (part_raw == "") continue;

            var sp   = string_pos(" ", part_raw);
            var verb = (sp > 0) ? string_upper(string_copy(part_raw, 1, sp - 1)) : string_upper(part_raw);
            var rest = (sp > 0) ? string_trim(string_copy(part_raw, sp + 1, string_length(part_raw))) : "";

            if (verb != "DATA") continue;

            // --- collapse the remainder of THIS physical line so ':' after @name doesn't split the DATA ---
            // *** CHANGE: also stop collapse if we hit a REM/' part later on the same line.
            var remainder = part_raw;
            for (var t = p + 1; t < array_length(parts); t++) {
                var tail_full = string_trim(parts[t]);
                if (tail_full == "") continue;

                var spT   = string_pos(" ", tail_full);
                var verbT = (spT > 0) ? string_upper(string_copy(tail_full, 1, spT - 1)) : string_upper(tail_full);

                // *** CHANGE: if a later colon slot is a whole-line comment, stop collapse here
                if (verbT == "REM" || string_char_at(tail_full, 1) == "'") {
                    if (dbg_on(DBG_FLOW)) show_debug_message("DATA collapse: hit REM/' at part " + string(t) + " on line " + string(line_no));
                    break;
                }

                var tail = strip_basic_remark(tail_full);
                if (tail != "") remainder += ":" + tail;
            }
            if (dbg_on(DBG_FLOW) && remainder != part_raw) show_debug_message("DATA: collapsed line parts → '" + remainder + "'");

            // Recompute 'rest' from the collapsed DATA statement
            var sp2  = string_pos(" ", remainder);
            rest     = (sp2 > 0) ? string_trim(string_copy(remainder, sp2 + 1, string_length(remainder))) : "";
            added_lines++;

            var stream_name = "";     // default stream
            var values_text = rest;   // may be rewritten if @name: is present

            // Optional named stream: DATA @name: v1, v2, ...
            if (string_length(rest) > 0 && string_char_at(rest, 1) == "@") {
                var _depth = 0, inq = false, cut = 0, L = string_length(rest);
                for (var j = 1; j <= L; j++) {
                    var ch = string_char_at(rest, j);
                    if (ch == "\"") {
                        var nxt = (j < L) ? string_char_at(rest, j + 1) : "";
                        if (inq && nxt == "\"") { j++; continue; }
                        inq = !inq; continue;
                    }
                    if (inq) continue;
                    if (ch == "(") { _depth++; continue; }
                    if (ch == ")") { _depth = max(0, _depth - 1); continue; }
                    if (ch == ":" && _depth == 0) { cut = j; break; }
                }
                if (cut == 0) {
                    show_debug_message("?DATA ERROR: expected ':' after @name — line " + string(line_no) + " text: '" + part_raw + "'");
                    continue;
                }
                stream_name = string_trim(string_copy(rest, 2, cut - 2)); // exclude '@'
                values_text = string_trim(string_copy(rest, cut + 1, L - cut));
            }

            var vals = split_on_unquoted_commas(values_text);

            if (!ds_map_exists(global.data_streams, stream_name)) {
                var stream = { list: ds_list_create(), ptr: 0 };
                ds_map_add(global.data_streams, stream_name, stream);
            }
            var sref = ds_map_find_value(global.data_streams, stream_name);

            for (var vi = 0; vi < array_length(vals); vi++) {
                var token = vals[vi];
                var v = parse_data_value(token);
                ds_list_add(sref.list, v);
                total_vals++;
                if (dbg_on(DBG_FLOW)) show_debug_message(
                    "DATA: +" + (is_string(v) ? ("\"" + string(v) + "\"") : string(v)) +
                    " -> stream='" + stream_name + "' (line " + string(line_no) + ")"
                );
            }

            // we consumed the collapsed remainder of this physical line for this DATA
            break;
        }
    }

    if (dbg_on(DBG_FLOW)) {
        var summary = "DATA SUMMARY — streams: ";
        var k2 = ds_map_find_first(global.data_streams);
        while (!is_undefined(k2)) {
            var st2 = ds_map_find_value(global.data_streams, k2);
            var cnt = ds_list_size(st2.list);
            summary += "'" + string(k2) + "'=" + string(cnt) + "  ";
            k2 = ds_map_find_next(global.data_streams, k2);
        }
        show_debug_message(summary + "| values=" + string(total_vals) + " | data_lines=" + string(added_lines));
    }

    // TEMP: verify default stream size
    if (ds_map_exists(global.data_streams, "")) {
        var _def = ds_map_find_value(global.data_streams, "");
        show_debug_message("DATA DEFAULT SIZE = " + string(ds_list_size(_def.list)));
    }
}
