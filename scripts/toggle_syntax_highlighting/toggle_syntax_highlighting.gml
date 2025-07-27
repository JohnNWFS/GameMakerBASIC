// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function toggle_syntax_highlighting() {
    syntax_highlighting = !syntax_highlighting;
    basic_show_message("SYNTAX HIGHLIGHTING: " + (syntax_highlighting ? "ON" : "OFF"));
    update_display();
 }
