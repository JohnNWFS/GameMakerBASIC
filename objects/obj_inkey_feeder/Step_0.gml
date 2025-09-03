/// @event obj_inkey_feeder/Step
if (os_browser != browser_not_a_browser) exit;
// === EARLY EXIT GUARDS ===
var _is_editor_room =
    (variable_global_exists("editor_return_room") && room == global.editor_return_room)
 || (variable_global_exists("editor_room") && room == global.editor_room)
 || (asset_get_index("rm_editor") != -1 && room == asset_get_index("rm_editor"))
 || instance_exists(obj_editor);

if (_is_editor_room) { keyboard_string = ""; exit; }
if (variable_global_exists("interpreter_running") && !global.interpreter_running) { keyboard_string = ""; exit; }

// === Ensure queue exists ===
if (!variable_global_exists("inkey_queue") || is_undefined(global.inkey_queue)) {
    global.inkey_queue = ds_queue_create();
}

// Capacity-aware enqueue (pass cap explicitly to avoid scope issues)
var _enq = function(val, cap) {
    while (ds_queue_size(global.inkey_queue) >= cap) ds_queue_dequeue(global.inkey_queue);
    ds_queue_enqueue(global.inkey_queue, val);
    if (dbg_on(DBG_PARSE)) {
        show_debug_message("##KEYFEED## ENQ='" + string(val) + "'"
            + " A1=" + string((is_string(val) && string_length(val)>=1) ? ord(string_char_at(val,1)) : -1)
            + " A2=" + string((is_string(val) && string_length(val)>=2) ? ord(string_char_at(val,2)) : -1));
    }
};
var _CAP = 128;

// === 1) DISPLAYABLE TEXT (letters, digits, punctuation, space, shifted forms) ===
if (keyboard_string != "") {
    var s = keyboard_string;
    var n = string_length(s);
    for (var i = 1; i <= n; i++) {
        _enq(string_char_at(s, i), _CAP);
    }
    keyboard_string = "";
}

// === 2) STANDARD CONTROL KEYS (single-char control codes) ===
if (keyboard_check_pressed(vk_enter))     _enq(chr(13), _CAP); // Enter
if (keyboard_check_pressed(vk_tab))       _enq(chr(9),  _CAP); // Tab
if (keyboard_check_pressed(vk_backspace)) _enq(chr(8),  _CAP); // Backspace
if (keyboard_check_pressed(vk_escape))    _enq(chr(27), _CAP); // Escape

// === 3) NUMPAD DIGITS (show up even if keyboard_string doesn't) ===
if (keyboard_check_pressed(vk_numpad0)) _enq("0", _CAP);
if (keyboard_check_pressed(vk_numpad1)) _enq("1", _CAP);
if (keyboard_check_pressed(vk_numpad2)) _enq("2", _CAP);
if (keyboard_check_pressed(vk_numpad3)) _enq("3", _CAP);
if (keyboard_check_pressed(vk_numpad4)) _enq("4", _CAP);
if (keyboard_check_pressed(vk_numpad5)) _enq("5", _CAP);
if (keyboard_check_pressed(vk_numpad6)) _enq("6", _CAP);
if (keyboard_check_pressed(vk_numpad7)) _enq("7", _CAP);
if (keyboard_check_pressed(vk_numpad8)) _enq("8", _CAP);
if (keyboard_check_pressed(vk_numpad9)) _enq("9", _CAP);

// === 4) EXTENDED KEYS (QBASIC style: CHR$(0)+CHR$(scan)) ===
var _enqueue_ext = function(sc) { _enq(chr(0) + chr(sc), _CAP); };
if (keyboard_check_pressed(vk_up))    _enqueue_ext(72); // Up
if (keyboard_check_pressed(vk_down))  _enqueue_ext(80); // Down
if (keyboard_check_pressed(vk_left))  _enqueue_ext(75); // Left
if (keyboard_check_pressed(vk_right)) _enqueue_ext(77); // Right

// Convenience WASD (uppercase; add lowercase if desired)
if (keyboard_check_pressed(ord("W"))) _enq("W", _CAP);
if (keyboard_check_pressed(ord("A"))) _enq("A", _CAP);
if (keyboard_check_pressed(ord("S"))) _enq("S", _CAP);
if (keyboard_check_pressed(ord("D"))) _enq("D", _CAP);
