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




// ---------- SYNTAX GUARD: INKEY$ misuse (quote-aware) ----------
{
    var _src  = stmt;                      // stmt already had remarks stripped
    var _len  = string_length(_src);
    var _up   = string_upper(_src);

    var inq = false;       // inside "..."
    var i   = 1;
    var found_inkey = false;
    var eq_pos = 0;        // first '=' found outside quotes

    while (i <= _len) {
        var ch = string_char_at(_src, i);

        // Handle quotes and escaped quotes
        if (ch == "\"") {
            // Check for escaped quote "" inside strings
            if (i < _len && string_char_at(_src, i + 1) == "\"") {
                i += 2;    // skip escaped quote pair
                continue;
            }
            inq = !inq;    // toggle quote state
            i++;
            continue;
        }

        // Only process characters outside quotes
        if (!inq) {
            if (eq_pos == 0 && ch == "=") eq_pos = i;

            // Detect INKEY$ outside quotes - fixed the boundary check
            if (i + 5 <= _len && string_copy(_up, i, 6) == "INKEY$") {
                found_inkey = true;
                break;
            }
        }

        i++;
    }

    if (found_inkey) {
        // Allow only: LET ... = INKEY$  or implicit  NAME = INKEY$
        var implicit_assign = false;
        if (eq_pos > 0) {
            var lhs = string_trim(string_copy(_src, 1, eq_pos - 1));
            if (string_length(lhs) > 0) {
                var h  = string_upper(string_char_at(lhs, 1));
                var oc = ord(h);
                if (oc >= 65 && oc <= 90) implicit_assign = true;  // starts with A..Z
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
        /* line_no */ undefined, // let basic_syntax_error compute via basic_current_line_no()
        /* stmt_idx */ global.interpreter_current_stmt_index,
		"IF REQUIRES THEN"
    );
    return;
}


        // === INLINE IF COLLAPSE (also catches malformed inline IF without THEN) ===
        if (_verb == "IF") {
            // Reconstruct the original physical line from the dispatcher’s position
            var line_idx   = global.interpreter_current_line_index; // set by Step
            var line_no    = global.line_list[| line_idx];
            var src_line   = ds_map_find_value(global.program_map, line_no);
            var parts_full = split_on_unquoted_colons(string_trim(src_line));

            // Build the remainder of this physical line from the current colon slot
            var p         = global.interpreter_current_stmt_index;  // set by Step
            var remainder = parts_full[p];
            for (var t = p + 1; t < array_length(parts_full); t++) {
                remainder += ":" + parts_full[t];
            }

            // Text after the "IF" keyword
            var after_if = string_trim(string_copy(remainder, 3, max(0, string_length(remainder) - 2)));
            var up_after = string_upper(after_if);

var has_then           = (string_pos("THEN", up_after) > 0);
var has_colon_tail     = (string_pos(":", remainder) > 0);
var has_action_no_then = (!has_then && string_length(after_if) > 0);

// Check if there's content after THEN
var has_content_after_then = false;
if (has_then) {
    var then_pos = string_pos("THEN", up_after);
    var after_then = string_trim(string_copy(after_if, then_pos + 4, string_length(after_if)));
    has_content_after_then = (string_length(after_then) > 0);
}

// Decide: inline vs. structured block IF…ENDIF
if (has_content_after_then || has_colon_tail || has_action_no_then) {
                // Inline: feed the whole thing to the inline handler
                var arg_full = remainder;
                var up_rem   = string_upper(string_trim(remainder));
                if (string_copy(up_rem, 1, 2) == "IF") {
                    arg_full = string_trim(string_copy(remainder, 3, string_length(remainder) - 2));
                }

                if (dbg_on(DBG_FLOW)) show_debug_message("COMMAND DISPATCH (collapsed IF): IF | ARG: " + arg_full);
                basic_cmd_if_inline(arg_full);

                // If the inline handler halted with an error, don't synthesize a jump
                if (global.program_has_ended || !global.interpreter_running) {
                    break; // stop dispatching; Step will show the error/end screen
                }

                // Otherwise, consume the rest of this physical line so Step won’t re-run it
                global.interpreter_use_stmt_jump = true;
                global.interpreter_target_line   = line_idx;
                global.interpreter_target_stmt   = array_length(parts_full); // end-of-line slot
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
			    if (global.current_mode >= 1) {
			        basic_cmd_cls_mode1();
			    } else {
			        basic_cmd_cls(); 
			    }
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

			case "SCREEN":    // This will be handled as a function in expressions
			case "POINT":     // This will be handled as a function in expressions  
			case "POS":       // This will be handled as a function in expressions
			case "CSRLIN":    // This will be handled as a function in expressions
			case "TAB":       // This will be handled in PRINT processing
			case "SPC":       // This will be handled in PRINT processing
			    break;
			
			case "FONTSET":  basic_cmd_fontset(_rest); 
			break;

            default:
                // implicit LET?  e.g.  "X = 5"
                if (string_pos("=", _verb + " " + _rest) > 0) {
                    basic_cmd_let(_verb + " " + _rest);
                } else {
                    basic_show_message("UNKNOWN COMMAND: " + _verb);
                }
                break;
        }
    }
}
