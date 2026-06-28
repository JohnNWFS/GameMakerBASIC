/// obj_mobile_kb — on-screen keyboard for HTML5/browser builds.
/// Active in browser runtimes, including the Opera GX/GX.games export target.

kb_active  = (os_type == os_gxgames || os_browser != browser_not_a_browser);
kb_visible = false;  // hidden until user taps SHOW KB
kb_caps    = false;
kb_shift   = false;
KB_H       = 0;

if (kb_active) {
    var _sw = display_get_width();
    var _sh = display_get_height();
    if (_sw < 100) _sw = room_width;
    if (_sh < 100) _sh = room_height;
    display_set_gui_size(_sw, _sh);
}
