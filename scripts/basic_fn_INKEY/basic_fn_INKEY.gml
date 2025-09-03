/// === BASIC_fn_INKEY$ : dequeue 1 char for INKEY$ ===
/// Returns "" if queue empty. Safe to call from evaluator/command handler.
function BASIC_fn_INKEY() {
    if (!variable_global_exists("inkey_queue") || is_undefined(global.inkey_queue)) {
        global.inkey_queue = ds_queue_create();
    }
    if (ds_queue_size(global.inkey_queue) > 0) {
        var _ch = ds_queue_dequeue(global.inkey_queue);
        if (is_real(_ch)) _ch = chr(_ch);
        return string(_ch);
    }
    return "";
}