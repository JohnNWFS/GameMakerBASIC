/// basic_cmd_close(arg)
/// Syntax: CLOSE #n   or   CLOSE   (closes all open channels)
function basic_cmd_close(arg) {
    arg = string_trim(arg);

    if (arg == "") {
        // Close all open channels
        var _keys = ds_map_keys_to_array(global.basic_file_handles);
        for (var _i = 0; _i < array_length(_keys); _i++) {
            file_text_close(global.basic_file_handles[? _keys[_i]]);
        }
        ds_map_clear(global.basic_file_handles);
        ds_map_clear(global.basic_file_modes);
        dbg_log(DBG_FLOW, "CLOSE: closed all channels");
    } else {
        // Strip leading #
        if (string_length(arg) > 0 && string_char_at(arg, 1) == "#") {
            arg = string_copy(arg, 2, string_length(arg) - 1);
        }
        var _chan_arg = basic_eval_int_arg(arg, "CLOSE", "channel");
        if (!_chan_arg.ok) return;
        var _chan = _chan_arg.value;
        if (ds_map_exists(global.basic_file_handles, _chan)) {
            file_text_close(global.basic_file_handles[? _chan]);
            ds_map_delete(global.basic_file_handles, _chan);
            ds_map_delete(global.basic_file_modes, _chan);
            dbg_log(DBG_FLOW, "CLOSE: closed channel " + string(_chan));
        }
    }
}
