// === BEGIN: basic_cmd_print ===
function basic_cmd_print(arg, line_number) {

    if (!ds_exists(global.output_lines, ds_type_list))  global.output_lines  = ds_list_create();
    if (!ds_exists(global.output_colors, ds_type_list)) global.output_colors = ds_list_create();

    var suppress_newline = false;
    var tabw = max(1, is_undefined(global.print_zone) ? 14 : global.print_zone);
    var line_accum = "";
    var col = 0;

    // Trailing semicolon → no newline
    if (string_length(arg) > 0 && string_char_at(arg, string_length(arg)) == ";") {
        suppress_newline = true;
        arg = string_copy(arg, 1, string_length(arg) - 1);
        if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: Trailing semicolon detected; suppressing newline");
    }

    arg = string_trim(arg);

    // 1) Split by unquoted semicolons (these do NOT tab)
    var semi_parts = split_on_unquoted_semicolons(arg);

    // 2) Flatten, preserving WHICH separator preceded each part
    //    sep[i] ∈ { "START", "SEMI", "COMMA" }
    var parts = [];
    var seps  = [];

    var have_any = false;
    for (var si = 0; si < array_length(semi_parts); si++) {
        var seg = string_trim(semi_parts[si]);
        if (seg == "") {
            // if there are consecutive semicolons, they just concatenate nothing
            continue;
        }

        var comma_parts = split_on_unquoted_commas(seg);
        if (array_length(comma_parts) <= 1) {
            parts[array_length(parts)] = seg;
            seps[array_length(seps)]   = (have_any ? "SEMI" : "START");
            have_any = true;
        } else {
            for (var cj = 0; cj < array_length(comma_parts); cj++) {
                var p = string_trim(comma_parts[cj]);
                if (p == "") continue;
                parts[array_length(parts)] = p;
                var sep_kind = "START";
                if (have_any) {
                    // first item of this segment is after a semicolon; others after commas
                    sep_kind = (cj == 0) ? "SEMI" : "COMMA";
                }
                seps[array_length(seps)] = sep_kind;
                have_any = true;
            }
        }
    }

    // Column-aware appender with "\t" expansion (inline, no local functions)
    var _append_string = 0; // dummy to allow block reuse via comments

    // 3) Evaluate/emit each part with separator behavior
    for (var i = 0; i < array_length(parts); i++) {

        // --- Insert padding if previous separator was a COMMA (tab to next zone)
		if (seps[i] == "COMMA") {
		    var pad_comm;
		    if (global.print_tab_mode == 1) {
		        // Fixed-width tab (equal every time)
		        pad_comm = tabw;
		    } else {
		        // Zone tab (classic BASIC)
		        var next_zone = ((col div tabw) + 1) * tabw;
		        pad_comm = max(1, next_zone - col);
		    }
		    line_accum += string_repeat(" ", pad_comm);
		    col += pad_comm;
		}

        // "SEMI" and "START" add nothing (plain concatenation)

        var part = parts[i];
        var treat_as_literal = false;

        if (is_quoted_string(part)) {
            var inner = string_copy(part, 2, string_length(part) - 2);
            if (!string_pos("+", inner) && !string_pos("-", inner) && !string_pos("*", inner) && !string_pos("/", inner)) {
                treat_as_literal = true;
            }
        }

        var text_piece = "";

        if (treat_as_literal) {
            text_piece = string_copy(part, 2, string_length(part) - 2);
            text_piece = string_replace_all(text_piece, "\"\"", "\""); // "" → "
            if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: Part " + string(i) + " literal → " + text_piece);
        } else {
            if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: Part " + string(i) + " expr → " + part);
            var tokens  = basic_tokenize_expression_v2(part);
            if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: Tokens = " + string(tokens));
            var postfix = infix_to_postfix(tokens);
            if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: Postfix = " + string(postfix));
            var result  = evaluate_postfix(postfix);
            if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: Evaluated result = " + string(result));

            // INKEY$ modal sentinel — defer PRINT until resume
            if (is_string(result) && result == "<<INKEY_WAIT>>") {
                if (is_undefined(global.inkey_waiting))  global.inkey_waiting  = false;
                if (is_undefined(global.inkey_captured)) global.inkey_captured = "";
                global.inkey_waiting   = true;
                global.inkey_captured  = "";
                global.pause_in_effect = true;
                global.awaiting_input  = false;
                if (dbg_on(DBG_FLOW)) show_debug_message("INKEY_WAIT: Deferring PRINT until a key is captured.");
                return;
            }

            if (is_real(result)) {
                if (array_length(parts) > 1) {
                    text_piece = string(result); // compact for multi-arg print
                    if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: numeric (compact) → '" + text_piece + "'");
                } else {
                    if (frac(result) == 0) text_piece = string(round(result));
                    else                   text_piece = string_format(result, 12, 8);
                    if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: numeric (padded) → '" + text_piece + "'");
                }
            } else {
                text_piece = string(result);
            }
        }

        // Treat CHR$(9) as a tab (optional, harmless)
        if (text_piece == chr(9)) text_piece = "\t";

        // Append with "\t" expansion and column tracking
        var s = string(text_piece);
        for (var k = 1; k <= string_length(s); k++) {
            var ch = string_char_at(s, k);
			if (ch == "\t") {
			    var pad = (global.print_tab_mode == 1)
			        ? tabw
			        : max(1, (((col div tabw) + 1) * tabw) - col);
			    line_accum += string_repeat(" ", pad);
			    col += pad;
			} else {
                line_accum += ch;
                col += 1;
            }
        }
    }

    // 4) Wrap + commit using your existing buffer
    var wrap_width = 40;
    var full_line  = global.print_line_buffer + line_accum;

    while (string_length(full_line) > wrap_width) {
        var line = string_copy(full_line, 1, wrap_width);
        ds_list_add(global.output_lines, line);
        ds_list_add(global.output_colors, global.current_draw_color);
        full_line = string_copy(full_line, wrap_width + 1, string_length(full_line) - wrap_width);
    }

    global.print_line_buffer = full_line;

    if (!suppress_newline) {
        basic_wrap_and_commit(global.print_line_buffer, global.current_draw_color);
        if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: Line committed → " + global.print_line_buffer);
        global.print_line_buffer = "";
    } else {
        if (dbg_on(DBG_FLOW)) show_debug_message("PRINT: Output buffered without newline → " + global.print_line_buffer);
    }
}
// === END: basic_cmd_print ===
