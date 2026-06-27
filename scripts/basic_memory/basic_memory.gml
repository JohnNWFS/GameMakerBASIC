/// Safe destroy for any ds structure; no-op when id is invalid or already freed.
function basic_ds_release(_id) {
    if (!is_real(_id)) return;
    if (ds_exists(_id, ds_type_map)) ds_map_destroy(_id);
    else if (ds_exists(_id, ds_type_list)) ds_list_destroy(_id);
    else if (ds_exists(_id, ds_type_stack)) ds_stack_destroy(_id);
    else if (ds_exists(_id, ds_type_queue)) ds_queue_destroy(_id);
}

/// Release a named global ds_* if it was ever created (avoids unset-global reads).
function basic_memory_release_global(_name) {
    if (!variable_global_exists(_name)) return;
    basic_ds_release(variable_global_get(_name));
    variable_global_set(_name, undefined);
}

function basic_memory_ensure_map(_name) {
    if (!variable_global_exists(_name) || !ds_exists(variable_global_get(_name), ds_type_map)) {
        variable_global_set(_name, ds_map_create());
    }
    return variable_global_get(_name);
}

function basic_memory_ensure_list(_name) {
    if (!variable_global_exists(_name) || !ds_exists(variable_global_get(_name), ds_type_list)) {
        variable_global_set(_name, ds_list_create());
    }
    return variable_global_get(_name);
}

function basic_memory_ensure_stack(_name) {
    if (!variable_global_exists(_name) || !ds_exists(variable_global_get(_name), ds_type_stack)) {
        variable_global_set(_name, ds_stack_create());
    }
    return variable_global_get(_name);
}

function basic_memory_ensure_queue(_name) {
    if (!variable_global_exists(_name) || !ds_exists(variable_global_get(_name), ds_type_queue)) {
        variable_global_set(_name, ds_queue_create());
    }
    return variable_global_get(_name);
}

/// Destroy nested IF-block metadata maps and their elseif index lists.
function basic_memory_release_if_block_map() {
    if (!variable_global_exists("if_block_map") || !ds_exists(global.if_block_map, ds_type_map)) return;
    var _key = ds_map_find_first(global.if_block_map);
    while (!is_undefined(_key)) {
        var _info = global.if_block_map[? _key];
        if (is_real(_info) && ds_exists(_info, ds_type_map)) {
            var _elseif = _info[? "elseifIndices"];
            basic_ds_release(_elseif);
            basic_ds_release(_info);
        }
        _key = ds_map_find_next(global.if_block_map, _key);
    }
    basic_ds_release(global.if_block_map);
    global.if_block_map = undefined;
}

/// Destroy DATA stream lists held inside global.data_streams.
function basic_memory_release_data_streams() {
    if (!variable_global_exists("data_streams") || !ds_exists(global.data_streams, ds_type_map)) return;
    var _key = ds_map_find_first(global.data_streams);
    while (!is_undefined(_key)) {
        var _stream = global.data_streams[? _key];
        if (is_struct(_stream) && variable_struct_exists(_stream, "list")) {
            basic_ds_release(_stream.list);
        }
        _key = ds_map_find_next(global.data_streams, _key);
    }
    basic_ds_release(global.data_streams);
    global.data_streams = undefined;
}

/// Drain undo snapshots and destroy the undo stack.
function basic_memory_release_undo_stack() {
    if (!variable_global_exists("undo_stack") || !ds_exists(global.undo_stack, ds_type_list)) return;
    while (!ds_list_empty(global.undo_stack)) {
        var _snapshot = ds_list_find_value(global.undo_stack, 0);
        if (is_real(_snapshot) && ds_exists(_snapshot, ds_type_map)) {
            basic_ds_release(_snapshot[? "program_map"]);
            basic_ds_release(_snapshot[? "line_list"]);
            basic_ds_release(_snapshot[? "global.program_lines"]);
            basic_ds_release(_snapshot[? "global.line_numbers"]);
            basic_ds_release(_snapshot);
        }
        ds_list_delete(global.undo_stack, 0);
    }
    basic_ds_release(global.undo_stack);
    global.undo_stack = undefined;
}

