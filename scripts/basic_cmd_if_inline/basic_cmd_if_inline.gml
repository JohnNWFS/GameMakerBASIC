/// @script basic_cmd_if_inline
/// @description Single-line IF…THEN…ELSE helpers and collapse across colon segments.

/// Join colon-separated statement parts from index _start to end.
function basic_join_colon_parts(_parts, _start) {
    var out = "";
    for (var _part_i = _start; _part_i < array_length(_parts); _part_i++) {
        if (_part_i > _start) out += ":";
        out += _parts[_part_i];
    }
    return out;
}

/// How many colon parts (from _start) cover _consumed chars in the joined string.
function basic_colon_segments_spanned(_parts, _start, _consumed) {
    var cum = 0;
    for (var _part_i = _start; _part_i < array_length(_parts); _part_i++) {
        if (_part_i > _start) cum += 1;
        cum += string_length(_parts[_part_i]);
        if (cum >= _consumed) return _part_i - _start + 1;
    }
    return array_length(_parts) - _start;
}

/// Quote/paren-aware keyword search with word boundaries.
function basic_find_kw_boundary(_src, _kw) {
    var up  = string_upper(_src);
    var kw  = string_upper(_kw);
    var L   = string_length(_src);
    var K   = string_length(kw);
    var inq = false;
    var _depth = 0;

    for (var i = 1; i <= L - K + 1; i++) {
        var ch = string_char_at(_src, i);
        if (ch == "\"") {
            var nxt = (i < L) ? string_char_at(_src, i + 1) : "";
            if (inq && nxt == "\"") { i++; continue; }
            inq = !inq;
            continue;
        }
        if (inq) continue;

        if (ch == "(") _depth++;
        else if (ch == ")") _depth = max(0, _depth - 1);

        if (_depth == 0 && string_copy(up, i, K) == kw) {
            var prev = (i == 1) ? " " : string_char_at(_src, i - 1);
            var next = (i + K <= L) ? string_char_at(_src, i + K) : " ";
            if ((prev == " " || prev == ":") && (next == " " || next == ":" || i + K - 1 == L)) {
                return i;
            }
        }
    }
    return 0;
}

/// First top-level character _ch in _src (outside quotes/parens), else 0.
function basic_find_top_level_char(_src, _ch) {
    var L = string_length(_src);
    var inq = false;
    var _depth = 0;
    for (var i = 1; i <= L; i++) {
        var ch = string_char_at(_src, i);
        if (ch == "\"") {
            var nxt = (i < L) ? string_char_at(_src, i + 1) : "";
            if (inq && nxt == "\"") { i++; continue; }
            inq = !inq;
            continue;
        }
        if (!inq) {
            if (ch == "(") _depth++;
            else if (ch == ")") _depth = max(0, _depth - 1);
            else if (ch == _ch && _depth == 0) return i;
        }
    }
    return 0;
}

/// Parse inline IF text that begins with IF. Returns ok=false for block IF (empty THEN tail).
function basic_inline_if_dissect_scope(_scope) {
    var out = { ok: false, cond_src: "", then_src: "", else_src: "", consumed: 0 };

    var s = string_trim(_scope);
    var L = string_length(s);
    if (L < 4) return out;

    var s0 = 1;
    while (s0 <= L && string_char_at(s, s0) == " ") s0++;
    if (string_upper(string_copy(s, s0, 2)) != "IF") return out;

    var cond_start = s0 + 2;
    while (cond_start <= L && string_char_at(s, cond_start) == " ") cond_start++;
    if (cond_start > L) return out;

    var then_pos = basic_find_kw_boundary(s, "THEN");
    if (then_pos <= 0 || then_pos < cond_start) return out;

    out.cond_src = string_trim(string_copy(s, cond_start, then_pos - cond_start));

    var tail = string_copy(s, then_pos + 4, L - (then_pos + 4) + 1);
    if (string_trim(tail) == "") return out;

    var else_pos = basic_find_kw_boundary(tail, "ELSE");
    if (else_pos > 0) {
        out.then_src = string_trim(string_copy(tail, 1, else_pos - 1));
        var after_else = string_copy(tail, else_pos + 4, string_length(tail) - (else_pos + 3));
        var colon_pos  = basic_find_top_level_char(after_else, ":");
        var else_len   = (colon_pos > 0) ? colon_pos - 1 : string_length(after_else);
        out.else_src   = string_trim(string_copy(after_else, 1, else_len));
        out.consumed   = then_pos + 4 + else_pos - 1 + 4 + else_len;
    } else {
        out.then_src = string_trim(tail);
        out.else_src = "";
        out.consumed = L;
    }

    out.ok = true;
    return out;
}

