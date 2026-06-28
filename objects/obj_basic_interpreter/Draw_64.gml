/// Draw GUI — browser-only interpreter input / end footer above on-screen keyboard.
if (!nwbasic_is_browser_runtime()) exit;
if (!global.interpreter_running && !global.program_has_ended) exit;

var _metrics = nwbasic_browser_chrome_metrics(string_height("A"));

if (global.awaiting_input && global.input_expected) {
    var _pfx = (variable_global_exists("input_show_qmark") && !global.input_show_qmark && variable_global_exists("input_prompt"))
               ? global.input_prompt
               : "? ";
    var input_str = _pfx + global.interpreter_input;
    if (current_time mod 1000 < 500) input_str += "|";
    nwbasic_browser_draw_interpreter_prompt(_metrics, input_str);
}

if (global.program_has_ended) {
    var _base = _metrics.prompt_base_gui;
    var _fh = _metrics.font_h;
    draw_set_font(fnt_basic);
    draw_set_color(make_color_rgb(16, 16, 16));
    draw_rectangle(0, _base - _fh * 2, _metrics.gw, _base, false);
    draw_set_color(c_lime);
    draw_text(16, _base - _fh, "Program has ended - ESC or ENTER to return");
}