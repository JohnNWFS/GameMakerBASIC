/// MODE 2 TILE COMMANDS
/// @desc BOX/FILL/HLINE/VLINE helpers for the tile grid.

function __basic_tile_parse_draw_args(arg, min_args, command_name) {
    var args = basic_parse_csv_args(arg);
    if (array_length(args) < min_args) {
        dbg_log(DBG_FLOW, command_name + ": not enough arguments");
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

    var x1 = floor(real(basic_evaluate_expression_v2(string_trim(args[0]))));
    var y1 = floor(real(basic_evaluate_expression_v2(string_trim(args[1]))));
    var x2 = floor(real(basic_evaluate_expression_v2(string_trim(args[2]))));
    var y2 = floor(real(basic_evaluate_expression_v2(string_trim(args[3]))));
    var ch = floor(real(basic_evaluate_expression_v2(string_trim(args[4]))));
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

    var x1 = floor(real(basic_evaluate_expression_v2(string_trim(args[0]))));
    var y1 = floor(real(basic_evaluate_expression_v2(string_trim(args[1]))));
    var x2 = floor(real(basic_evaluate_expression_v2(string_trim(args[2]))));
    var y2 = floor(real(basic_evaluate_expression_v2(string_trim(args[3]))));
    var ch = floor(real(basic_evaluate_expression_v2(string_trim(args[4]))));
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

    var x1 = floor(real(basic_evaluate_expression_v2(string_trim(args[0]))));
    var x2 = floor(real(basic_evaluate_expression_v2(string_trim(args[1]))));
    var line_y = floor(real(basic_evaluate_expression_v2(string_trim(args[2]))));
    var ch = floor(real(basic_evaluate_expression_v2(string_trim(args[3]))));
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

    var line_x = floor(real(basic_evaluate_expression_v2(string_trim(args[0]))));
    var y1 = floor(real(basic_evaluate_expression_v2(string_trim(args[1]))));
    var y2 = floor(real(basic_evaluate_expression_v2(string_trim(args[2]))));
    var ch = floor(real(basic_evaluate_expression_v2(string_trim(args[3]))));
    var colors = __basic_tile_colors(args, 4);

    for (var ty = min(y1, y2); ty <= max(y1, y2); ty++) {
        __basic_tile_plot(line_x, ty, ch, colors.fg, colors.bg);
    }
}
