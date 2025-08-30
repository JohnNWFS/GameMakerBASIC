// FILE: scripts/inkey_capture_keys.gml
// FUNCTION: inkey_capture_keys
// CHANGE: Expand key scan to ASCII 32-126, ensure queue initialization, add debug logs

function inkey_capture_keys() {
   // Initialize queue if not exists
   if (!ds_exists(global.__inkey_queue, ds_type_queue)) {
       global.__inkey_queue = ds_queue_create();
       if (dbg_on(DBG_FLOW)) show_debug_message("INKEY$ CAPTURE: Initialized global.__inkey_queue");
   }

   // Scan for printable keys (ASCII 32-126)
   for (var key = 32; key <= 126; key++) {
        if (keyboard_check_pressed(key)) {
            var ch = chr(key);
            if (dbg_on(DBG_FLOW)) show_debug_message("INKEY$ CAPTURE: Key " + string(key) + " pressed, char = '" + ch + "'");
           // Limit queue to 10 keys to prevent overflow
           if (ds_queue_size(global.__inkey_queue) < 10) {
                ds_queue_enqueue(global.__inkey_queue, ch);
                if (dbg_on(DBG_FLOW)) show_debug_message("INKEY$ CAPTURE: '" + ch + "' queued. Queue size now = " + string(ds_queue_size(global.__inkey_queue)));
           } else {
               if (dbg_on(DBG_FLOW)) show_debug_message("INKEY$ CAPTURE: Queue full (10 keys), skipping enqueue of '" + ch + "'");
           }
            break; // Only capture one key per frame
        }
    }
	
	  // Handle touch input for Android (map screen regions to W/A/S/D)
   if (os_type == os_android) {
       var w = display_get_width(), h = display_get_height();
       var region_w = w / 4; // Divide screen into four quadrants
       if (device_mouse_check_button_pressed(0, mb_left)) {
           var mx = device_mouse_x(0), my = device_mouse_y(0);
           var ch = "";
           if (my < h/2 && mx > w/4 && mx < 3*w/4) ch = "W"; // Top center: W
           else if (my > h/2 && mx > w/4 && mx < 3*w/4) ch = "S"; // Bottom center: S
           else if (mx < w/2 && my > h/4 && my < 3*h/4) ch = "A"; // Left center: A
           else if (mx > w/2 && my > h/4 && my < 3*h/4) ch = "D"; // Right center: D
           if (ch != "" && ds_queue_size(global.__inkey_queue) < 10) {
               ds_queue_enqueue(global.__inkey_queue, ch);
               if (dbg_on(DBG_FLOW)) show_debug_message("INKEY$ CAPTURE: Touch mapped to '" + ch + "', queued. Queue size now = " + string(ds_queue_size(global.__inkey_queue)));
           }
       }
   }	
}