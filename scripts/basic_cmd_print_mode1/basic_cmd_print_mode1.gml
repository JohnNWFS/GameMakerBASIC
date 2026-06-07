/// MODE 1 COMMAND
/// @function basic_cmd_print_mode1(arg)
/// @description MODE 1 version of PRINT that writes to the grid using cursor position
function basic_cmd_print_mode1(arg) {
    // Initialize cursor if not set
    if (!variable_global_exists("mode1_cursor_x")) global.mode1_cursor_x = 0;
    if (!variable_global_exists("mode1_cursor_y")) global.mode1_cursor_y = 0;
    
    var suppress_newline = false;
    
    // Check for trailing semicolon (do not trim first so semicolon at true end detected)
    if (string_length(arg) > 0 && string_char_at(arg, string_length(arg)) == ";") {
        suppress_newline = true;
        arg = string_copy(arg, 1, string_length(arg) - 1);
        dbg_log(DBG_FLOW, "PRINT MODE1: Semicolon detected, suppressing newline");
    }
    
    arg = string_trim(arg);
    if (arg == "") {
        if (!suppress_newline) {
            // Move cursor to next line (use grid height if available)
            var _grid = instance_find(obj_mode1_grid, 0);
            var _rows = (instance_exists(_grid)) ? _grid.grid_rows : 25;
            global.mode1_cursor_x = 0;
            global.mode1_cursor_y = min(_rows - 1, global.mode1_cursor_y + 1);
            dbg_log(DBG_FLOW, "PRINT MODE1: Empty line, cursor now at (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
        }
        return;
    }
    
    var output_text = "";
    var tabw = max(1, is_undefined(global.print_zone) ? 14 : global.print_zone);
    var col = 0;

    var semi_parts = split_on_unquoted_semicolons(arg);
    var parts = [];
    var seps = [];
    var have_any = false;

    for (var si = 0; si < array_length(semi_parts); si++) {
        var seg = string_trim(semi_parts[si]);
        if (seg == "") continue;

        var comma_parts = split_on_unquoted_commas(seg);
        if (array_length(comma_parts) <= 1) {
            parts[array_length(parts)] = seg;
            seps[array_length(seps)] = have_any ? "SEMI" : "START";
            have_any = true;
        } else {
            for (var cj = 0; cj < array_length(comma_parts); cj++) {
                var p = string_trim(comma_parts[cj]);
                if (p == "") continue;
                parts[array_length(parts)] = p;
                var sep_kind = "START";
                if (have_any) sep_kind = (cj == 0) ? "SEMI" : "COMMA";
                seps[array_length(seps)] = sep_kind;
                have_any = true;
            }
        }
    }

    for (var part_index = 0; part_index < array_length(parts); part_index++) {
        if (seps[part_index] == "COMMA") {
            var next_zone = ((col div tabw) + 1) * tabw;
            var pad_comm = max(1, next_zone - col);
            output_text += string_repeat(" ", pad_comm);
            col += pad_comm;
        }

        var part = parts[part_index];
        var text_piece = "";

        if (is_quoted_string(part)) {
            text_piece = string_copy(part, 2, string_length(part) - 2);
            text_piece = string_replace_all(text_piece, "\"\"", "\"");
        } else {
            var tokens = basic_tokenize_expression_v2(part);
            var postfix = infix_to_postfix(tokens);
            var result = evaluate_postfix(postfix);

            if (is_real(result)) {
                text_piece = string(result);
            } else {
                text_piece = string(result);
            }
        }

        if (text_piece == chr(9)) text_piece = "\t";

        for (var tk = 1; tk <= string_length(text_piece); tk++) {
            var tch = string_char_at(text_piece, tk);
            if (tch == "\t") {
                var pad = max(1, (((col div tabw) + 1) * tabw) - col);
                output_text += string_repeat(" ", pad);
                col += pad;
            } else {
                output_text += tch;
                col += 1;
            }
        }
    }

    dbg_log(DBG_FLOW, "PRINT MODE1: assembled output '" + output_text + "'");
    
    dbg_log(DBG_FLOW, "PRINT MODE1: Starting at cursor (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
    basic_output_transcript_append(output_text);
    
    // Ensure grid exists and get cols/rows
    var grid_inst = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_inst)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: grid not found; creating");
        instance_create_layer(0, 0, "Instances", obj_mode1_grid);
        grid_inst = instance_find(obj_mode1_grid, 0);
        if (!instance_exists(grid_inst)) {
            if (dbg_on(DBG_FLOW)) show_debug_message("PRINT MODE1: grid creation failed; falling back to defaults");
        }
    }
    var cols = (instance_exists(grid_inst)) ? grid_inst.grid_cols : 40;
    var rows = (instance_exists(grid_inst)) ? grid_inst.grid_rows : 25;
    
    // Print each character at cursor position using mode1_grid_set
    for (var i = 0; i < string_length(output_text); i++) {
        var ch = ord(string_char_at(output_text, i + 1));
        
        dbg_log(DBG_FLOW, "PRINT MODE1: Setting char '" + string_char_at(output_text, i + 1) + "' (code " + string(ch) + ") at (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
        
        // Preserve existing cell colors unless explicitly changed elsewhere: pass undefined for fg/bg
        mode1_grid_set(global.mode1_cursor_x, global.mode1_cursor_y, ch, undefined, undefined);
        
        // Advance cursor
        global.mode1_cursor_x++;
        if (global.mode1_cursor_x >= cols) {
            global.mode1_cursor_x = 0;
            global.mode1_cursor_y = min(rows - 1, global.mode1_cursor_y + 1);
            dbg_log(DBG_FLOW, "PRINT MODE1: Wrapped to next line, cursor now at (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
        }
    }
    
    // If not suppressed, clear the remainder of the row (removes leftover glyphs), then newline
    if (!suppress_newline) {
        var cur_x = global.mode1_cursor_x;
        var cur_y = global.mode1_cursor_y;
        // Clear from current column to end-of-row (char -> 32), keep colors unchanged
        for (var cx = cur_x; cx < cols; cx++) {
            mode1_grid_set(cx, cur_y, 32, undefined, undefined);
        }
        // Move cursor to next line
        global.mode1_cursor_x = 0;
        global.mode1_cursor_y = min(rows - 1, cur_y + 1);
        dbg_log(DBG_FLOW, "PRINT MODE1: Newline, cursor now at (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
    }
    
    dbg_log(DBG_FLOW, "PRINT MODE1: Finished printing '" + output_text + "', cursor at (" + string(global.mode1_cursor_x) + "," + string(global.mode1_cursor_y) + ")");
}