/// Close open BASIC file channels. When _destroy_maps is false, maps are cleared for reuse.
function basic_memory_close_file_channels(_destroy_maps = false) {
    if (variable_global_exists("basic_file_handles") && ds_exists(global.basic_file_handles, ds_type_map)) {
        var _fkeys = ds_map_keys_to_array(global.basic_file_handles);
        for (var _fi = 0; _fi < array_length(_fkeys); _fi++) {
            file_text_close(global.basic_file_handles[? _fkeys[_fi]]);
        }
        if (_destroy_maps) {
            basic_ds_release(global.basic_file_handles);
            global.basic_file_handles = undefined;
            if (variable_global_exists("basic_file_modes")) {
                basic_ds_release(global.basic_file_modes);
                global.basic_file_modes = undefined;
            }
        } else {
            ds_map_clear(global.basic_file_handles);
            if (variable_global_exists("basic_file_modes") && ds_exists(global.basic_file_modes, ds_type_map)) {
                ds_map_clear(global.basic_file_modes);
            }
        }
    }
}

/// WHILE frames store per-loop ds_maps; release nested maps before clearing the store.
function basic_memory_release_while_meta(_destroy_parent = true) {
    if (!variable_global_exists("while_meta") || !ds_exists(global.while_meta, ds_type_map)) {
        if (_destroy_parent) global.while_meta = undefined;
        return;
    }
    var _keys = ds_map_keys_to_array(global.while_meta);
    for (var _wi = 0; _wi < array_length(_keys); _wi++) {
        basic_ds_release(global.while_meta[? _keys[_wi]]);
    }
    if (_destroy_parent) {
        basic_ds_release(global.while_meta);
        global.while_meta = undefined;
    } else {
        ds_map_clear(global.while_meta);
    }
}

function basic_memory_release_help_snapshots() {
    if (variable_global_exists("help_snapshot_lines")) {
        basic_ds_release(global.help_snapshot_lines);
        global.help_snapshot_lines = undefined;
    }
    if (variable_global_exists("help_snapshot_nums")) {
        basic_ds_release(global.help_snapshot_nums);
        global.help_snapshot_nums = undefined;
    }
}

function basic_memory_release_html_dir_files() {
    if (!variable_global_exists("html_dir_files") || !ds_exists(global.html_dir_files, ds_type_list)) return;
    var _n = ds_list_size(global.html_dir_files);
    for (var _hi = 0; _hi < _n; _hi++) {
        basic_ds_release(global.html_dir_files[| _hi]);
    }
    basic_ds_release(global.html_dir_files);
    global.html_dir_files = undefined;
}

function basic_memory_release_basic_arrays() {
    if (!variable_global_exists("basic_arrays") || !ds_exists(global.basic_arrays, ds_type_map)) return;
    var _arr_keys = ds_map_keys_to_array(global.basic_arrays);
    for (var _aki = 0; _aki < array_length(_arr_keys); _aki++) {
        basic_array_release_storage(global.basic_arrays[? _arr_keys[_aki]]);
    }
    basic_ds_release(global.basic_arrays);
    global.basic_arrays = undefined;
}

function basic_memory_release_beep_audio() {
    if (variable_global_exists("beep_instance") && is_real(global.beep_instance) && global.beep_instance >= 0) {
        if (audio_is_playing(global.beep_instance)) audio_stop_sound(global.beep_instance);
        global.beep_instance = -1;
    }
    if (variable_global_exists("beep_generated_sound") && !is_undefined(global.beep_generated_sound) && global.beep_generated_sound != -1) {
        audio_free_buffer_sound(global.beep_generated_sound);
        global.beep_generated_sound = -1;
    }
    if (variable_global_exists("beep_generated_buffer") && !is_undefined(global.beep_generated_buffer) && global.beep_generated_buffer != -1) {
        buffer_delete(global.beep_generated_buffer);
        global.beep_generated_buffer = -1;
    }
    if (variable_global_exists("beep_seq_queue")) {
        basic_ds_release(global.beep_seq_queue);
        global.beep_seq_queue = undefined;
    }
}

