// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
 // Functions for input handling
 function handle_character_input() {
    var key_string = keyboard_string;
    
    // Robust keyboard handling with fallback
    if (key_string != last_keyboard_string) {
        var new_chars = string_copy(key_string, string_length(last_keyboard_string) + 1, 
                                   string_length(key_string) - string_length(last_keyboard_string));
        
        // Filter out control characters and validate input
        var filtered_chars = "";
        for (var i = 1; i <= string_length(new_chars); i++) {
            var char = string_char_at(new_chars, i);
            var char_code = ord(char);
            // Accept printable ASCII characters (32-126)
            if (char_code >= 32 && char_code <= 126) {
                filtered_chars += char;
            }
        }
        
        if (filtered_chars != "") {
            current_input = string_insert(filtered_chars, current_input, cursor_pos + 1);
            cursor_pos += string_length(filtered_chars);
        }
        
        last_keyboard_string = key_string;
    }
    
    // Fallback: Direct key detection for special cases
  //  if (keyboard_check_pressed(vk_space)) {
        // Ensure space is captured even if keyboard_string fails
  //      if (string_char_at(current_input, cursor_pos + 1) != " ") {
   //         current_input = string_insert(" ", current_input, cursor_pos + 1);
   //         cursor_pos++;
   //     }
   // }
 }
