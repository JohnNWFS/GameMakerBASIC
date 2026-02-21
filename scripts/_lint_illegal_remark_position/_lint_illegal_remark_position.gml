/// @helper _lint_illegal_remark_position(stmt_raw)
/// Returns >0 if a top-level REM or ' appears after code in the colon segment (illegal), else 0
function _lint_illegal_remark_position(stmt_raw) {
    var s   = stmt_raw;
    var L   = string_length(s);
    var inq = false;

    // Find first non-space char
    var head = 1;
    while (head <= L && string_char_at(s, head) == " ") head++;

    // If the segment *starts* with a remark, it's allowed
    if (head <= L) {
        if (string_char_at(s, head) == "'") return 0;
        if (head + 2 <= L && string_upper(string_copy(s, head, 3)) == "REM") return 0;
    }

    // Otherwise, scan for a top-level ' or REM token later in the segment
    for (var i = 1; i <= L; i++) {
        var ch = string_char_at(s, i);

        if (ch == "\"") { 
            // handle doubled quotes "" as a literal quote
            if (i < L && string_char_at(s, i + 1) == "\"") { i += 1; continue; }
            inq = !inq; 
            continue; 
        }

        if (!inq) {
            // Apostrophe found later → illegal
            if (ch == "'") return i;

            // Check for REM token at top level with word-ish boundaries
            if (i + 2 <= L && string_upper(string_copy(s, i, 3)) == "REM") {
                var prev = (i == 1) ? " " : string_char_at(s, i - 1);
                var next = (i + 3 <= L) ? string_char_at(s, i + 3) : " ";
                var prev_ok = (prev == " " || prev == ":");
                var next_ok = (next == " " || next == ":" || i + 3 > L);
                if (prev_ok && next_ok) {
                    // Since we already know it didn't start the segment, this is inline → illegal
                    return i;
                }
            }
        }
    }
    return 0;
}
