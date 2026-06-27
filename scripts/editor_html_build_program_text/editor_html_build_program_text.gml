/// @function editor_html_build_program_text
/// @desc Serialize the current BASIC program into canonical lines: "<line> <code>\r\n"
///       Uses the same sources your desktop save_program_as() already prefers.
/// @returns {string}
function editor_html_build_program_text() {
    var lines_list = ds_list_create(); // ordered strings to emit
    var source_used = "NONE";
    var ed = instance_find(obj_editor, 0);

    // === Try obj_editor.program_lines (array) ===
    if (ed != noone && variable_instance_exists(ed, "program_lines") && is_array(ed.program_lines)) {
        for (var i = 0; i < array_length(ed.program_lines); i++) {
            ds_list_add(lines_list, string(ed.program_lines[i]));
        }
        if (ds_list_size(lines_list) > 0) source_used = "obj_editor.program_lines (array)";
    }

    // === Try obj_editor.program_lines (ds_list) ===
    if (source_used == "NONE" && ed != noone && variable_instance_exists(ed, "program_lines") &&
        ds_exists(ed.program_lines, ds_type_list)) {
        var n = ds_list_size(ed.program_lines);
        for (var j = 0; j < n; j++) {
            ds_list_add(lines_list, string(ds_list_find_value(ed.program_lines, j)));
        }
        if (n > 0) source_used = "obj_editor.program_lines (ds_list)";
    }

    // === Try obj_editor.program_lines (ds_map keyed by line numbers) ===
    if (source_used == "NONE" && ed != noone && variable_instance_exists(ed, "program_lines") &&
        ds_exists(ed.program_lines, ds_type_map)) {

        var epl_keys = ds_list_create();
        var e_k = ds_map_find_first(ed.program_lines);
        while (e_k != undefined) { ds_list_add(epl_keys, e_k); e_k = ds_map_find_next(ed.program_lines, e_k); }

        var epl_numeric = true;
        for (var ei = 0; ei < ds_list_size(epl_keys); ei++) {
            if (!is_real(ds_list_find_value(epl_keys, ei))) { epl_numeric = false; break; }
        }
        if (epl_numeric) ds_list_sort(epl_keys, true);

        for (var ej = 0; ej < ds_list_size(epl_keys); ej++) {
            var _ln  = ds_list_find_value(epl_keys, ej);
            var _val = ds_map_find_value(ed.program_lines, _ln);
            ds_list_add(lines_list, string(_ln) + " " + string(_val));
        }
        if (ds_list_size(lines_list) > 0) source_used = "obj_editor.program_lines (ds_map)";

        ds_list_destroy(epl_keys);
    }

    // === Try common ds_map containers keyed by line numbers ===
    if (source_used == "NONE") {
        var map_names = [
            "program_map", "program_lines_map", "basic_program",
            "lines_map", "line_store", "program"
        ];
        for (var mi = 0; mi < array_length(map_names); mi++) {
            var mn = map_names[mi];
            if (variable_instance_exists(ed, mn) && ds_exists(ed[? mn], ds_type_map)) {
                var keys = ds_list_create();
                var k = ds_map_find_first(ed[? mn]);
                while (k != undefined) { ds_list_add(keys, k); k = ds_map_find_next(ed[? mn], k); }
                var numeric = true;
                for (var ki = 0; ki < ds_list_size(keys); ki++) {
                    if (!is_real(ds_list_find_value(keys, ki))) { numeric = false; break; }
                }
                if (numeric) ds_list_sort(keys, true);
                for (var kj = 0; kj < ds_list_size(keys); kj++) {
                    var _ln  = ds_list_find_value(keys, kj);
                    var val = ds_map_find_value(ed[? mn], _ln);
                    ds_list_add(lines_list, string(_ln) + " " + string(val));
                }
                ds_list_destroy(keys);
                if (ds_list_size(lines_list) > 0) { source_used = "obj_editor." + mn; break; }
            }
        }
    }

    // === Try global.program_map + line_list (canonical editor storage) ===
    if (source_used == "NONE" && variable_global_exists("program_map") && ds_exists(global.program_map, ds_type_map)
     && variable_global_exists("line_list") && ds_exists(global.line_list, ds_type_list)) {
        for (var gpj = 0; gpj < ds_list_size(global.line_list); gpj++) {
            var gln  = ds_list_find_value(global.line_list, gpj);
            var gval = ds_map_find_value(global.program_map, gln);
            ds_list_add(lines_list, string(gln) + " " + string(gval));
        }
        if (ds_list_size(lines_list) > 0) source_used = "global.program_map+line_list";
    }

    // --- Emit CRLF text
    var out = "";
    var total = ds_list_size(lines_list);
    for (var ii = 0; ii < total; ii++) {
        out += string(ds_list_find_value(lines_list, ii)) + "\r\n";
    }
    ds_list_destroy(lines_list);
    return out; // empty if nothing found
}
