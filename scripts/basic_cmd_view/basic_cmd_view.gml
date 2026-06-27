/// VIEW col, row, w, h  — clip MODE 2 drawing to a viewport
/// VIEW OFF             — restore full-grid drawing

function basic_cmd_view(arg) {
    if (global.current_mode != 2) {
        dbg_log(DBG_FLOW, "VIEW: only available in MODE 2 tile graphics");
        return;
    }

    var trimmed = string_upper(string_trim(arg));
    if (trimmed == "OFF" || trimmed == "") {
        mode1_view_off();
        return;
    }

    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "VIEW", 4, 4, "col,row,w,h")) return;

    var x_arg = basic_eval_int_arg(args[0], "VIEW", "col");
    var y_arg = basic_eval_int_arg(args[1], "VIEW", "row");
    var w_arg = basic_eval_int_arg(args[2], "VIEW", "w");
    var h_arg = basic_eval_int_arg(args[3], "VIEW", "h");
    if (!x_arg.ok || !y_arg.ok || !w_arg.ok || !h_arg.ok) return;

    mode1_view_set(x_arg.value, y_arg.value, w_arg.value, h_arg.value);
}