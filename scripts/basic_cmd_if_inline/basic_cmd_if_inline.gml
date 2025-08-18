/// @script basic_cmd_if_inline
/// @description Single-line IF…THEN…ELSE. Executes THEN/ELSE here and tells Step which colon slot to resume at.
function basic_cmd_if_inline(arg) {
    // 1) Normalize and strip inline remarks first
    var s = string_trim(arg);
    s = strip_basic_remark(s);
    var s_upper = string_upper(s);

    // 2) Quote-safe, word-boundary keyword find
    var find_kw = function(_src, _up, _kw) {
        var L = string_length(_src), K = string_length(_kw), inq = false;
        for (var i = 1; i <= L - K + 1; i++) {
            var ch = string_char_at(_src, i);
            if (ch == "\"") { inq = !inq; continue; }
            if (inq) continue;

            if (string_copy(_up, i, K) == _kw) {
                var prev = (i == 1) ? " " : string_char_at(_up, i - 1);
                var next = (i + K <= L) ? string_char_at(_up, i + K) : " ";
                if ((prev == " " || prev == ":") && (next == " " || next == ":" || i + K - 1 == L)) {
                    return i;
                }
            }
        }
        return 0;
    };

    // 3) Require THEN
    var then_pos = find_kw(s, s_upper, "THEN");
		if (then_pos <= 0) {
		    basic_syntax_error("IF requires THEN", 
			basic_current_line_no(), 
			global.interpreter_current_stmt_index,
			"IF MISSING THEN");
		    return;
		}
    var else_pos = find_kw(s, s_upper, "ELSE");

    // 4) Slice parts
    var condition = string_trim(string_copy(s, 1, then_pos - 1));
    var then_action, else_action;
    if (else_pos > then_pos) {
        then_action = string_trim(string_copy(s, then_pos + 4, else_pos - (then_pos + 4)));
        else_action = string_trim(string_copy(s, else_pos + 4, string_length(s) - (else_pos + 3)));
    } else {
        then_action = string_trim(string_copy(s, then_pos + 4, string_length(s) - (then_pos + 3)));
        else_action = "";
    }

    // 5) Evaluate condition
    var cond = basic_evaluate_condition(condition);

    // 6) Split branches into colon segments
    var run_parts = cond ? (then_action != "" ? split_on_unquoted_colons(then_action) : []) 
                         : (else_action != "" ? split_on_unquoted_colons(else_action) : []);

    var p        = global.interpreter_current_stmt_index;
    var line_idx = global.interpreter_current_line_index;

    // 7) Runner: executes a single colon-segment with implicit-LET promotion
    var run_seg = function(seg) {
        seg = strip_basic_remark(string_trim(seg));
        if (seg == "") return;

        var sp = string_pos(" ", seg);
        var head = (sp > 0) ? string_upper(string_copy(seg, 1, sp - 1)) : string_upper(seg);

        var is_cmd =
              (head == "PRINT")   || (head == "LET")     || (head == "INPUT")   || (head == "CLS")
           || (head == "COLOR")   || (head == "BGCOLOR") || (head == "IF")      || (head == "FOR")
           || (head == "NEXT")    || (head == "WHILE")   || (head == "WEND")    || (head == "GOTO")
           || (head == "GOSUB")   || (head == "RETURN")  || (head == "DIM")     || (head == "END")
           || (head == "MODE")    || (head == "PSET")    || (head == "CHARAT")  || (head == "PRINTAT")
           || (head == "FONT")    || (head == "CLSCHAR") || (head == "PAUSE")
           || (head == "READ")    || (head == "RESTORE") || (head == "DATA")    || (head == "INKEY$");

        if (!is_cmd) {
            var d = 0, eq = 0, L = string_length(seg);
            for (var i = 1; i <= L; i++) {
                var ch = string_char_at(seg, i);
                if (ch == "(") d++;
                else if (ch == ")") d = max(0, d - 1);
                else if (ch == "=" && d == 0) { eq = i; break; }
            }
            if (eq > 0) seg = "LET " + seg;
        }

        var sp2 = string_pos(" ", seg);
        var cmd = (sp2 > 0) ? string_upper(string_copy(seg, 1, sp2 - 1)) : string_upper(seg);
        var arg = (sp2 > 0) ? string_trim(string_copy(seg, sp2 + 1, string_length(seg))) : "";

        if (cmd == "GOTO") {
            var line_target = real(arg);
            var idx = ds_list_find_index(global.line_list, line_target);
            if (idx >= 0) {
                global.interpreter_next_line = idx;
            } else {
                basic_syntax_error("GOTO target not found: " + string(line_target), 
				global.current_line_number, 
				p,
				"TARGET NOT FOUND");
            }
        } else {
            handle_basic_command(cmd, arg);
        }
    };

    // 8) Execute chosen branch (if any)
    for (var k = 0; k < array_length(run_parts); k++) {
        run_seg(run_parts[k]);
        if (global.program_has_ended || !global.interpreter_running) return; // error halted
    }

    // 9) Tell Step to resume after this IF colon-slot
    global.interpreter_use_stmt_jump = true;
    global.interpreter_target_line   = line_idx;
    global.interpreter_target_stmt   = p + 1;
}
