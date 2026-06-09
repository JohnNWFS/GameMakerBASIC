/// MODE 2 TILE COMMANDS
/// @desc BOX/FILL/HLINE/VLINE helpers for the tile grid.

function __basic_tile_parse_draw_args(arg, min_args, command_name) {
    var args = basic_parse_csv_args(arg);
    if (array_length(args) < min_args) {
        basic_arg_error(command_name, "not enough arguments");
        return undefined;
    }
    return args;
}

function __basic_tile_plot(_x, _y, _char, _fg, _bg) {
    var grid_obj = instance_find(obj_mode1_grid, 0);
    if (!instance_exists(grid_obj)) return;

    if (_x < 0 || _y < 0 || _x >= grid_obj.grid_cols || _y >= grid_obj.grid_rows) return;
    mode1_grid_set(_x, _y, _char, _fg, _bg);
}

function __basic_tile_colors(args, start_index) {
    var fg = (array_length(args) > start_index) ? basic_parse_color(string_trim(args[start_index])) : undefined;
    var bg = (array_length(args) > start_index + 1) ? basic_parse_color(string_trim(args[start_index + 1])) : undefined;
    return { fg: fg, bg: bg };
}

function basic_cmd_tile_box(arg) {
    if (global.current_mode != 2) {
        dbg_log(DBG_FLOW, "BOX: only available in MODE 2 tile graphics");
        return;
    }

    var args = __basic_tile_parse_draw_args(arg, 5, "BOX");
    if (is_undefined(args)) return;

    var x1_arg = basic_eval_int_arg(args[0], "BOX", "x1");
    var y1_arg = basic_eval_int_arg(args[1], "BOX", "y1");
    var x2_arg = basic_eval_int_arg(args[2], "BOX", "x2");
    var y2_arg = basic_eval_int_arg(args[3], "BOX", "y2");
    var ch_arg = basic_eval_int_arg(args[4], "BOX", "char");
    if (!x1_arg.ok || !y1_arg.ok || !x2_arg.ok || !y2_arg.ok || !ch_arg.ok) return;
    var x1 = x1_arg.value;
    var y1 = y1_arg.value;
    var x2 = x2_arg.value;
    var y2 = y2_arg.value;
    var ch = ch_arg.value;
    var colors = __basic_tile_colors(args, 5);

    var left = min(x1, x2);
    var right = max(x1, x2);
    var top = min(y1, y2);
    var bottom = max(y1, y2);

    for (var tx = left; tx <= right; tx++) {
        __basic_tile_plot(tx, top, ch, colors.fg, colors.bg);
        __basic_tile_plot(tx, bottom, ch, colors.fg, colors.bg);
    }
    for (var ty = top + 1; ty <= bottom - 1; ty++) {
        __basic_tile_plot(left, ty, ch, colors.fg, colors.bg);
        __basic_tile_plot(right, ty, ch, colors.fg, colors.bg);
    }
}

function basic_cmd_tile_fill(arg) {
    if (global.current_mode != 2) {
        dbg_log(DBG_FLOW, "FILL: only available in MODE 2 tile graphics");
        return;
    }

    var args = __basic_tile_parse_draw_args(arg, 5, "FILL");
    if (is_undefined(args)) return;

    var x1_arg = basic_eval_int_arg(args[0], "FILL", "x1");
    var y1_arg = basic_eval_int_arg(args[1], "FILL", "y1");
    var x2_arg = basic_eval_int_arg(args[2], "FILL", "x2");
    var y2_arg = basic_eval_int_arg(args[3], "FILL", "y2");
    var ch_arg = basic_eval_int_arg(args[4], "FILL", "char");
    if (!x1_arg.ok || !y1_arg.ok || !x2_arg.ok || !y2_arg.ok || !ch_arg.ok) return;
    var x1 = x1_arg.value;
    var y1 = y1_arg.value;
    var x2 = x2_arg.value;
    var y2 = y2_arg.value;
    var ch = ch_arg.value;
    var colors = __basic_tile_colors(args, 5);

    for (var ty = min(y1, y2); ty <= max(y1, y2); ty++) {
        for (var tx = min(x1, x2); tx <= max(x1, x2); tx++) {
            __basic_tile_plot(tx, ty, ch, colors.fg, colors.bg);
        }
    }
}

function basic_cmd_tile_hline(arg) {
    if (global.current_mode != 2) {
        dbg_log(DBG_FLOW, "HLINE: only available in MODE 2 tile graphics");
        return;
    }

    var args = __basic_tile_parse_draw_args(arg, 4, "HLINE");
    if (is_undefined(args)) return;

    var x1_arg = basic_eval_int_arg(args[0], "HLINE", "x1");
    var x2_arg = basic_eval_int_arg(args[1], "HLINE", "x2");
    var line_y_arg = basic_eval_int_arg(args[2], "HLINE", "y");
    var ch_arg = basic_eval_int_arg(args[3], "HLINE", "char");
    if (!x1_arg.ok || !x2_arg.ok || !line_y_arg.ok || !ch_arg.ok) return;
    var x1 = x1_arg.value;
    var x2 = x2_arg.value;
    var line_y = line_y_arg.value;
    var ch = ch_arg.value;
    var colors = __basic_tile_colors(args, 4);

    for (var tx = min(x1, x2); tx <= max(x1, x2); tx++) {
        __basic_tile_plot(tx, line_y, ch, colors.fg, colors.bg);
    }
}

function basic_cmd_tile_vline(arg) {
    if (global.current_mode != 2) {
        dbg_log(DBG_FLOW, "VLINE: only available in MODE 2 tile graphics");
        return;
    }

    var args = __basic_tile_parse_draw_args(arg, 4, "VLINE");
    if (is_undefined(args)) return;

    var line_x_arg = basic_eval_int_arg(args[0], "VLINE", "x");
    var y1_arg = basic_eval_int_arg(args[1], "VLINE", "y1");
    var y2_arg = basic_eval_int_arg(args[2], "VLINE", "y2");
    var ch_arg = basic_eval_int_arg(args[3], "VLINE", "char");
    if (!line_x_arg.ok || !y1_arg.ok || !y2_arg.ok || !ch_arg.ok) return;
    var line_x = line_x_arg.value;
    var y1 = y1_arg.value;
    var y2 = y2_arg.value;
    var ch = ch_arg.value;
    var colors = __basic_tile_colors(args, 4);

    for (var ty = min(y1, y2); ty <= max(y1, y2); ty++) {
        __basic_tile_plot(line_x, ty, ch, colors.fg, colors.bg);
    }
}
