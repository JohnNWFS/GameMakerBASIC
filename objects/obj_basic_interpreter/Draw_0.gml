/// @event obj_basic_interpreter/Draw
draw_set_font(fnt_basic);

    //draw_set_color(c_white);
	//draw_text(4, room_height - 60, "FONT=" + global.active_font_name + "  spr=" + string(global.active_font_sprite) + "  num=" + string(sprite_get_number(global.active_font_sprite)));


// === BACKGROUND === //
if (global.background_draw_enabled) {
    draw_set_color(global.background_draw_color);
    draw_rectangle(0, 0, room_width, room_height, false);
}

var font_height = string_height("A");
var visible_lines = floor(room_height / font_height) - 2;
var total_lines = ds_list_size(global.output_lines) + (global.awaiting_input ? 1 : 0);

// === SCROLL MANAGEMENT === //
if (!global.scroll_lock && global.interpreter_running && !global.awaiting_input && !global.program_has_ended) {
    global.scroll_offset = max(0, total_lines - visible_lines);
}
global.scroll_offset = clamp(global.scroll_offset, 0, max(0, total_lines - visible_lines));

// === OUTPUT TEXT === //
var y1 = 0;
for (var i = global.scroll_offset; i < ds_list_size(global.output_lines); i++) {
    var col = (i < ds_list_size(global.output_colors)) ? global.output_colors[| i] : global.basic_text_color;
    draw_set_color(col);
    draw_text(16, y1, global.output_lines[| i]);
    y1 += font_height;
}

// === INPUT LINE OR PAUSE === //
if (global.awaiting_input) {
    draw_set_color(global.basic_text_color);
    var input_str = "";

    if (global.input_expected) {
        // We're in INPUT mode
        input_str = "? " + global.interpreter_input;
    } else {
        // We're in PAUSE mode
        input_str = global.interpreter_input;

        var curr_color = draw_get_color();
        var txt = "PAUSED...";
        var xx = room_width div 2;
        var yy = room_height div 2;

        draw_set_color(c_black);
        draw_text(xx - 1, yy - 1, txt);
        draw_text(xx + 1, yy - 1, txt);
        draw_text(xx - 1, yy + 1, txt);
        draw_text(xx + 1, yy + 1, txt);

        draw_set_color(c_yellow);
        draw_text(xx, yy, txt);

        draw_set_color(curr_color);
    }

    if (current_time mod 1000 < 500) input_str += "|";
    draw_text(16, y1, input_str);
    y1 += font_height;
}

// === END MESSAGE === //
if (global.program_has_ended) {
    draw_set_color(c_lime);
    draw_text(16, y1 + 16, "Program has ended - ESC or ENTER to return");
}
