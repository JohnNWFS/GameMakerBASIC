/// Map trap hint/message to a QBASIC-style ERR code for ERR() in handlers.
function basic_err_code_from_hint(_key, _msg) {
    var k = string_upper(string_trim(string(_key)));
    switch (k) {
        case "DIV_ZERO":           return 11;
        case "GOSUB_MISMATCH":     return 3;
        case "RESUME_NO_TRAP":     return 20;
        case "ARRAY_INDEX_RANGE":
        case "ARRAY_DIM_MISMATCH":
        case "ARRAY_INDEX_EVAL":   return 9;
        case "TYPE_MISMATCH":      return 13;
        case "READ_OUT_OF_DATA":   return 4;
        default: break;
    }
    var m = string_upper(string(_msg));
    if (string_pos("DIVISION BY ZERO", m) > 0) return 11;
    if (string_pos("RETURN WITHOUT", m) > 0)   return 3;
    if (string_pos("OUT OF DATA", m) > 0)        return 4;
    if (string_pos("OUT OF BOUNDS", m) > 0
     || string_pos("INDEX BELOW", m) > 0
     || string_pos("DIMENSION MISMATCH", m) > 0) return 9;
    return 2; // generic syntax / runtime error
}

/// @script basic_error_hint
/// Return an array of short hint lines (<= 3) for a given key.
function basic_error_hint(key) {
    var lines = [];
    switch (string_upper(string(key))) {
        case "INKEY_MISUSE":
            lines[0] = "INKEY$ must assign to a var.";
            lines[1] = "Use:  K$ = INKEY$";
            lines[2] = "Then PRINT K$ if desired.";
            break;

        case "IF_MISSING_THEN":
            lines[0] = "Use: IF cond THEN stmt";
            lines[1] = "Or multi-line IF...ENDIF";
            lines[2] = "Example: IF X=1 THEN PRINT X";
            break;

        case "FOR_MISMATCH":
            lines[0] = "FOR must have matching NEXT.";
            lines[1] = "Example: FOR I=1 TO 10 : ... : NEXT";
            break;

        case "WHILE_MISMATCH":
            lines[0] = "WHILE must end with WEND.";
            break;

        default:
            lines[0] = ""; lines[1] = ""; lines[2] = "";
            break;
    }
    return lines;
}
