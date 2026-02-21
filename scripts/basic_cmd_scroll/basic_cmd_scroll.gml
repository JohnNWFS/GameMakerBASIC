/// MODE 1 COMMAND
/// @function basic_cmd_scroll(arg)
/// @description SCROLL [direction,] amount  -- direction defaults to UP when omitted or numeric-first.
function basic_cmd_scroll(arg) {
    if (global.current_mode < 1) {
        if (dbg_on(DBG_FLOW)) show_debug_message("SCROLL: Not implemented in text mode");
        return;
    }
    
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("SCROLL: No grid object found");
        return;
    }

    // Defaults
    var _direction = "UP";
    var amount     = 1;

    var s = string_trim(arg);
    if (s != "") {
        var args = basic_parse_csv_args(s);

        if (array_length(args) == 1) {
            var a0 = string_trim(args[0]);

            // If single arg is numeric (or evaluates numeric), treat as amount; direction stays UP
            var treat_as_amount = false;
            if (is_numeric_string(a0)) {
                amount = max(1, floor(real(a0)));
                treat_as_amount = true;
            } else {
                var v = basic_evaluate_expression_v2(a0);
                if (is_real(v)) {
                    amount = max(1, floor(real(v)));
                    treat_as_amount = true;
                }
            }

            if (!treat_as_amount) {
                // Otherwise treat it as a direction token (quotes allowed)
                _direction = string_upper(a0);
                if (string_length(_direction) >= 2) {
                    var q = string_char_at(_direction, 1);
                    if (q == "\"" || q == "'") {
                        _direction = string_copy(_direction, 2, string_length(_direction) - 2);
                        _direction = string_upper(_direction);
                    }
                }
            }
        }
        else if (array_length(args) >= 2) {
            // direction, amount (direction may be quoted)
            _direction = string_upper(string_trim(args[0]));
            if (string_length(_direction) >= 2) {
                var q0 = string_char_at(_direction, 1);
                if (q0 == "\"" || q0 == "'") {
                    _direction = string_copy(_direction, 2, string_length(_direction) - 2);
                    _direction = string_upper(_direction);
                }
            }
            amount = max(1, floor(real(basic_evaluate_expression_v2(string_trim(args[1])))));
        }
    }

    // Hand off to grid scroller (current signature)
    mode1_scroll_grid(grid_obj, _direction, amount);
    if (dbg_on(DBG_FLOW)) show_debug_message("SCROLL: " + _direction + " by " + string(amount));
}
