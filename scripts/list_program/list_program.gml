// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function list_program() {
    display_start_line = 0;
    update_display();
 }
 function list_program_range(range) {
    // Parse range like "10-50" or single number "10"
    var dash_pos = string_pos("-", range);
    if (dash_pos > 0) {
        var start_line = real(string_copy(range, 1, dash_pos - 1));
        var end_line = real(string_copy(range, dash_pos + 1, string_length(range)));
        list_between_lines(start_line, end_line);
    } else {
        var single_line = real(range);
        list_single_line(single_line);
    }
 }