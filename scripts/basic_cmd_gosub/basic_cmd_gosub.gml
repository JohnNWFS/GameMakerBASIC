/// @script basic_cmd_gosub
/// @description Handle GOSUB line-number jumps, stripping inline comments
function basic_cmd_gosub(arg) {
    // 1) Strip off anything after a ':' (inline comment or extra code)
    var raw = string_trim(arg);
    var colonPos = string_pos(":", raw);
    if (colonPos > 0) {
        raw = string_trim(string_copy(raw, 1, colonPos - 1));
        if (dbg_on(DBG_FLOW)) show_debug_message("GOSUB: Stripped argument to '" + raw + "'");
    }

    // 2) Parse the target line number
    var target = real(raw);
    if (dbg_on(DBG_FLOW)) show_debug_message("GOSUB: Target line requested: " + string(target));

    // 3) Push return point (the *next* line index) onto the gosub stack
    var return_index = line_index + 1;
    ds_stack_push(global.gosub_stack, return_index);
    if (dbg_on(DBG_FLOW)) show_debug_message("GOSUB: Pushed return index: " + string(return_index));

    // 4) Find the target in the sorted line_list
    global.interpreter_next_line = -1;
    var listSize = ds_list_size(global.line_list);
    for (var i = 0; i < listSize; i++) {
        if (ds_list_find_value(global.line_list, i) == target) {
            global.interpreter_next_line = i;
            if (dbg_on(DBG_FLOW))  show_debug_message("GOSUB: Found target line at index " + string(i));
            break;
        }
    }

    // 5) Error if not found
    if (global.interpreter_next_line == -1) {
        if (dbg_on(DBG_FLOW)) show_debug_message("GOSUB: ERROR — Target line " + string(target) + " not found");
        basic_show_error_message("GOSUB target line not found: " + string(target));
        global.interpreter_running = false;
    }
}
