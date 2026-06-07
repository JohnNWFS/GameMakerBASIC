/// pm_receive_text(text)
function pm_receive_text(_text) {
    var text_in = _text;
    if (is_undefined(text_in)) text_in = "";

   dbg_log(DBG_FLOW, "[pm_receive_text] got len=" + string(is_string(text_in) ? string_length(text_in) : -1));
    if (!is_string(text_in) || string_length(text_in) <= 0) return 0;

    var t = string(text_in);
    t = string_replace_all(t, "\r\n", "\n");
    t = string_replace_all(t, "\r",   "\n");

    var arr = string_split(t, "\n");
    var count = 0;
    var auto_num = 10;

    for (var i = 0; i < array_length(arr); i++) {
        var raw = string_trim(arr[i]);
        if (raw == "") continue;

        // Treat a leading '+' as decoration (strip it)
        if (string_length(raw) >= 2 && string_char_at(raw, 1) == "+") {
            raw = string_delete(raw, 1, 1);
            raw = string_trim(raw);
        }

        var sp   = string_pos(" ", raw);
        var head = (sp > 0) ? string_copy(raw, 1, sp - 1) : raw;

        if (string_length(head) > 0 && is_real(real(head))) {
            var num  = real(head);
            var code = (sp > 0) ? string_trim(string_copy(raw, sp + 1, string_length(raw))) : "";
            if (function_exists(paste_line)) paste_line(num, code);
        } else {
            if (function_exists(paste_line)) paste_line(auto_num, raw);
            auto_num += 10;
        }
        count++;
    }

    if (instance_exists(obj_paste_manager)) with (obj_paste_manager) {
        _pm_msg = "Imported " + string(count) + " line(s).";
        _pm_msg_ttl = 180;
        _pm_visible = false;
    }

   dbg_log(DBG_FLOW, "[pm_receive_text] imported lines=" + string(count));
    return count;
}
