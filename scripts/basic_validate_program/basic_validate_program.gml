function basic_validate_program() {
    // Ensure structures exist
    if (!ds_exists(global.program_map, ds_type_map) || !ds_exists(global.line_list, ds_type_list)) return true;

    // Helpers local to validator
    var _top_level_eq_pos = function(s) {
        var L = string_length(s), _depth = 0, inq = false;
        for (var i = 1; i <= L; i++) {
            var ch = string_char_at(s, i);
            if (ch == "\"") { inq = !inq; continue; }
            if (inq) continue;
            if (ch == "(") { _depth++; continue; }
            if (ch == ")") { if (_depth > 0) _depth--; continue; }
            if (ch == "=" && _depth == 0) return i;
        }
        return 0;
    };
    
    var _is_letter = function(ch) {
        if (string_length(ch) < 1) return false;
        var c = ord(string_upper(ch));
        return (c >= 65 && c <= 90);
    };
    
    var _is_valid_lhs = function(lhs) {
        lhs = string_trim(lhs);
        if (lhs == "") return false;
        var head = string_char_at(lhs, 1);
        // Inline the letter check to avoid scoping issues
        var head_ord = ord(string_upper(head));
        var is_valid_head = (string_length(head) >= 1) && (head_ord >= 65 && head_ord <= 90);
        if (!is_valid_head) return false;
        var p = string_pos("(", lhs);
        if (p > 0 && string_char_at(lhs, string_length(lhs)) != ")") return false;
        return true;
    };
    
    var _has_unquoted_inkey = function(stmt, up) {
        var inq = false;
        var stmt_len = string_length(stmt);
        for (var j = 1; j <= stmt_len - 5; j++) {
            var ch = string_char_at(stmt, j);
            if (ch == "\"") {
                if (j < stmt_len && string_char_at(stmt, j + 1) == "\"") {
                    j++; // skip escaped quote
                    continue;
                }
                inq = !inq;
                continue;
            }
            if (!inq && j + 5 <= stmt_len && string_copy(up, j, 6) == "INKEY$") {
                return true;
            }
        }
        return false;
    };

    // Walk each physical line in program order
    for (var i = 0; i < ds_list_size(global.line_list); i++) {
        var line_no  = global.line_list[| i];
        var src_line = ds_map_find_value(global.program_map, line_no);
        if (!is_string(src_line)) continue;

        // Split on top-level colons (your helper)
        var parts = split_on_unquoted_colons(string_trim(src_line));
        for (var p = 0; p < array_length(parts); p++) {
            var stmt_raw = string_trim(parts[p]);
            if (stmt_raw == "") continue;

            // Ignore REM / apostrophe comments entirely
            var sp  = string_pos(" ", stmt_raw);
            var verb = (sp > 0) ? string_upper(string_copy(stmt_raw, 1, sp - 1)) : string_upper(stmt_raw);
            if (verb == "REM" || string_char_at(stmt_raw, 1) == "'") break;

            var stmt = strip_basic_remark(stmt_raw);
            var up   = string_upper(stmt);

            // Use quote-aware INKEY$ detection instead of simple string_pos
            if (_has_unquoted_inkey(stmt, up)) {
                var eqp = _top_level_eq_pos(stmt);
                if (eqp > 0) {
                    var lhs = string_copy(stmt, 1, eqp - 1);
                    if (!_is_valid_lhs(lhs)) {
                        basic_syntax_error("Left side of assignment must be a variable or array name before INKEY$", line_no, p, "INKEY_LHS");
                        return false;
                    }
                } else if (verb != "LET") {
                    basic_syntax_error("INKEY$ may only appear on the right side of an assignment like  X$ = INKEY$", line_no, p, "INKEY_MISUSE");
                    return false;
                }
            }
        }
    }
    return true;
}