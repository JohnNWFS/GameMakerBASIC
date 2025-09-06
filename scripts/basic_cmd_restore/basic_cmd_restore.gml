/// @func basic_cmd_restore(arg)
/// @desc RESTORE [@stream]    — reset the read pointer to the start of the stream.
///       No arg resets the default stream "".
function basic_cmd_restore(arg) {
    var s = strip_basic_remark(string_trim(arg));
    var stream_name = "";
    // Optional @name or bare name
    if (s != "") {
        if (string_char_at(s, 1) == "@") {
            stream_name = string_trim(string_copy(s, 2, string_length(s) - 1)); // drop '@'
        } else {
            stream_name = s; // bare stream name
        }
    }
	if (!ds_exists(global.data_streams, ds_type_map) || !ds_map_exists(global.data_streams, stream_name)) {
	    basic_syntax_error("RESTORE stream not found: " + stream_name, 
	        global.current_line_number, global.interpreter_current_stmt_index, "DATA_STREAM");
	    return;
	}
    var st = ds_map_find_value(global.data_streams, stream_name);
    st.ptr = 0;
    if (dbg_on(DBG_FLOW)) {
        var cnt = ds_list_size(st.list);
        if (dbg_on(DBG_FLOW)) show_debug_message("RESTORE: stream='" + stream_name + "' ptr=0 (size=" + string(cnt) + ")");
    }
}