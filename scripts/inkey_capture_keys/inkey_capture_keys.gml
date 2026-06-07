// FILE: scripts/inkey_capture_keys.gml
// FUNCTION: inkey_capture_keys
// PURPOSE: Feed the INKEY$ queue with a single key per frame.
// POLICY:
//   - Block capture while BASIC INPUT is active (awaiting_input = true)
//     UNLESS we are in an INKEY$ modal wait (inkey_waiting = true).
//   - During INKEY$ modal wait, keep capturing so the state machine can unblock.
//   - Otherwise capture printable ASCII (32..126) and (optionally) touch on Android.

function inkey_capture_keys() {
    /// inkey_capture_keys()

    // --- INPUT/INKEY arbitration guard -------------------------------------
    // Block capture only when INPUT is live and we are NOT in a modal INKEY wait.
    var _block_capture = false;

    if (variable_global_exists("awaiting_input") && global.awaiting_input) {
        var _inkey_waiting = (variable_global_exists("inkey_waiting") && global.inkey_waiting);
        if (!_inkey_waiting) {
            _block_capture = true;  // INPUT owns the keyboard; don't feed INKEY$ queue
        }
    }

    if (_block_capture) {
		//TEMPORARY: REMOVE WHEN TESTING INKEY$
        //dbg_log(DBG_FLOW, "INKEY$ CAPTURE: blocked (awaiting_input && !inkey_waiting)");
        exit;
    }
    // -----------------------------------------------------------------------

    // Initialize queue if not exists (use your current global.__inkey_queue)
    if (!variable_global_exists("__inkey_queue") || !ds_exists(global.__inkey_queue, ds_type_queue)) {
        global.__inkey_queue = ds_queue_create();
        dbg_log(DBG_FLOW, "INKEY$ CAPTURE: Initialized global.__inkey_queue");
    }

    // --- Scan for Enter, then one printable key (ASCII 32..126) per frame ---
    if (keyboard_check_pressed(vk_enter)) {
        var enter_ch = chr(13);
        dbg_log(DBG_FLOW, "INKEY$ CAPTURE: ENTER pressed");
        if (ds_queue_size(global.__inkey_queue) < 10) {
            ds_queue_enqueue(global.__inkey_queue, enter_ch);
            dbg_log(DBG_FLOW, "INKEY$ CAPTURE: ENTER queued. Size=" + string(ds_queue_size(global.__inkey_queue)));
        }
        exit;
    }

    for (var key = 32; key <= 126; key++) {
        if (keyboard_check_pressed(key)) {
            var ch = chr(key);
            dbg_log(DBG_FLOW, "INKEY$ CAPTURE: Key " + string(key) + " pressed, char='" + ch + "'");

            // Limit queue length to 10 (same policy as before)
            if (ds_queue_size(global.__inkey_queue) < 10) {
                ds_queue_enqueue(global.__inkey_queue, ch);
                dbg_log(DBG_FLOW, "INKEY$ CAPTURE: '" + ch + "' queued. Size=" + string(ds_queue_size(global.__inkey_queue)));
            } else {
                dbg_log(DBG_FLOW, "INKEY$ CAPTURE: Queue full (10), skipped '" + ch + "'");
            }
            break; // capture at most one key per frame
        }
    }

    // --- Optional: map simple touch regions to WASD on Android --------------
    if (os_type == os_android) {
        var w = display_get_width();
        var h = display_get_height();
        if (device_mouse_check_button_pressed(0, mb_left)) {
            var mx = device_mouse_x(0);
            var my = device_mouse_y(0);
            var ch2 = "";

            // Quadrant-ish mapping (center bands) → W/A/S/D
            if (my < h * 0.5 && mx > w * 0.25 && mx < w * 0.75) ch2 = "W";
            else if (my > h * 0.5 && mx > w * 0.25 && mx < w * 0.75) ch2 = "S";
            else if (mx < w * 0.5 && my > h * 0.25 && my < h * 0.75) ch2 = "A";
            else if (mx > w * 0.5 && my > h * 0.25 && my < h * 0.75) ch2 = "D";

            if (ch2 != "" && ds_queue_size(global.__inkey_queue) < 10) {
                ds_queue_enqueue(global.__inkey_queue, ch2);
                dbg_log(DBG_FLOW, "INKEY$ CAPTURE: Touch→'" + ch2 + "', queued. Size=" + string(ds_queue_size(global.__inkey_queue)));
            }
        }
    }
}
