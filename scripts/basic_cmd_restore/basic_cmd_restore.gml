/// @func basic_cmd_restore(arg)
/// @desc RESTORE [@stream]    — reset the read pointer to the start of the stream.
///       No arg resets the default stream "".
function basic_cmd_restore(arg) {
    var s = strip_basic_remark(string_trim(arg));
    var stream_name = "";

    // Optional @name
    if (s != "" && string_char_at(s, 1) == "@") {
        stream_name = string_trim(string_copy(s, 2, string_length(s) - 1)); // drop '@'
    }

    if (!ds_exists(global.data_streams, ds_type_map) || !ds_map_exists(global.data_streams, stream_name)) {
        show_debug_message("?RESTORE ERROR: stream '" + stream_name + "' not found");
        return;
    }

    var st = ds_map_find_value(global.data_streams, stream_name);
    st.ptr = 0;

    if (dbg_on(DBG_FLOW)) {
        var cnt = ds_list_size(st.list);
        show_debug_message("RESTORE: stream='" + stream_name + "' ptr=0 (size=" + string(cnt) + ")");
    }
}
