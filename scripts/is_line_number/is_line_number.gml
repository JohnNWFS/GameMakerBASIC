// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
 function is_line_number(str) {
    // Check if string contains only digits
    if (string_length(str) == 0) return false;
    
    for (var i = 1; i <= string_length(str); i++) {
        var char = string_char_at(str, i);
        if (char < "0" || char > "9") return false;
    }
    
    // Convert to number and validate range
    var line_num = real(str);
    return (line_num >= 1 && line_num <= 65535);
 }