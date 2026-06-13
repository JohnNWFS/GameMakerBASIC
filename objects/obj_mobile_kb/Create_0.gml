/// obj_mobile_kb — on-screen keyboard for HTML5/browser builds.
/// Active in browser runtimes, including the Opera GX/GX.games export target.

kb_active  = (os_type == os_gxgames || os_browser != browser_not_a_browser);
kb_visible = kb_active;
kb_caps    = false;
kb_shift   = false;
KB_H       = 0;  // keyboard height in GUI (screen) pixels; 0 when keyboard is hidden

if (kb_active) {
    var _sw = display_get_width();
    var _sh = display_get_height();
    // Fall back to room dimensions if display query returns 0 before canvas is ready
    if (_sw < 100) _sw = room_width;
    if (_sh < 100) _sh = room_height;
    // Set the GUI layer to actual screen pixels so the keyboard renders full-size
    display_set_gui_size(_sw, _sh);
    // Row height: ~7% of screen height, minimum 48px (finger-friendly tap target)
    var _row_h = max(48, floor(_sh * 0.07));
    KB_H = 6 * (_row_h + 2) + 6;
}
