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

        // Guard: IF must contain THEN in the same statement
        if (_verb == "IF" && string_pos("THEN", string_upper(_rest)) <= 0) {
            basic_syntax_error(
                "IF requires THEN",
                /* line_no */ undefined,
                /* stmt_idx */ global.interpreter_current_stmt_index,
                "IF REQUIRES THEN"
            );
            return;
        }

        // === INLINE IF COLLAPSE (only within THIS colon segment) ===
        if (_verb == "IF") {
            // Reconstruct the original physical line from the dispatcher’s position
            var line_idx   = global.interpreter_current_line_index; // set by Step
            var line_no    = global.line_list[| line_idx];
            var src_line   = ds_map_find_value(global.program_map, line_no);
            var parts_full = split_on_unquoted_colons(string_trim(src_line));

            // Use ONLY the current colon segment (do NOT append the rest of the line)
            var p       = global.interpreter_current_stmt_index;  // set by Step
            var segment = parts_full[p];

            // Text after the "IF" keyword within THIS segment only
            var after_if  = string_trim(string_copy(segment, 3, max(0, string_length(segment) - 2)));
            var up_after  = string_upper(after_if);

            var has_then = (string_pos("THEN", up_after) > 0);

            // Is there content after THEN within THIS segment?
            var has_content_after_then = false;
            if (has_then) {
                var then_pos   = string_pos("THEN", up_after);
                var after_then = string_trim(string_copy(after_if, then_pos + 4, string_length(after_if)));
                has_content_after_then = (string_length(after_then) > 0);
            }

            if (has_content_after_then) {
                // Inline: parse THEN/ELSE only inside this segment
                var arg_full = string_trim(string_copy(segment, 3, string_length(segment) - 2)); // after "IF"

                if (dbg_on(DBG_FLOW)) show_debug_message("COMMAND DISPATCH (collapsed IF): IF | ARG: " + arg_full);

                // Find top-level THEN (quote/paren-aware)
                var _arg = arg_full;
                var _L   = string_length(_arg);
                var _lvl = 0, _inq = false, _then_pos = 0;
                for (var _i = 1; _i <= _L - 4 + 1; _i++) {
                    var _ch = string_char_at(_arg, _i);
                    if (_ch == "\"") _inq = !_inq;
                    if (!_inq) {
                        if (_ch == "(") _lvl++;
                        else if (_ch == ")") _lvl = max(0, _lvl - 1);
                        if (_lvl == 0 && string_upper(string_copy(_arg, _i, 4)) == "THEN") { _then_pos = _i; break; }
                    }
                }

                if (_then_pos == 0) {
                    // Fallback: old handler
                    basic_cmd_if_inline(arg_full);
                } else {
                    // Split condition and the THEN/ELSE tail (still within this segment only)
                    var _cond_src = string_trim(string_copy(_arg, 1, _then_pos - 1));
                    var _tail     = string_trim(string_copy(_arg, _then_pos + 4, _L - (_then_pos + 4) + 1));

                    // Look for a top-level ELSE
                    var _L2 = string_length(_tail), _lvl2 = 0, _inq2 = false, _else_pos = 0;
                    for (var _j = 1; _j <= _L2 - 4 + 1; _j++) {
                        var _ch2 = string_char_at(_tail, _j);
                        if (_ch2 == "\"") _inq2 = !_inq2;
                        if (!_inq2) {
                            if (_ch2 == "(") _lvl2++;
                            else if (_ch2 == ")") _lvl2 = max(0, _lvl2 - 1);
                            if (_lvl2 == 0 && string_upper(string_copy(_tail, _j, 4)) == "ELSE") { _else_pos = _j; break; }
                        }
                    }

                    var _then_src = (_else_pos > 0) ? string_trim(string_copy(_tail, 1, _else_pos - 1)) : _tail;
                    var _else_src = (_else_pos > 0) ? string_trim(string_copy(_tail, _else_pos + 4, _L2 - (_else_pos + 4) + 1)) : "";

                    // Evaluate condition
                    var _tok  = basic_tokenize_expression_v2(_cond_src);
                    var _post = infix_to_postfix(_tok);
                    var _val  = evaluate_postfix(_post);
                    var _truth = 0;
                    if (is_real(_val))        _truth = (_val != 0);
                    else if (is_string(_val)) _truth = (string_length(_val) > 0);

                    // Execute the chosen arm by reusing the normal dispatcher
                    if (_truth) {
                        if (_then_src != "") handle_basic_command(_then_src, "");
                    } else {
                        if (_else_src != "") handle_basic_command(_else_src, "");
                    }

                    if (dbg_on(DBG_FLOW)) show_debug_message(
                        "INLINE IF (" + string(_truth) + "): THEN='" + _then_src + "' ELSE='" + _else_src + "'"
                    );

                    // *** FIX: If INPUT/PAUSE occurred inside the THEN/ELSE arm,
                    // set a statement-level jump to the NEXT colon segment (p+1)
                    // and return immediately so Step resumes AFTER this IF segment.
                    if (global.pause_in_effect || global.awaiting_input) {
                        if (dbg_on(DBG_FLOW)) show_debug_message("INLINE IF: pausing after arm — scheduling resume at next segment");
                        global.interpreter_use_stmt_jump = true;
                        global.interpreter_target_line   = line_idx;
                        global.interpreter_target_stmt   = p + 1;  // resume at next colon slot (or EOL)
                        return; // yield now
                    }
                }

                // If the inline handler halted with an error, don't synthesize a jump
                if (global.program_has_ended || !global.interpreter_running) {
                    break; // stop dispatching
                }

                // Normal path (no INPUT): advance to the NEXT colon segment on this line.
                global.interpreter_use_stmt_jump = true;
                global.interpreter_target_line   = line_idx;
                global.interpreter_target_stmt   = p + 1;
                break;
            }
            // Else fall-through to the structured IF handler below.
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
        //    case "POS":       // handled as function in expressions
            case "CSRLIN":    // handled as function in expressions
            case "TAB":       // handled in PRINT processing
            case "SPC":       // handled in PRINT processing
                break;

            case "FONTSET":   basic_cmd_fontset(_rest); break;

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
    }
}
