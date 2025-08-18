/// @script basic_current_line_no
function basic_current_line_no() {
    if (ds_exists(global.line_list, ds_type_list)) {
        var idx = global.interpreter_current_line_index;
        if (is_real(idx) && idx >= 0 && idx < ds_list_size(global.line_list)) {
            return global.line_list[| idx];
        }
    }
    return is_undefined(global.current_line_number) ? -1 : global.current_line_number;
}