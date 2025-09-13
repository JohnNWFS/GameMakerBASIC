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

        if (dbg_on(DBG_FLOW)) show_debug_message("DISPATCH PART: " + stmt);

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

        // Skip INKEY$ as command (handled as function in evaluate_postfix)
        if (_verb == "INKEY$") {
            if (dbg_on(DBG_FLOW)) show_debug_message("INKEY$: Ignored as command, treated as function");
            continue;
        }

        // ---------- SYNTAX GUARD: INKEY$ misuse (quote-aware) ----------
        {
            var _src  = stmt;   // stmt already had remarks stripped
            var _len  = string_length(_src);
            var _up   = string_upper(_src);

            var inq = false;
            var i2  = 1;
            var found_inkey = false;
            var eq_pos = 0;

            while (i2 <= _len) {
                var ch = string_char_at(_src, i2);
                if (ch == "\"") {
                    if (i2 < _len && string_char_at(_src, i2 + 1) == "\"") { i2 += 2; continue; }
                    inq = !inq; i2++; continue;
                }
                if (!inq) {
                    if (eq_pos == 0 && ch == "=") eq_pos = i2;
                    if (i2 + 5 <= _len && string_copy(_up, i2, 6) == "INKEY$") { found_inkey = true; break; }
                }
                i2++;
            }

            if (found_inkey) {
                var implicit_assign = false;
                if (eq_pos > 0) {
                    var lhs = string_trim(string_copy(_src, 1, eq_pos - 1));
                    if (string_length(lhs) > 0) {
                        var h  = string_upper(string_char_at(lhs, 1));
                        var oc = ord(h);
                        if (oc >= 65 && oc <= 90) implicit_assign = true;
                    }
                }
                if (!(_verb == "LET" || implicit_assign)) {
                    basic_syntax_error(
                        "INKEY$ may only appear on the right side of an assignment like  K$ = INKEY$",
                        global.current_line_number,
                        global.interpreter_current_stmt_index,
                        "INKEY_MISUSE"
                    );
                    return;
                }
            }
        }
        // ---------- END SYNTAX GUARD ----------

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

			                if (dbg_on(DBG_FLOW)) show_debug_message("COMMAND DISPATCH (collapsed IF): IF | ARG: " + (cond_src + " THEN " + then_src + (else_src!="" ? " ELSE " + else_src : "")));

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

			                if (dbg_on(DBG_FLOW)) show_debug_message("INLINE IF (" + string(truth) + "): THEN='" + then_src + "' ELSE='" + else_src + "'");

			                // If INPUT/PAUSE occurred inside the THEN/ELSE arm,
			                // schedule resume at NEXT colon segment and yield now.
			                if (global.pause_in_effect || global.awaiting_input) {
			                    if (dbg_on(DBG_FLOW)) show_debug_message("INLINE IF: pausing after arm — scheduling resume at next segment");
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

        if (dbg_on(DBG_FLOW)) show_debug_message("COMMAND DISPATCH: " + _verb + " | ARG: " + _rest);

        switch (_verb) {

            case "PRINT":
                if (global.current_mode >= 1) {
                    basic_cmd_print_mode1(_rest);
                } else {
                    basic_cmd_print(_rest, global.current_line_number);
                }
                break;

            case "LET":       basic_cmd_let(_rest); break;
            case "GOTO":      basic_cmd_goto(_rest); break;
            case "INPUT":     basic_cmd_input(_rest); break;
            case "COLOR":     basic_cmd_color(_rest); break;

            case "CLS":
                if (global.current_mode >= 1) { basic_cmd_cls_mode1(); }
                else                           { basic_cmd_cls(); }
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
            case "CHARAT":    basic_cmd_charat(_rest); break;
            case "PRINTAT":   basic_cmd_printat(_rest); break;
            case "FONT":      basic_cmd_font(_rest); break;
            case "DIM":       basic_cmd_dim(_rest); break; // 1-D arrays

            case "END":       basic_cmd_end(); break;

            case "REM":
                // no-op
                break;

            case "DATA":
                // Runtime no-op (DATA was harvested at load time)
                if (dbg_on(DBG_FLOW)) show_debug_message("DATA (runtime): no-op");
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

			case "BEEP":     basic_cmd_beep(_rest); break;

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
            if (dbg_on(DBG_FLOW)) show_debug_message("DISPATCH: pause/input armed → yielding after segment");
            return;
        }
    }
}
