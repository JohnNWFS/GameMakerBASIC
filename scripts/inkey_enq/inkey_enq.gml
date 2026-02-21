/// @function inkey_enq(val, cap)
function inkey_enq(val, cap) {
    if (!variable_global_exists("inkey_queue") || !ds_exists(global.inkey_queue, ds_type_queue)) {
        global.inkey_queue = ds_queue_create();
    }
    while (ds_queue_size(global.inkey_queue) >= cap) ds_queue_dequeue(global.inkey_queue);
    ds_queue_enqueue(global.inkey_queue, val);

    if (variable_global_exists("DBG_PARSE") && dbg_on(DBG_PARSE)) {
        var s  = string(val);
        var a1 = (is_string(s) && string_length(s)>=1) ? ord(string_char_at(s,1)) : -1;
        var a2 = (is_string(s) && string_length(s)>=2) ? ord(string_char_at(s,2)) : -1;
        show_debug_message("##KEYFEED## ENQ='" + s + "' A1=" + string(a1) + " A2=" + string(a2));
    }
}