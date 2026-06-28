/// Browser / GX.games detection and layout for input strip + on-screen keyboard.

function nwbasic_is_browser_runtime() {
    return (os_type == os_gxgames || os_browser != browser_not_a_browser);
}

/// Reserved chrome: input strip always visible; keyboard optional below it.
function nwbasic_browser_chrome_metrics(_font_h) {
    var _kb_h = 0;
    if (instance_exists(obj_mobile_kb) && obj_mobile_kb.kb_visible) {
        _kb_h = obj_mobile_kb.KB_H;
    }

    if (!nwbasic_is_browser_runtime()) {
        return {
            is_browser: false,
            kb_h: 0,
            gw: room_width,
            gh: room_height,
            input_strip_gui: 0,
            content_bottom_room: room_height,
            prompt_base_gui: room_height,
            font_h: _font_h
        };
    }

    var _gh = display_get_gui_height();
    var _gw = display_get_gui_width();
    if (_gh < 100) _gh = room_height;
    if (_gw < 100) _gw = room_width;
    if (_font_h <= 0) _font_h = string_height("A");

    var _input_strip = _font_h * 3 + 12;
    var _prompt_base = _gh - _kb_h;
    var _scale = room_height / _gh;
    var _chrome_room = (_kb_h + _input_strip) * _scale;
    var _content_bottom_room = max(64, room_height - _chrome_room);

    return {
        is_browser: true,
        kb_h: _kb_h,
        gw: _gw,
        gh: _gh,
        input_strip_gui: _input_strip,
        content_bottom_room: _content_bottom_room,
        prompt_base_gui: _prompt_base,
        font_h: _font_h
    };
}

function nwbasic_browser_draw_editor_prompt(_metrics, _current_input, _cursor_pos, _message_text) {
    if (!_metrics.is_browser) return;

    var _fh = _metrics.font_h;
    var _base = _metrics.prompt_base_gui;
    var _x = 16;
    var _top = _base - _metrics.input_strip_gui;

    draw_set_font(fnt_basic);
    draw_set_color(make_color_rgb(16, 16, 16));
    draw_rectangle(0, _top, _metrics.gw, _base, false);
    draw_set_color(make_color_rgb(40, 40, 40));
    draw_line(0, _top, _metrics.gw, _top);

    if (_message_text != "") {
        draw_set_color(c_yellow);
        draw_text(_x, _base - _fh * 3, _message_text);
    }

    draw_set_color(make_color_rgb(255, 191, 64));
    draw_text(_x, _base - _fh * 2, "READY");
    draw_text(_x, _base - _fh, "> " + _current_input);

    var _cx = _x + string_width("> " + string_copy(_current_input, 1, _cursor_pos));
    if (current_time mod 1000 < 500) {
        draw_text(_cx, _base - _fh, "_");
    }
}

function nwbasic_browser_draw_interpreter_prompt(_metrics, _input_str) {
    if (!_metrics.is_browser) return;

    var _fh = _metrics.font_h;
    var _base = _metrics.prompt_base_gui;
    var _x = 16;
    var _top = _base - _metrics.input_strip_gui;

    draw_set_font(fnt_basic);
    draw_set_color(make_color_rgb(16, 16, 16));
    draw_rectangle(0, _top, _metrics.gw, _base, false);
    draw_set_color(make_color_rgb(40, 40, 40));
    draw_line(0, _top, _metrics.gw, _top);

    draw_set_color(global.basic_text_color);
    draw_text(_x, _base - _fh, _input_str);
}