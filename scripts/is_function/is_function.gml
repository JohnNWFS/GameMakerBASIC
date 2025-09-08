/// @script is_function
// === BEGIN: is_function ===
function is_function(t) {
    var fn = string_upper(string_trim(t));
    return  fn == "RND"    // your original BASIC call
         || fn == "RND1"   // internal 1-arg postfix token
         || fn == "RND2"   // internal 2-arg postfix token
         || fn == "STR$"
         || fn == "CHR$"
         || fn == "LEFT$"
         || fn == "RIGHT$"
         || fn == "MID$"
         || fn == "ABS"
         || fn == "INT"
         || fn == "EXP"
         || fn == "LOG"
         || fn == "LOG10"
         || fn == "SGN"
         || fn == "SIN"
         || fn == "COS"
         || fn == "TAN"
         || fn == "REPEAT$"
         || fn == "TIMER"
         || fn == "TIME$"
         || fn == "DATE$"
         || fn == "INKEY$"
         || fn == "ASC"
		 || fn == "LEN";   // <-- added
}
// === END: is_function ===