/// Per-RUN reset: vars, arrays, control stacks, files, WHILE metadata, input queue.
function basic_memory_runtime_reset() {
    global.basic_variables = {};

    if (!variable_global_exists("basic_arrays") || !ds_exists(global.basic_arrays, ds_type_map)) {
        global.basic_arrays = ds_map_create();
    } else {
        var _arr_keys = ds_map_keys_to_array(global.basic_arrays);
        for (var _aki = 0; _aki < array_length(_arr_keys); _aki++) {
            basic_array_release_storage(global.basic_arrays[? _arr_keys[_aki]]);
        }
        ds_map_clear(global.basic_arrays);
    }

    if (!variable_global_exists("basic_array_dims") || !ds_exists(global.basic_array_dims, ds_type_map)) {
        global.basic_array_dims = ds_map_create();
    } else {
        ds_map_clear(global.basic_array_dims);
    }

    basic_memory_ensure_stack("gosub_stack");
    ds_stack_clear(global.gosub_stack);
    basic_memory_ensure_stack("for_stack");
    ds_stack_clear(global.for_stack);
    basic_memory_ensure_stack("while_stack");
    ds_stack_clear(global.while_stack);
    basic_memory_ensure_stack("if_stack");
    ds_stack_clear(global.if_stack);

    basic_memory_close_file_channels(false);
    basic_memory_release_while_meta(false);

    if (variable_global_exists("__inkey_queue") && ds_exists(global.__inkey_queue, ds_type_queue)) {
        ds_queue_clear(global.__inkey_queue);
    }
    if (variable_global_exists("beep_seq_queue") && ds_exists(global.beep_seq_queue, ds_type_queue)) {
        ds_queue_clear(global.beep_seq_queue);
    }

    global.option_base = 1;
    basic_peek_poke_reset();
    global.draw_pen_x     = 0;
    global.draw_pen_y     = 0;
    global.draw_scale     = 4;
    global.draw_angle     = 0;
    global.draw_color     = c_white;
    mode1_view_reset();
    dbg_log(DBG_FLOW, "MEMORY: runtime reset (vars/arrays/stacks/files/while_meta)");
}

/// Virtual 64K byte space for PEEK/POKE (address 0..65535).
function basic_peek_poke_ensure() {
    if (!variable_global_exists("peek_poke_mem") || !ds_exists(global.peek_poke_mem, ds_type_map)) {
        global.peek_poke_mem = ds_map_create();
    }
}

function basic_peek_poke_reset() {
    if (variable_global_exists("peek_poke_mem") && ds_exists(global.peek_poke_mem, ds_type_map)) {
        ds_map_clear(global.peek_poke_mem);
    }
}

function basic_peek(_addr) {
    basic_peek_poke_ensure();
    var addr = floor(_addr);
    if (addr < 0 || addr > 65535) return 0;
    if (!ds_map_exists(global.peek_poke_mem, addr)) return 0;
    return ds_map_find_value(global.peek_poke_mem, addr) & 255;
}

function basic_poke(_addr, _val) {
    basic_peek_poke_ensure();
    var addr = floor(_addr);
    if (addr < 0 || addr > 65535) return;
    ds_map_set(global.peek_poke_mem, addr, floor(_val) & 255);
}

/// POKE addr, value
function basic_cmd_poke(arg) {
    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "POKE", 2, 2, "addr,value")) return;
    var a_arg = basic_eval_number_arg(args[0], "POKE", "addr");
    var v_arg = basic_eval_number_arg(args[1], "POKE", "value");
    if (!a_arg.ok || !v_arg.ok) return;
    basic_poke(a_arg.value, v_arg.value);
    dbg_log(DBG_FLOW, "POKE " + string(floor(a_arg.value)) + " = " + string(floor(v_arg.value) & 255));
}

