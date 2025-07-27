/// @description Draw interpreter output and current input
draw_set_font(fnt_basic);
//global.current_draw_color = global.basic_text_color;

var font_height = string_height("A");
var y1 = 32;

// Draw output lines
for (var i = 0; i < ds_list_size(output_lines); i++) {
    if (i < ds_list_size(global.output_colors)) {
        draw_set_color(global.output_colors[| i]);
    } else {
        draw_set_color(global.basic_text_color);
    }
    draw_text(16, y1, ds_list_find_value(output_lines, i));
    y1 += font_height;
}

// Draw input prompt if waiting
if (global.awaiting_input) {
    draw_set_color(global.basic_text_color);
    var input_str = "? " + global.interpreter_input;

    // Blinking cursor
    if (current_time mod 1000 < 500) {
        input_str += "|";
    }

    draw_text(16, y1, input_str);
}
