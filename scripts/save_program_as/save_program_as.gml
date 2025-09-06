/// scripts/save_program/save_program.gml
/// Robust save: finds program lines from several common containers and writes them.
/// Logs exactly what was written (count + source), so we can confirm why a file went empty.

function save_program_as(filename)
{
    // --- Normalize filename
    filename = string_trim(filename);
    if (string_length(filename) == 0) { show_error_message("NO FILENAME PROVIDED"); return; }
    if (string_char_at(filename, 1) == "\"" && string_char_at(filename, string_length(filename)) == "\"") {
        filename = string_copy(filename, 2, string_length(filename)-2);
    }
    filename = string_replace_all(filename, "/", "_");
    filename = string_replace_all(filename, "\\", "_");
    filename = string_replace_all(filename, "..", "_");
    filename = string_replace_all(filename, ".bas", "");

    // --- Resolve save directory (desktop-first)
    var save_dir = get_save_directory();
    if (!is_string(save_dir) || string_length(save_dir) == 0) {
        save_dir = working_directory;
        var _last = string_copy(save_dir, string_length(save_dir), 1);
        if (_last != "/" && _last != "\\") save_dir += (os_type == os_windows) ? "\\" : "/";
       if (dbg_on(DBG_FLOW)) show_debug_message("FALLBACK save_dir -> '" + save_dir + "'");
    }
    if (os_type == os_windows || os_type == os_macosx || os_type == os_linux) {
        if (!directory_exists(save_dir)) directory_create(save_dir);
        if (!directory_exists(save_dir)) { show_error_message("COULD NOT CREATE SAVE FOLDER:\n" + string(save_dir)); return; }
    }

    var save_path = save_dir + filename + ".bas";
   if (dbg_on(DBG_FLOW)) show_debug_message("SAVE -> " + save_path);

    // --- Collect lines from likely sources
    var lines_list = ds_list_create(); // will hold strings to write, in order
    var source_used = "NONE";
    var ed = instance_find(obj_editor, 0);

    if (ed != noone) {
        // 1) obj_editor.program_lines (array)
        if (variable_instance_exists(ed, "program_lines") && is_array(ed.program_lines)) {
            for (var i = 0; i < array_length(ed.program_lines); i++) {
                ds_list_add(lines_list, string(ed.program_lines[i]));
            }
            if (ds_list_size(lines_list) > 0) source_used = "obj_editor.program_lines (array)";
        }

        // 2) obj_editor.program_lines (ds_list)
        if (source_used == "NONE" && variable_instance_exists(ed, "program_lines") &&
            ds_exists(ed.program_lines, ds_type_list)) {
            var n = ds_list_size(ed.program_lines);
            for (var j = 0; j < n; j++) {
                ds_list_add(lines_list, string(ds_list_find_value(ed.program_lines, j)));
            }
            if (n > 0) source_used = "obj_editor.program_lines (ds_list)";
        }

/// >>> INSERT START: 2c) obj_editor.program_lines (ds_map) <<<
        if (source_used == "NONE" && variable_instance_exists(ed, "program_lines") &&
            ds_exists(ed.program_lines, ds_type_map)) {

            // Gather keys
            var epl_keys = ds_list_create();
            var epl_k = ds_map_find_first(ed.program_lines);
            while (epl_k != undefined) {
                ds_list_add(epl_keys, epl_k);
                epl_k = ds_map_find_next(ed.program_lines, epl_k);
            }

            // Sort numerically if keys are numbers
            var epl_numeric = true;
            for (var ei = 0; ei < ds_list_size(epl_keys); ei++) {
                if (!is_real(ds_list_find_value(epl_keys, ei))) { epl_numeric = false; break; }
            }
            if (epl_numeric) ds_list_sort(epl_keys, true); // ascending

            // Emit "lineNum content" in key order
            for (var ej = 0; ej < ds_list_size(epl_keys); ej++) {
                var _ln  = ds_list_find_value(epl_keys, ej);
                var _val = ds_map_find_value(ed.program_lines, _ln);
                ds_list_add(lines_list, string(_ln) + " " + string(_val));
            }

            if (ds_list_size(lines_list) > 0) {
                source_used = "obj_editor.program_lines (ds_map)";
                if (dbg_on(DBG_IO)) show_debug_message("SAVE: pulled " + string(ds_list_size(lines_list)) + " lines from obj_editor.program_lines (map)");
            }
            ds_list_destroy(epl_keys);
        }
        /// <<< INSERT END <<<




        // 3) Common ds_map containers keyed by line numbers (we’ll join "lineNum + space + content")
        if (source_used == "NONE") {
            var map_names = [
                "program_map", "program_lines_map", "basic_program",
                "lines_map", "line_store", "program"
            ];
            for (var m = 0; m < array_length(map_names); m++) {
                var nm = map_names[m];
                if (variable_instance_exists(ed, nm) && ds_exists(ed[? nm], ds_type_map)) {
                    // Gather keys
                    var keys = ds_list_create();
                    var k = ds_map_find_first(ed[? nm]);
                    while (k != undefined) {
                        ds_list_add(keys, k);
                        k = ds_map_find_next(ed[? nm], k);
                    }
                    // Sort numerically if keys look like numbers
                    // (GameMaker sorts as strings; so we’ll bubble minimal numeric ordering)
                    var numeric = true;
                    for (var t = 0; t < ds_list_size(keys); t++) {
                        if (!is_real(ds_list_find_value(keys, t))) { numeric = false; break; }
                    }
                    if (numeric) ds_list_sort(keys, true); // ascending

                    // Emit "lineNum content" in key order
                    for (var t2 = 0; t2 < ds_list_size(keys); t2++) {
                        var _ln = ds_list_find_value(keys, t2);
                        var val = ds_map_find_value(ed[? nm], _ln);
                        // if val already includes line number, this will double it; but that’s rare.
                        ds_list_add(lines_list, string(_ln) + " " + string(val));
                    }
                    if (ds_list_size(lines_list) > 0) {
                        source_used = "obj_editor." + nm + " (ds_map)";
                        ds_list_destroy(keys);
                        break;
                    }
                    ds_list_destroy(keys);
                }
            }
        }
    }

    // 4) Global fallbacks
    if (source_used == "NONE" && variable_global_exists("program_lines")) {
        if (is_array(global.program_lines)) {
            for (var g1 = 0; g1 < array_length(global.program_lines); g1++) {
                ds_list_add(lines_list, string(global.program_lines[g1]));
            }
            if (ds_list_size(lines_list) > 0) source_used = "global.program_lines (array)";
        } else if (ds_exists(global.program_lines, ds_type_list)) {
            var gn = ds_list_size(global.program_lines);
            for (var g2 = 0; g2 < gn; g2++) {
                ds_list_add(lines_list, string(ds_list_find_value(global.program_lines, g2)));
            }
            if (gn > 0) source_used = "global.program_lines (ds_list)";
        }
    }
	
	/// >>> INSERT START: support global.program_lines when it's a MAP <<<
    if (source_used == "NONE" && variable_global_exists("program_lines") && ds_exists(global.program_lines, ds_type_map)) {
        var gpl_keys = ds_list_create();
        var gpl_k = ds_map_find_first(global.program_lines);
        while (gpl_k != undefined) {
            ds_list_add(gpl_keys, gpl_k);
            gpl_k = ds_map_find_next(global.program_lines, gpl_k);
        }
        // numeric-sort keys if they’re numbers
        var gpl_numeric = true;
        for (var gpi = 0; gpi < ds_list_size(gpl_keys); gpi++) {
            if (!is_real(ds_list_find_value(gpl_keys, gpi))) { gpl_numeric = false; break; }
        }
        if (gpl_numeric) ds_list_sort(gpl_keys, true);

        for (var gpj = 0; gpj < ds_list_size(gpl_keys); gpj++) {
            var gln  = ds_list_find_value(gpl_keys, gpj); // line number
            var gval = ds_map_find_value(global.program_lines, gln); // code
            ds_list_add(lines_list, string(gln) + " " + string(gval));
        }
        if (ds_list_size(lines_list) > 0) {
            source_used = "global.program_lines (ds_map)";
            if (dbg_on(DBG_IO)) show_debug_message("SAVE: pulled " + string(ds_list_size(lines_list)) + " lines from global.program_lines (map)");
        }
        ds_list_destroy(gpl_keys);
    }
    /// <<< INSERT END <<<
	
    if (source_used == "NONE" && variable_global_exists("program_map") && ds_exists(global.program_map, ds_type_map)) {
        var gkeys = ds_list_create();
        var gk = ds_map_find_first(global.program_map);
        while (gk != undefined) { ds_list_add(gkeys, gk); gk = ds_map_find_next(global.program_map, gk); }
        var gnum = true;
        for (var gg = 0; gg < ds_list_size(gkeys); gg++) if (!is_real(ds_list_find_value(gkeys, gg))) { gnum = false; break; }
        if (gnum) ds_list_sort(gkeys, true);
        for (var gh = 0; gh < ds_list_size(gkeys); gh++) {
            var gln = ds_list_find_value(gkeys, gh);
            var gval = ds_map_find_value(global.program_map, gln);
            ds_list_add(lines_list, string(gln) + " " + string(gval));
        }
        if (ds_list_size(lines_list) > 0) source_used = "global.program_map (ds_map)";
        ds_list_destroy(gkeys);
    }

    // --- Diagnostics before writing
    var total = ds_list_size(lines_list);
   if (dbg_on(DBG_FLOW)) show_debug_message("SAVE SOURCE -> " + source_used + " | lines=" + string(total));
    if (total > 0) {
        // show first couple lines for verification
        var preview_max = min(3, total);
        for (var pv = 0; pv < preview_max; pv++) {
           if (dbg_on(DBG_FLOW)) show_debug_message("LINE[" + string(pv) + "] -> " + string(ds_list_find_value(lines_list, pv)));
        }
    }

    // --- Open file and write
    var fh = file_text_open_write(save_path);
    if (fh < 0) { show_error_message("COULD NOT OPEN FILE FOR WRITE:\n" + filename + ".bas"); ds_list_destroy(lines_list); return; }

    for (var w = 0; w < total; w++) {
        file_text_write_string(fh, string(ds_list_find_value(lines_list, w)));
        file_text_writeln(fh); // newline
    }
    file_text_close(fh);

    var exists_after = file_exists(save_path);
   if (dbg_on(DBG_FLOW)) show_debug_message("SAVE EXISTS AFTER -> " + string(exists_after));

    if (total == 0) {
        show_error_message("NOTHING TO SAVE — no program lines found");
    } else if (!exists_after) {
        show_error_message("SAVE REPORTED OK BUT FILE NOT FOUND:\n" + save_path);
    } else if (ed != noone && variable_instance_exists(ed, "status_message")) {
        ed.status_message = "FILE SAVED: " + filename + ".bas (" + string(total) + " lines)";
    }

    ds_list_destroy(lines_list);
}
