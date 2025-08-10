/// @script basic_cmd_if_inline
/// @description Single-line IF…THEN…ELSE. Executes THEN here and tells Step which colon slot to resume at.
function basic_cmd_if_inline(arg) {
    var s  = string_trim(arg);
    var up = string_upper(s);
    if (dbg_on(DBG_FLOW)) show_debug_message("INLINE IF — Raw arg: '" + s + "'");

    // --- find THEN / ELSE at top-level (quote-safe) ---
    var find_kw = function(_src, _up, _kw) {
        var L = string_length(_src), K = string_length(_kw), inq = false;
        for (var i = 1; i <= L - K + 1; i++) {
            var ch = string_char_at(_src, i);
            if (ch == "\"") { inq = !inq; continue; }
            if (inq) continue;
            if (string_copy(_up, i, K) == _kw) {
                var prev = (i == 1) ? " " : string_char_at(_up, i - 1);
                var next = (i + K <= L) ? string_char_at(_up, i + K) : " ";
                if ((prev == " " || prev == ":") && (next == " " || next == ":" || i + K - 1 == L)) return i;
            }
        }
        return 0;
    };

    var then_pos = find_kw(s, up, "THEN");
    if (then_pos <= 0) { if (dbg_on(DBG_FLOW)) show_debug_message("?IF ERROR: Missing THEN"); return; }
    var else_pos = find_kw(s, up, "ELSE");

    // --- slice condition / then / else ---
    var condition  = string_trim(string_copy(s, 1, then_pos - 1));
    var then_action, else_action;
    if (else_pos > then_pos) {
        then_action = string_trim(string_copy(s, then_pos + 4, else_pos - (then_pos + 4)));
        else_action = string_trim(string_copy(s, else_pos + 4, string_length(s) - (else_pos + 3)));
    } else {
        then_action = string_trim(string_copy(s, then_pos + 4, string_length(s) - (then_pos + 3)));
        else_action = "";
    }

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("Parsed condition: '" + condition + "'");
        show_debug_message("Parsed THEN: '" + then_action + "'");
        show_debug_message("Parsed ELSE: '" + else_action + "'");
    }

    // --- evaluate condition ---
    var cond = basic_evaluate_condition(condition);
    if (dbg_on(DBG_FLOW)) show_debug_message("Single/combined condition result: " + string(cond));

    // --- split branches into colon segments (quote/paren-safe) ---
    var then_parts = (then_action != "") ? split_on_unquoted_colons(then_action) : [];
    var else_parts = (else_action != "") ? split_on_unquoted_colons(else_action) : [];

    // We're currently executing colon slot `p` of this BASIC line.
    var p          = global.interpreter_current_stmt_index;
    var line_idx   = global.interpreter_current_line_index;

    // Helper: run one segment with your promotion whitelist intact
    var run_seg = function(seg) {
        seg = strip_basic_remark(string_trim(seg)); if (seg == "") return;

        var sp = string_pos(" ", seg);
        var head = (sp > 0) ? string_upper(string_copy(seg, 1, sp - 1)) : string_upper(seg);
        var is_cmd =
              (head == "PRINT") || (head == "LET")   || (head == "INPUT") || (head == "CLS")
           || (head == "COLOR") || (head == "BGCOLOR") || (head == "IF")    || (head == "FOR")
           || (head == "NEXT")  || (head == "WHILE")   || (head == "WEND")  || (head == "GOTO")
           || (head == "GOSUB") || (head == "RETURN")  || (head == "DIM")   || (head == "END")
           || (head == "MODE")  || (head == "PSET")    || (head == "CHARAT")|| (head == "PRINTAT")
           || (head == "FONT")  || (head == "CLSCHAR") || (head == "PAUSE");

        if (!is_cmd) {
            var d = 0, eq = 0, L = string_length(seg);
            for (var i = 1; i <= L; i++) {
                var ch = string_char_at(seg, i);
                if (ch == "(") d++;
                else if (ch == ")") d = max(0, d - 1);
                else if (ch == "=" && d == 0) { eq = i; break; }
            }
            if (eq > 0) {
                seg = "LET " + seg;
                if (dbg_on(DBG_FLOW)) show_debug_message("INLINE IF: Promoted → '" + seg + "'");
            }
        }

        var sp2 = string_pos(" ", seg);
        var cmd = (sp2 > 0) ? string_upper(string_copy(seg, 1, sp2 - 1)) : string_upper(seg);
        var arg = (sp2 > 0) ? string_trim(string_copy(seg, sp2 + 1, string_length(seg))) : "";

        if (dbg_on(DBG_FLOW)) show_debug_message("INLINE IF seg → " + cmd + " '" + arg + "'");
        if (cmd == "GOTO") {
            var line_target = real(arg);
            var idx = ds_list_find_index(global.line_list, line_target);
            if (idx >= 0) {
                global.interpreter_next_line = idx;
                if (dbg_on(DBG_FLOW)) show_debug_message("INLINE IF: GOTO → line " + string(line_target) + " (index " + string(idx) + ")");
            } else if (dbg_on(DBG_FLOW)) show_debug_message("?IF ERROR: GOTO target not found: " + string(line_target));
        } else {
            handle_basic_command(cmd, arg);
        }
    };

    if (cond) {
        // Execute the THEN branch here (all of it)
        if (dbg_on(DBG_FLOW)) show_debug_message("INLINE IF: executing THEN with " + string(array_length(then_parts)) + " segment(s).");
        for (var k = 0; k < array_length(then_parts); k++) run_seg(then_parts[k]);

        // Resume at the next colon slot after this IF statement
        global.interpreter_use_stmt_jump = true;
        global.interpreter_target_line   = line_idx;
        global.interpreter_target_stmt   = p + 1;
        if (dbg_on(DBG_FLOW)) show_debug_message("INLINE IF: resume at stmt index " + string(global.interpreter_target_stmt));
 } else {
    // Condition FALSE
    if (else_action != "") {
        // Execute the ELSE branch here (ELSE lives in the *same* inline statement)
        if (dbg_on(DBG_FLOW)) show_debug_message("INLINE IF: executing ELSE with " + string(array_length(else_parts)) + " segment(s).");
        for (var k = 0; k < array_length(else_parts); k++) run_seg(else_parts[k]);

        // Resume at the next colon slot after this IF
        global.interpreter_use_stmt_jump = true;
        global.interpreter_target_line   = line_idx;
        global.interpreter_target_stmt   = p + 1;
    } else {
        // No ELSE: skip to next statement after the IF
        global.interpreter_use_stmt_jump = true;
        global.interpreter_target_line   = line_idx;
        global.interpreter_target_stmt   = p + 1;
    }
}

}