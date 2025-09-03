/// pm_paste_handler(data, name, type)
function pm_paste_handler(_data, _name, _type) {
    // Text if name is undefined
    if (is_undefined(_name)) {
        if (is_string(_data) && string_length(_data) > 0) {
            pm_receive_text(_data);
        } else {
            show_debug_message("[PASTE] Text handler: empty or non-string payload.");
        }
    } else {
        // You pasted a file; ignore for now (or handle base64 here)
        show_debug_message("[PASTE] File paste ignored: " + string(_name) + " (" + string(_type) + ")");
    }

    // Unbind so we don't keep intercepting Ctrl/Cmd+V forever
    var _bind = asset_get_index("browser_paste_bind");
    if (_bind != -1) script_execute(_bind);
}
