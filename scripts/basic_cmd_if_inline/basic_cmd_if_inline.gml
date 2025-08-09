/// @script basic_cmd_if_inline
/// @description Legacy single-line IF…THEN…ELSE handler (tightened & quote-safe)
function basic_cmd_if_inline(arg) {
    // Safe check: don't read a global that doesn't exist
    var silent = (variable_global_exists("if_scan_mode") && global.if_scan_mode);

    var s  = string_trim(arg);
    var up = string_upper(s);
    if (!silent) show_debug_message("INLINE IF — Raw arg: '" + s + "'");

    // Local helper to find a top-level keyword with word boundaries (space/colon/EOL), quote-aware
    var _find_kw = function(_src, _up, _kw) {
        var L = string_length(_src), K = string_length(_kw);
        var in_q = false;
        for (var i = 1; i <= L - K + 1; i++) {
            var ch = string_char_at(_src, i);
            if (ch == "\"") { in_q = !in_q; continue; }
            if (in_q) continue;
            if (string_copy(_up, i, K) == _kw) {
                var prev = (i == 1) ? " " : string_char_at(_up, i - 1);
                var next = (i + K <= L) ? string_char_at(_up, i + K) : " ";
                var ok_prev = (prev == " " || prev == ":");
                var ok_next = (next == " " || next == ":" || (i + K - 1 == L));
                if (ok_prev && ok_next) return i;
            }
        }
        return 0;
    };

    var then_pos = _find_kw(s, up, "THEN");
    if (then_pos <= 0) {
        if (!silent) show_debug_message("?IF ERROR: Missing THEN in '" + s + "'");
        return;
    }
    var else_pos = _find_kw(s, up, "ELSE");

    // Slice parts (length parameter is explicit)
    var condition  = string_trim(string_copy(s, 1, then_pos - 1));
    var then_action, else_action;
    if (else_pos > then_pos) {
        var then_len = max(0, else_pos - (then_pos + 4));
        then_action  = string_trim(string_copy(s, then_pos + 4, then_len));
        var else_len = max(0, string_length(s) - (else_pos + 3));
        else_action  = string_trim(string_copy(s, else_pos + 4, else_len));
    } else {
        var tlen = max(0, string_length(s) - (then_pos + 3));
        then_action = string_trim(string_copy(s, then_pos + 4, tlen));
        else_action = "";
    }

    if (!silent) {
        show_debug_message("Parsed condition: '" + condition + "'");
        show_debug_message("Parsed THEN: '" + then_action + "'");
        show_debug_message("Parsed ELSE: '" + else_action + "'");
    }

    // Evaluate condition (AND/OR handled inside)
    var result = basic_evaluate_condition(condition);
    if (!silent) show_debug_message("Single/combined condition result: " + string(result));

    // Pick branch; strip trailing REM before executing
    var final_action = strip_basic_remark(string_trim(result ? then_action : else_action));
    if (final_action == "") {
        if (!silent) show_debug_message("No action to execute for this branch.");
        return;
    }

    // Promote bare assignment to LET (only if not already a known command)
    {
        var _sp   = string_pos(" ", final_action);
        var _head = (_sp > 0) ? string_upper(string_copy(final_action, 1, _sp - 1)) : string_upper(final_action);

        var _is_cmd =
              (_head == "PRINT")   || (_head == "LET")     || (_head == "INPUT")   || (_head == "CLS")
           || (_head == "COLOR")   || (_head == "BGCOLOR") || (_head == "IF")      || (_head == "FOR")
           || (_head == "NEXT")    || (_head == "WHILE")   || (_head == "WEND")    || (_head == "GOTO")
           || (_head == "GOSUB")   || (_head == "RETURN")  || (_head == "DIM")     || (_head == "END")
           || (_head == "MODE")    || (_head == "PSET")    || (_head == "CHARAT")  || (_head == "PRINTAT")
           || (_head == "FONT")    || (_head == "CLSCHAR");

        if (!_is_cmd) {
            var _depth2 = 0, eqpos = 0, Lfa = string_length(final_action);
            for (var i2 = 1; i2 <= Lfa; i2++) {
                var ch2 = string_char_at(final_action, i2);
                if (ch2 == "(") _depth2++;
                else if (ch2 == ")") _depth2 = max(0, _depth2 - 1);
                else if (ch2 == "=" && _depth2 == 0) { eqpos = i2; break; }
            }
            if (eqpos > 0) {
                final_action = "LET " + final_action;
                if (!silent) show_debug_message("INLINE IF: Promoted bare assignment to: '" + final_action + "'");
            }
        }
    }

    if (!silent) show_debug_message((result ? "THEN" : "ELSE") + " executing: '" + final_action + "'");

    // Execute action (fast-path GOTO sets the line jump)
    var sp = string_pos(" ", final_action);
    var cmd = (sp > 0) ? string_upper(string_copy(final_action, 1, sp - 1)) : string_upper(final_action);
    var action_arg = (sp > 0) ? string_trim(string_copy(final_action, sp + 1, string_length(final_action))) : "";

    if (cmd == "GOTO") {
        var line_target = real(action_arg);
        var index = ds_list_find_index(global.line_list, line_target);
        if (index >= 0) {
            global.interpreter_next_line = index; // honored by step loop
            if (!silent) show_debug_message("GOTO from IF → line " + string(line_target) + " (index " + string(index) + ")");
        } else {
            if (!silent) show_debug_message("?IF ERROR: GOTO target line not found: " + string(line_target));
        }
    } else {
        handle_basic_command(cmd, action_arg);
    }
}
