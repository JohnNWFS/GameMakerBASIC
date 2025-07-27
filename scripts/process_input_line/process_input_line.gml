// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function process_input_line(input_text) {
    // Trim whitespace
    input_text = string_trim(input_text);
    
    if (input_text == "") return;
    
    // Check if line starts with a number
    var first_space = string_pos(" ", input_text);
    var potential_line_num = "";
    
    if (first_space > 0) {
        potential_line_num = string_copy(input_text, 1, first_space - 1);
    } else {
        potential_line_num = input_text;
    }
    
    // Check if it's a valid line number
    if (is_line_number(potential_line_num)) {
        handle_program_line(input_text);
    } else {
        handle_command(input_text);
    }
 }