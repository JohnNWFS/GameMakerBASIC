// === 2. SECOND: Add this function to your Step event (or call it from Step) ===
function inkey_capture_keys() {
    // Debug: Show that capture is running
    if (keyboard_check_pressed(ord("A"))) {
        show_debug_message("INKEY$ CAPTURE: A key detected!");
    }
    
    // Scan for any newly pressed printable keys
    for (var key = 65; key <= 90; key++) { // A-Z first for testing
        if (keyboard_check_pressed(key)) {
            var ch = chr(key);
            show_debug_message("INKEY$ CAPTURE: Key " + string(key) + " pressed, char = '" + ch + "'");
            
            // Check if queue exists before adding
            if (!ds_exists(global.__inkey_queue, ds_type_queue)) {
                show_debug_message("INKEY$ CAPTURE ERROR: Queue doesn't exist!");
                global.__inkey_queue = ds_queue_create();
            }
            
            // Add to queue
            ds_queue_enqueue(global.__inkey_queue, ch);
            show_debug_message("INKEY$ CAPTURE: '" + ch + "' queued. Queue size now = " + string(ds_queue_size(global.__inkey_queue)));
            break; // Only capture one key per frame
        }
    }
}