/// @function handle_basic_command(cmd, arg)
/// @description Routes BASIC commands (and multiple colon-separated statements) to the correct functions
function handle_basic_command(cmd, arg) {
    // Rebuild the full statement (so we catch any colons in the original)
    var full = string_trim(cmd + (string_length(arg) ? " " + arg : ""));

    // Split on unquoted, top-level colons.
    var parts = split_on_unquoted_colons(full);

    // Dispatch each sub-statement in turn
    for (var i = 0; i < array_length(parts); i++) {
        var stmt = string_trim(parts[i]);
        if (stmt == "") continue;

        dbg_log(DBG_FLOW, "DISPATCH PART: " + stmt);

        // Strip any trailing REM (apostrophe handled inside)
        stmt = strip_basic_remark(stmt);

        // Pull off the verb vs. the rest
        var sp = string_pos(" ", stmt);
        var _verb, _rest;
        if (sp > 0) {
            _verb = string_upper(string_copy(stmt, 1, sp - 1));
            _rest = string_trim(string_copy(stmt, sp + 1, string_length(stmt)));
        } else {
            _verb = string_upper(stmt);
            _rest = "";
        }

        // DATA is a runtime no-op (pre-scanned at load time). Skip this colon-segment
        // AND all remaining segments on this line, since DATA @name: v1, v2 contains
        // a colon that the generic splitter treats as a statement separator.
        if (_verb == "DATA") {
            dbg_log(DBG_FLOW, "DATA (runtime): no-op, consuming rest of colon-parts");
            break;
        }

        // Skip INKEY$ as command (handled as function in evaluate_postfix)
        if (_verb == "INKEY$") {
            dbg_log(DBG_FLOW, "INKEY$: Ignored as command, treated as function");
            continue;
        }

        // INKEY$ is valid inside expressions. LET still has a special path for
        // pure "K$ = INKEY$" modal waits.

			// === INLINE IF COLLAPSE (robust; only within THIS colon segment) ===
			// (Do this before the generic "IF requires THEN" guard so inline IF is handled cleanly.)
			if (_verb == "IF") {
			    // Reconstruct the original physical line from the dispatcher’s position
			    var line_idx   = global.interpreter_current_line_index; // set by Step
			    var line_no    = global.line_list[| line_idx];
			    var src_line   = ds_map_find_value(global.program_map, line_no);
			    var parts_full = split_on_unquoted_colons(string_trim(src_line));

			    // Use ONLY the current colon segment
			    var p       = global.interpreter_current_stmt_index;  // set by Step
			    var segment = string_trim(parts_full[p]);
			    var seg_len = string_length(segment);
			    if (seg_len >= 2) {
			        // Find 'IF' at the true start (skip leading spaces)
			        var s = 1;
			        while (s <= seg_len && string_char_at(segment, s) == " ") s++;
			        var is_if = false;
			        if (s + 1 <= seg_len) {
			            var head2 = string_upper(string_copy(segment, s, 2));
			            is_if = (head2 == "IF");
			        }

			        if (is_if) {
			            // Position right after 'IF', then skip spaces to condition start
			            var cond_start = s + 2;
			            while (cond_start <= seg_len && string_char_at(segment, cond_start) == " ") cond_start++;
			            var after_if = (cond_start <= seg_len) ? string_copy(segment, cond_start, seg_len - cond_start + 1) : "";
			            var up_after = string_upper(after_if);

			            // Find top-level THEN (quote/paren aware)
			            var L = string_length(after_if);
			            var lvl = 0, inq = false, then_pos = 0;
			            for (var iTH = 1; iTH <= L - 4 + 1; iTH++) {
			                var chTH = string_char_at(after_if, iTH);
			                if (chTH == "\"") inq = !inq;
			                if (!inq) {
			                    if (chTH == "(") lvl++;
			                    else if (chTH == ")") lvl = max(0, lvl - 1);
			                    if (lvl == 0 && string_upper(string_copy(after_if, iTH, 4)) == "THEN") { then_pos = iTH; break; }
			                }
			            }

			            if (then_pos > 0) {

			                // --- LINT: illegal unconditional flow after inline IF on same line ---
			                // Inspect the *next* colon segment (if any). If it's an unconditional
			                // control-transfer, it will run regardless of IF truth and is almost
			                // always an authoring error.
			                if (p + 1 < array_length(parts_full)) {
			                    var next_seg_raw = string_trim(parts_full[p + 1]);
			                    next_seg_raw = strip_basic_remark(next_seg_raw);

			                    var spn  = string_pos(" ", next_seg_raw);
			                    var vraw = (spn > 0) ? string_copy(next_seg_raw, 1, spn - 1) : next_seg_raw;
			                    var vup  = string_upper(vraw);

			                    // Add more unconditional transfers if desired
			                    if (vup == "GOTO" || vup == "RETURN" || vup == "END") {
			                        basic_syntax_error(
			                            "Illegal inline flow: unconditional " + vup +
			                            " appears after an inline IF on the same line. " +
			                            "Move the " + vup + " into THEN/ELSE or onto the next line.",
			                            global.current_line_number,
			                            p + 1, // offending colon-segment index
			                            "INLINE_FLOW_HAZARD"
			                        );
			                        return;
			                    }
			                }
			                // --- END LINT ---

			                // Split condition and tail (still within this segment only)
			                var cond_src = string_trim(string_copy(after_if, 1, then_pos - 1));
			                var tail     = string_trim(string_copy(after_if, then_pos + 4, L - (then_pos + 4) + 1));

			                // Empty tail means this is a structured block IF:
			                //   IF condition THEN
			                //     ...
			                //   ENDIF
			                // Let the normal IF command handler process it.
			                if (tail == "") {
			                    // Fall through to the structured IF dispatch below.
			                } else {
			                // Look for a top-level ELSE inside tail
			                var L2 = string_length(tail), lvl2 = 0, inq2 = false, else_pos = 0;
			                for (var iEL = 1; iEL <= L2 - 4 + 1; iEL++) {
			                    var chEL = string_char_at(tail, iEL);
			                    if (chEL == "\"") inq2 = !inq2;
			                    if (!inq2) {
			                        if (chEL == "(") lvl2++;
			                        else if (chEL == ")") lvl2 = max(0, lvl2 - 1);
			                        if (lvl2 == 0 && string_upper(string_copy(tail, iEL, 4)) == "ELSE") { else_pos = iEL; break; }
			                    }
			                }

			                var then_src = (else_pos > 0) ? string_trim(string_copy(tail, 1, else_pos - 1)) : tail;
			                var else_src = (else_pos > 0) ? string_trim(string_copy(tail, else_pos + 4, L2 - (else_pos + 4) + 1)) : "";

			                dbg_log(DBG_FLOW, "COMMAND DISPATCH (collapsed IF): IF | ARG: " + (cond_src + " THEN " + then_src + (else_src!="" ? " ELSE " + else_src : "")));

			                // Evaluate condition
			                var tok  = basic_tokenize_expression_v2(cond_src);
			                var post = infix_to_postfix(tok);
			                var val  = evaluate_postfix(post);
			                var truth = 0;
			                if (is_real(val))        truth = (val != 0);
			                else if (is_string(val)) truth = (string_length(val) > 0);

			                // Execute chosen arm via normal dispatcher (arm may contain colons)
			                if (truth) {
			                    if (then_src != "") handle_basic_command(then_src, "");
			                } else {
			                    if (else_src != "") handle_basic_command(else_src, "");
			                }

			                dbg_log(DBG_FLOW, "INLINE IF (" + string(truth) + "): THEN='" + then_src + "' ELSE='" + else_src + "'");

			                // If INPUT/PAUSE occurred inside the THEN/ELSE arm,
			                // schedule resume at NEXT colon segment and yield now.
			                if (global.pause_in_effect || global.awaiting_input) {
			                    dbg_log(DBG_FLOW, "INLINE IF: pausing after arm — scheduling resume at next segment");
			                    global.interpreter_use_stmt_jump = true;
			                    global.interpreter_target_line   = line_idx;
			                    global.interpreter_target_stmt   = p + 1;  // resume at next colon slot (or EOL)
			                    return; // yield now
			                }

			                // Normal path (no INPUT): advance to NEXT colon segment on this line
			                global.interpreter_use_stmt_jump = true;
			                global.interpreter_target_line   = line_idx;
			                global.interpreter_target_stmt   = p + 1;
			                break; // done with this segment
			                }
			            }
			            // If we didn’t find THEN, fall through to structured IF guard/handler below.
			        }
			    }
			}


        // Guard: IF must contain THEN in the same statement (only for non-inline handling)
        if (_verb == "IF" && string_pos("THEN", string_upper(_rest)) <= 0) {
            basic_syntax_error(
                "IF requires THEN",
                /* line_no */ undefined,
                /* stmt_idx */ global.interpreter_current_stmt_index,
                "IF REQUIRES THEN"
            );
            return;
        }

        dbg_log(DBG_FLOW, "COMMAND DISPATCH: " + _verb + " | ARG: " + _rest);

        switch (_verb) {

            case "PRINT":
                if (string_length(_rest) > 0 && string_char_at(_rest, 1) == "#") {
                    basic_cmd_print_file(_rest);
                } else if (global.current_mode == 2) {
                    basic_cmd_print_mode1(_rest);
                } else {
                    basic_cmd_print(_rest, global.current_line_number);
                }
                break;

            case "LET":       basic_cmd_let(_rest); break;
            case "GOTO":      basic_cmd_goto(_rest); break;

            case "OPTION": {
                // OPTION BASE 0 or OPTION BASE 1
                var _opt = string_upper(string_trim(_rest));
                if (string_copy(_opt, 1, 5) == "BASE ") {
                    var _b_arg = basic_eval_int_arg(string_copy(_opt, 6, string_length(_opt) - 5), "OPTION BASE", "base");
                    if (!_b_arg.ok) return;
                    var _b = _b_arg.value;
                    if (_b == 0 || _b == 1) {
                        global.option_base = _b;
                    } else {
                        basic_syntax_error("OPTION BASE must be 0 or 1", global.current_line_number, 0, "OPTION_BASE");
                    }
                }
                break;
            }

            case "ON": {
                // ON expr GOTO line1,line2,... or ON expr GOSUB line1,line2,...
                var _on_upper = string_upper(_rest);
                var _goto_pos  = string_pos(" GOTO ",  _on_upper);
                var _gosub_pos = string_pos(" GOSUB ", _on_upper);
                var _is_gosub  = (_gosub_pos > 0 && (_goto_pos == 0 || _gosub_pos < _goto_pos));
                var _kw_pos    = _is_gosub ? _gosub_pos : _goto_pos;
                var _kw_len    = _is_gosub ? 7 : 6;  // " GOSUB " = 7, " GOTO " = 6
                if (_kw_pos > 0) {
                    var _expr_src = string_trim(string_copy(_rest, 1, _kw_pos - 1));
                    var _lines_src = string_trim(string_copy(_rest, _kw_pos + _kw_len, string_length(_rest)));
                    var _n_arg = basic_eval_int_arg(_expr_src, "ON", "selector");
                    if (!_n_arg.ok) return;
                    var _n = _n_arg.value;
                    // split comma-separated line numbers
                    var _targets = string_split(_lines_src, ",");
                    if (_n >= 1 && _n <= array_length(_targets)) {
                        var _target_arg = basic_eval_number_arg(_targets[_n - 1], "ON", "target line");
                        if (!_target_arg.ok) return;
                        var _target_line = _target_arg.value;
                        if (_is_gosub) {
                            basic_cmd_gosub(string(_target_line));
                        } else {
                            basic_cmd_goto(string(_target_line));
                        }
                    }
                    // if n out of range, fall through (no jump) — standard BASIC behaviour
                } else {
                    basic_syntax_error("ON requires GOTO or GOSUB", global.current_line_number, 0, "ON_SYNTAX");
                }
                break;
            }
            case "INPUT":
                if (string_length(_rest) > 0 && string_char_at(_rest, 1) == "#") {
                    basic_cmd_input_file(_rest);
                } else {
                    basic_cmd_input(_rest);
                }
                break;

            case "LINE": {
                var _line_up = string_upper(string_trim(_rest));
                if (string_length(_line_up) >= 5 && string_copy(_line_up, 1, 5) == "INPUT") {
                    var _li_rest = string_trim(string_copy(_rest, 7, string_length(_rest)));
                    basic_cmd_line_input_file(_li_rest);
                } else {
                    basic_cmd_line(_rest);
                }
                break;
            }

            case "OPEN":  basic_cmd_open(_rest); break;
            case "CLOSE": basic_cmd_close(_rest); break;
            case "COLOR":     basic_cmd_color(_rest); break;

            case "CLS":
                if (global.current_mode == 2) { basic_cmd_cls_mode1(); }
                else                          { basic_cmd_cls(); }
                break;

            // Structured control flow (multi-line)
            case "IF":        basic_cmd_if(_rest); break;
            case "ELSEIF":    basic_cmd_elseif(_rest); break;
            case "ELSE":      basic_cmd_else(); break;
            case "ENDIF":     basic_cmd_endif(); break;

            case "FOR":       basic_cmd_for(_rest); break;
            case "NEXT":      basic_cmd_next(_rest); break;
            case "WHILE":     basic_cmd_while(_rest); break;
            case "WEND":      basic_cmd_wend(); break;

            case "GOSUB":     basic_cmd_gosub(_rest); break;
            case "RETURN":    basic_cmd_return(); break;

            case "BGCOLOR":   basic_cmd_bgcolor(_rest); break;
            case "PAUSE":     basic_cmd_pause(); break;
            case "MODE":      basic_cmd_mode(_rest); break;
            case "CLSCHAR":   basic_cmd_clschar(_rest); break;
            case "PSET":      basic_cmd_pset(_rest); break;
            case "CIRCLE":    basic_cmd_circle(_rest); break;
            case "PLOT":
                if (global.current_mode == 3) basic_cmd_pset(_rest);
                else basic_cmd_charat(_rest);
                break;
            case "TILE":      basic_cmd_charat(_rest); break;
            case "DRAWSTR":   basic_cmd_printat(_rest); break;
            case "BOX":       basic_cmd_box(_rest); break;
            case "FILL":      basic_cmd_tile_fill(_rest); break;
            case "HLINE":     basic_cmd_tile_hline(_rest); break;
            case "VLINE":     basic_cmd_tile_vline(_rest); break;
            case "TILEDEF":   basic_cmd_tiledef(_rest); break;
            case "TILEPX":    basic_cmd_tilepx(_rest); break;
            case "TILECLEAR": basic_cmd_tileclear(_rest); break;
            case "TILERESTORE": basic_cmd_tilerestore(_rest); break;
            case "TILESAVE":  basic_cmd_tilesave(_rest); break;
            case "TILELOAD":  basic_cmd_tileload(_rest); break;
            case "CHARAT":    basic_cmd_charat(_rest); break;
            case "PRINTAT":   basic_cmd_printat(_rest); break;
            case "FONT":      basic_cmd_font(_rest); break;
            case "DIM":       basic_cmd_dim(_rest); break; // 1-D arrays

            case "END":       basic_cmd_end(); break;
            case "STOP":      basic_cmd_end(); break;  // STOP = END for now

            case "ERASE": {
                var _nm = string_upper(string_trim(_rest));
                if (ds_exists(global.basic_arrays, ds_type_map) && ds_map_exists(global.basic_arrays, _nm)) {
                    basic_array_release_storage(global.basic_arrays[? _nm]);
                    ds_map_delete(global.basic_arrays, _nm);
                }
                if (variable_global_exists("basic_array_dims")
                 && ds_exists(global.basic_array_dims, ds_type_map)
                 && ds_map_exists(global.basic_array_dims, _nm)) {
                    ds_map_delete(global.basic_array_dims, _nm);
                }
                break;
            }

            case "RANDOMIZE": {
                var _seed = string_trim(_rest);
                if (_seed == "") {
                    randomize();
                } else {
                    var _seed_arg = basic_eval_int_arg(_seed, "RANDOMIZE", "seed");
                    if (!_seed_arg.ok) return;
                    random_set_seed(_seed_arg.value);
                }
                break;
            }

            case "REM":
                // no-op
                break;

            case "DATA":
                // Runtime no-op (DATA was harvested at load time)
                dbg_log(DBG_FLOW, "DATA (runtime): no-op");
                break;

            case "READ":      basic_cmd_read(_rest); break;
            case "RESTORE":   basic_cmd_restore(_rest); break;

            case "LOCATE":    basic_cmd_locate(_rest); break;
            case "SCROLL":    basic_cmd_scroll(_rest); break;

            case "POS":
                // If it's being used as a variable assignment (e.g., "POS = 1"),
                // treat it as an implicit LET. Otherwise it's a function token in expressions,
                // so do nothing at command level.
                if (string_pos("=", _rest) > 0) {
                    basic_cmd_let(_verb + " " + _rest);
                }
                break;

            case "SCREEN":    // handled as function in expressions
            case "POINT":     // handled as function in expressions
            //case "POS":     // handled as function in expressions
            case "CSRLIN":    // handled as function in expressions
            case "TAB":       // handled in PRINT processing
            case "SPC":       // handled in PRINT processing
                break;

            case "FONTSET":   basic_cmd_fontset(_rest); break;

            case "TEMPO":    basic_cmd_tempo(_rest); break;
            case "BEEP":     basic_cmd_beep(_rest); break;
            case "PLAY":     basic_cmd_play(_rest); break;

            case "SPRITE":   bas_sprite_command(_rest); break;

            default:
                // implicit LET?  e.g.  "X = 5"
                if (string_pos("=", _verb + " " + _rest) > 0) {
                    basic_cmd_let(_verb + " " + _rest);
                } else {
                    basic_syntax_error("Unknown command: " + _verb,
                        global.current_line_number,
                        global.interpreter_current_stmt_index,
                        "UNKNOWN_COMMAND");
                }
                break;
        }

        // === YIELD GATE: if any command armed INPUT/PAUSE, stop consuming this line’s remaining segments
        if (global.pause_in_effect || global.awaiting_input) {
            dbg_log(DBG_FLOW, "DISPATCH: pause/input armed → yielding after segment");
            return;
        }
    }
}