/// Resolve a PEEK-map save/load path under Documents/BasicInterpreter.
function basic_peek_resolve_filepath(_expr) {
    var save_dir = get_save_directory();
    if (save_dir == "") {
        basic_syntax_error("BSAVE/BLOAD not available on this platform",
            global.current_line_number, global.interpreter_current_stmt_index, "BSAVE_PLATFORM");
        return "";
    }
    if (!directory_exists(save_dir)) directory_create(save_dir);

    var fname = string(basic_evaluate_expression_v2(string_trim(_expr)));
    if (string_length(fname) <= 0) fname = "memory.nwmem";
    if (string_pos(".", fname) <= 0) fname += ".nwmem";
    return save_dir + fname;
}

function __peek_bin_write_u32(_fh, _val) {
    var v = floor(_val);
    if (v < 0) v = 0;
    file_bin_write_byte(_fh, v & 255);
    file_bin_write_byte(_fh, (v >> 8) & 255);
    file_bin_write_byte(_fh, (v >> 16) & 255);
    file_bin_write_byte(_fh, (v >> 24) & 255);
}

function __peek_bin_read_u32(_fh) {
    var b0 = file_bin_read_byte(_fh);
    var b1 = file_bin_read_byte(_fh);
    var b2 = file_bin_read_byte(_fh);
    var b3 = file_bin_read_byte(_fh);
    return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
}

function __peek_bin_read_magic(_fh) {
    var s = "";
    for (var i = 0; i < 7; i++) s += chr(file_bin_read_byte(_fh));
    return s;
}

/// BSAVE "file", addr, length — write virtual PEEK bytes to disk (.nwmem).
function basic_cmd_bsave(arg) {
    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "BSAVE", 3, 3, "filename,addr,length")) return;

    var path = basic_peek_resolve_filepath(args[0]);
    if (path == "") return;

    var addr_arg = basic_eval_number_arg(args[1], "BSAVE", "addr");
    var len_arg  = basic_eval_number_arg(args[2], "BSAVE", "length");
    if (!addr_arg.ok || !len_arg.ok) return;

    var start = floor(addr_arg.value);
    var len   = floor(len_arg.value);
    if (start < 0 || start > 65535 || len < 0 || len > 65536 || (start + len) > 65536) {
        basic_syntax_error("BSAVE range must stay within addresses 0..65535",
            global.current_line_number, global.interpreter_current_stmt_index, "BSAVE_RANGE");
        return;
    }

    basic_peek_poke_ensure();
    var fh = file_bin_open(path, 2);
    if (fh < 0) {
        basic_syntax_error("BSAVE failed: " + path,
            global.current_line_number, global.interpreter_current_stmt_index, "BSAVE_FAILED");
        return;
    }

    var _magic = "NWBMEM1";
    for (var _mi = 1; _mi <= 7; _mi++) {
        file_bin_write_byte(fh, ord(string_char_at(_magic, _mi)));
    }
    __peek_bin_write_u32(fh, start);
    __peek_bin_write_u32(fh, len);
    for (var i = 0; i < len; i++) {
        file_bin_write_byte(fh, basic_peek(start + i));
    }
    file_bin_close(fh);
    dbg_log(DBG_FLOW, "BSAVE: " + path + " start=" + string(start) + " len=" + string(len));
}

