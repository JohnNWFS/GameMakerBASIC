// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function set_color_scheme(scheme) {
    scheme = string_upper(scheme);
    switch (scheme) {
        case "GREEN":
            keyword_color = c_lime;
            text_color = c_green;
            number_color = c_yellow;
            break;
        case "BLUE":
            keyword_color = c_cyan;
            text_color = c_blue;
            number_color = c_white;
            break;
        case "AMBER":
            keyword_color = c_orange;
            text_color = c_yellow;
            number_color = c_white;
            break;
        default:
            show_error_message("UNKNOWN COLOR SCHEME");
            return;
    }
    basic_show_message("COLOR SCHEME: " + scheme);
    update_display();
 }