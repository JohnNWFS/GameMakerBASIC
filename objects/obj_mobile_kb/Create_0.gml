/// obj_mobile_kb — on-screen keyboard for HTML5/browser builds.
/// Active in browser runtimes, including the Opera GX/GX.games export target.
/// Draws in the Draw GUI event so it overlays the HTML5 room variants.

kb_active  = (os_type == os_gxgames || os_browser != browser_not_a_browser);
kb_visible = kb_active;
kb_caps    = false;
kb_shift   = false;

// Height of the keyboard in GUI pixels (matches mobile_kb_draw row geometry)
KB_H = 6 * (38 + 2) + 6;  // 246