/// BLOAD "file", addr — load .nwmem payload bytes into the virtual map at addr.
function basic_cmd_bload(arg) {
    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "BLOAD", 2, 2, "filename,addr")) return;

    var path = basic_peek_resolve_filepath(args[0]);
    if (path == "") return;

    if (!file_exists(path)) {
        basic_syntax_error("BLOAD missing file: " + path,
            global.current_line_number, global.interpreter_current_stmt_index, "BLOAD_MISSING");
        return;
    }

    var addr_arg = basic_eval_number_arg(args[1], "BLOAD", "addr");
    if (!addr_arg.ok) return;
    var load_addr = floor(addr_arg.value);
    if (load_addr < 0 || load_addr > 65535) {
        basic_syntax_error("BLOAD addr must be 0..65535",
            global.current_line_number, global.interpreter_current_stmt_index, "BLOAD_RANGE");
        return;
    }

    var fh = file_bin_open(path, 0);
    if (fh < 0) {
        basic_syntax_error("BLOAD failed: " + path,
            global.current_line_number, global.interpreter_current_stmt_index, "BLOAD_FAILED");
        return;
    }

    var magic = __peek_bin_read_magic(fh);
    if (magic != "NWBMEM1") {
        file_bin_close(fh);
        basic_syntax_error("BLOAD: not a NW-BASIC memory file (expected NWBMEM1)",
            global.current_line_number, global.interpreter_current_stmt_index, "BLOAD_FORMAT");
        return;
    }

    var _file_start = __peek_bin_read_u32(fh);
    var _file_len   = __peek_bin_read_u32(fh);
    if (_file_len < 0 || _file_len > 65536 || (load_addr + _file_len) > 65536) {
        file_bin_close(fh);
        basic_syntax_error("BLOAD: file length does not fit at addr " + string(load_addr),
            global.current_line_number, global.interpreter_current_stmt_index, "BLOAD_RANGE");
        return;
    }

    var _expected = 15 + _file_len;
    if (file_bin_size(fh) < _expected) {
        file_bin_close(fh);
        basic_syntax_error("BLOAD: file too short (expected " + string(_expected) + " bytes)",
            global.current_line_number, global.interpreter_current_stmt_index, "BLOAD_FORMAT");
        return;
    }

    basic_peek_poke_ensure();
    for (var i = 0; i < _file_len; i++) {
        basic_poke(load_addr + i, file_bin_read_byte(fh));
    }
    file_bin_close(fh);
    dbg_log(DBG_FLOW, "BLOAD: " + path + " -> addr=" + string(load_addr)
        + " len=" + string(_file_len) + " (file_start=" + string(_file_start) + ")");
}

/// Game-end teardown for all interpreter/editor ds structures.
function basic_memory_shutdown() {
    global.basic_variables = undefined;
    global.colors = undefined;

    basic_memory_release_global("program_map");
    basic_memory_release_global("program_lines");
    basic_memory_release_global("line_index_map");
    basic_memory_release_global("basic_program");

    basic_memory_release_if_block_map();
    basic_memory_release_global("mode_rooms");
    basic_memory_release_global("font_sheets");
    basic_memory_release_global("custom_tile_defs");
    basic_memory_release_global("config");

    basic_memory_release_data_streams();
    basic_memory_release_basic_arrays();
    basic_memory_release_global("basic_array_dims");

    basic_memory_release_global("line_list");
    basic_memory_release_global("line_numbers");
    basic_memory_release_global("basic_line_numbers");

    basic_memory_release_undo_stack();
    basic_memory_release_global("output_lines");
    basic_memory_release_global("output_colors");
    basic_memory_release_global("input_history");

    basic_memory_release_global("gosub_stack");
    basic_memory_release_global("for_stack");
    basic_memory_release_global("while_stack");
    basic_memory_release_global("if_stack");

    basic_memory_close_file_channels(true);
    basic_memory_release_global("gosub_targets");
    basic_memory_release_while_meta(true);

    basic_memory_release_global("help_topics");
    basic_memory_release_help_snapshots();
    basic_memory_release_html_dir_files();
    basic_memory_release_global("http_tags");

    basic_memory_release_global("__inkey_queue");
    basic_memory_release_beep_audio();

    global.print_line_buffer = "";
    global.editor_spawned = false;
    dbg_log(DBG_FLOW, "MEMORY: shutdown complete");
}