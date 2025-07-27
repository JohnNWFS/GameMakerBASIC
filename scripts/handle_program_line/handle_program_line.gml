// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function handle_program_line(input_text) {
    var space_pos = string_pos(" ", input_text);
    var line_num = real(string_copy(input_text, 1, space_pos - 1));
    var code_content = string_copy(input_text, space_pos + 1, string_length(input_text));
    
    // If no code content, delete the line
    if (string_trim(code_content) == "") {
        delete_program_line(line_num);
    } else {
        add_or_update_program_line(line_num, code_content);
    }
    
    update_display();
 }