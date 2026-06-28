/// Draw GUI — browser-only input strip (screen pixels, above on-screen keyboard).
if (room != rm_editor) exit;
if (!nwbasic_is_browser_runtime()) exit;
if (global.screen_edit_mode || global.tile_edit_mode) exit;
if (showing_dir_overlay) exit;

var _metrics = nwbasic_browser_chrome_metrics(string_height("A"));
nwbasic_browser_draw_editor_prompt(_metrics, current_input, cursor_pos, message_text);