/// Try to execute an inline IF spanning colon parts from _p; returns true if handled.
function basic_inline_if_collapse_from_line(_parts, _p, _line_idx) {
    var scope = string_trim(basic_join_colon_parts(_parts, _p));
    if (scope == "") return false;

    var info = basic_inline_if_dissect_scope(scope);
    if (!info.ok) return false;

    // Lint: unconditional flow immediately after the inline IF span
    var span = basic_colon_segments_spanned(_parts, _p, info.consumed);
    var next_idx = _p + span;
    if (next_idx < array_length(_parts)) {
        var next_seg_raw = strip_basic_remark(string_trim(_parts[next_idx]));
        var spn  = string_pos(" ", next_seg_raw);
        var vraw = (spn > 0) ? string_copy(next_seg_raw, 1, spn - 1) : next_seg_raw;
        var vup  = string_upper(vraw);
        if (vup == "GOTO" || vup == "RETURN" || vup == "END") {
            basic_syntax_error(
                "Illegal inline flow: unconditional " + vup +
                " appears after an inline IF on the same line. " +
                "Move the " + vup + " into THEN/ELSE or onto the next line.",
                global.current_line_number,
                next_idx,
                "INLINE_FLOW_HAZARD"
            );
            return true;
        }
    }

    var truth = basic_evaluate_condition(info.cond_src);

    dbg_log(DBG_FLOW, "COMMAND DISPATCH (collapsed IF): IF | ARG: " +
        (info.cond_src + " THEN " + info.then_src + (info.else_src != "" ? " ELSE " + info.else_src : "")));

    if (truth) {
        if (info.then_src != "") handle_basic_command(info.then_src, "");
    } else {
        if (info.else_src != "") handle_basic_command(info.else_src, "");
    }

    dbg_log(DBG_FLOW, "INLINE IF (" + string(truth) + "): THEN='" + info.then_src + "' ELSE='" + info.else_src + "'");

    global.interpreter_use_stmt_jump = true;
    global.interpreter_target_line   = _line_idx;
    global.interpreter_target_stmt   = _p + span;

    if (global.pause_in_effect || global.awaiting_input) {
        dbg_log(DBG_FLOW, "INLINE IF: pausing after arm — scheduling resume at next segment");
    }

    return true;
}

/// Legacy entry: arg is everything after IF for a single colon segment.
function basic_cmd_if_inline(arg) {
    var s = strip_basic_remark(string_trim(arg));
    var then_pos = basic_find_kw_boundary(s, "THEN");
    if (then_pos <= 0) {
        basic_syntax_error("IF requires THEN",
            basic_current_line_no(),
            global.interpreter_current_stmt_index,
            "IF MISSING THEN");
        return;
    }

    var else_pos = basic_find_kw_boundary(s, "ELSE");
    var condition = string_trim(string_copy(s, 1, then_pos - 1));
    var then_action = "";
    var else_action = "";

    if (else_pos > then_pos) {
        then_action = string_trim(string_copy(s, then_pos + 4, else_pos - (then_pos + 4)));
        var after_else = string_copy(s, else_pos + 4, string_length(s) - (else_pos + 3));
        var colon_pos  = basic_find_top_level_char(after_else, ":");
        var else_len   = (colon_pos > 0) ? colon_pos - 1 : string_length(after_else);
        else_action    = string_trim(string_copy(after_else, 1, else_len));
    } else {
        then_action = string_trim(string_copy(s, then_pos + 4, string_length(s) - (then_pos + 3)));
    }

    var cond = basic_evaluate_condition(condition);
    var run_parts = cond
        ? (then_action != "" ? split_on_unquoted_colons(then_action) : [])
        : (else_action != "" ? split_on_unquoted_colons(else_action) : []);

    var p        = global.interpreter_current_stmt_index;
    var line_idx = global.interpreter_current_line_index;

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
        var arg2 = (sp2 > 0) ? string_trim(string_copy(seg, sp2 + 1, string_length(seg))) : "";

        if (cmd == "GOTO") {
            var line_arg = basic_eval_number_arg(arg2, "GOTO", "line");
            if (!line_arg.ok) return;
            var line_target = line_arg.value;
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
            handle_basic_command(cmd, arg2);
        }
    };

    for (var k = 0; k < array_length(run_parts); k++) {
        run_seg(run_parts[k]);
        if (global.program_has_ended || !global.interpreter_running) return;
    }

    global.interpreter_use_stmt_jump = true;
    global.interpreter_target_line   = line_idx;
    global.interpreter_target_stmt   = p + 1;
}