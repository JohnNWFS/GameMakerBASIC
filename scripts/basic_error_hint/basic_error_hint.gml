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
