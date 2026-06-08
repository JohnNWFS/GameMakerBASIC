/// MODE 3 ACCELERATED DRAWING COMMAND
/// @function basic_cmd_circle(arg)
/// @syntax CIRCLE x,y,r[,lineColor[,fillFlag[,fillColor]]]
/// @desc Draws a GameMaker-backed circle on the MODE 3 pixel surface.
function basic_cmd_circle(arg) {
    if (global.current_mode != 3) {
        dbg_log(DBG_FLOW, "CIRCLE: only available in MODE 3 pixel graphics");
        return;
    }

    var args = basic_parse_csv_args(arg);
    if (array_length(args) < 3) {
        basic_syntax_error("CIRCLE requires x,y,r[,lineColor[,fillFlag[,fillColor]]]", global.current_line_number, 0, "CIRCLE_ARGS");
        return;
    }

    var cx = real(basic_evaluate_expression_v2(string_trim(args[0])));
    var cy = real(basic_evaluate_expression_v2(string_trim(args[1])));
    var radius = abs(real(basic_evaluate_expression_v2(string_trim(args[2]))));
    var line_color = (array_length(args) >= 4) ? basic_parse_color(string_trim(args[3])) : c_white;
    var fill_enabled = (array_length(args) >= 5) ? (real(basic_evaluate_expression_v2(string_trim(args[4]))) != 0) : false;
    var fill_color = (array_length(args) >= 6) ? basic_parse_color(string_trim(args[5])) : line_color;

    if (!variable_global_exists("mode2_surface") || !surface_exists(global.mode2_surface)) {
        mode2_surface_recreate();
    }

    if (surface_exists(global.mode2_surface)) {
        surface_set_target(global.mode2_surface);

        if (fill_enabled) {
            draw_set_color(fill_color);
            draw_circle(cx, cy, radius, false);
        }

        draw_set_color(line_color);
        draw_circle(cx, cy, radius, true);

        surface_reset_target();
        dbg_log(DBG_FLOW, "CIRCLE MODE3: (" + string(cx) + "," + string(cy) + ") r=" + string(radius)
            + " line=" + string(line_color) + " fill=" + string(fill_enabled) + " fill_color=" + string(fill_color));
    }
}

/// @function basic_cmd_line(arg)
/// @syntax LINE x1,y1,x2,y2[,color[,thickness]]
/// @desc Draws a GameMaker-backed line on the MODE 3 pixel surface.
function basic_cmd_line(arg) {
    if (global.current_mode != 3) {
        dbg_log(DBG_FLOW, "LINE: only available in MODE 3 pixel graphics");
        return;
    }

    var args = basic_parse_csv_args(arg);
    if (array_length(args) < 4) {
        basic_syntax_error("LINE requires x1,y1,x2,y2[,color[,thickness]]", global.current_line_number, 0, "LINE_ARGS");
        return;
    }

    var x1 = real(basic_evaluate_expression_v2(string_trim(args[0])));
    var y1 = real(basic_evaluate_expression_v2(string_trim(args[1])));
    var x2 = real(basic_evaluate_expression_v2(string_trim(args[2])));
    var y2 = real(basic_evaluate_expression_v2(string_trim(args[3])));
    var line_color = (array_length(args) >= 5) ? basic_parse_color(string_trim(args[4])) : c_white;
    var thickness = (array_length(args) >= 6) ? max(1, real(basic_evaluate_expression_v2(string_trim(args[5])))) : 1;

    if (!variable_global_exists("mode2_surface") || !surface_exists(global.mode2_surface)) {
        mode2_surface_recreate();
    }

    if (surface_exists(global.mode2_surface)) {
        surface_set_target(global.mode2_surface);
        draw_set_color(line_color);
        draw_line_width(x1, y1, x2, y2, thickness);
        surface_reset_target();
        dbg_log(DBG_FLOW, "LINE MODE3: (" + string(x1) + "," + string(y1) + ")-(" + string(x2) + "," + string(y2)
            + ") color=" + string(line_color) + " thickness=" + string(thickness));
    }
}

/// @function basic_cmd_box(arg)
/// @syntax BOX x1,y1,x2,y2[,lineColor[,fillFlag[,fillColor[,thickness]]]]
/// @desc Draws a GameMaker-backed rectangle on the MODE 3 pixel surface.
function basic_cmd_box(arg) {
    if (global.current_mode != 3) {
        basic_cmd_tile_box(arg);
        return;
    }

    var args = basic_parse_csv_args(arg);
    if (array_length(args) < 4) {
        basic_syntax_error("BOX requires x1,y1,x2,y2[,lineColor[,fillFlag[,fillColor[,thickness]]]]", global.current_line_number, 0, "BOX_ARGS");
        return;
    }

    var x1 = real(basic_evaluate_expression_v2(string_trim(args[0])));
    var y1 = real(basic_evaluate_expression_v2(string_trim(args[1])));
    var x2 = real(basic_evaluate_expression_v2(string_trim(args[2])));
    var y2 = real(basic_evaluate_expression_v2(string_trim(args[3])));
    var line_color = (array_length(args) >= 5) ? basic_parse_color(string_trim(args[4])) : c_white;
    var fill_enabled = (array_length(args) >= 6) ? (real(basic_evaluate_expression_v2(string_trim(args[5]))) != 0) : false;
    var fill_color = (array_length(args) >= 7) ? basic_parse_color(string_trim(args[6])) : line_color;
    var thickness = (array_length(args) >= 8) ? max(1, real(basic_evaluate_expression_v2(string_trim(args[7])))) : 1;

    var left = min(x1, x2);
    var right = max(x1, x2);
    var top = min(y1, y2);
    var bottom = max(y1, y2);

    if (!variable_global_exists("mode2_surface") || !surface_exists(global.mode2_surface)) {
        mode2_surface_recreate();
    }

    if (surface_exists(global.mode2_surface)) {
        surface_set_target(global.mode2_surface);

        if (fill_enabled) {
            draw_set_color(fill_color);
            draw_rectangle(left, top, right, bottom, false);
        }

        draw_set_color(line_color);
        draw_line_width(left, top, right, top, thickness);
        draw_line_width(right, top, right, bottom, thickness);
        draw_line_width(right, bottom, left, bottom, thickness);
        draw_line_width(left, bottom, left, top, thickness);

        surface_reset_target();
        dbg_log(DBG_FLOW, "BOX MODE3: (" + string(left) + "," + string(top) + ")-(" + string(right) + "," + string(bottom)
            + ") line=" + string(line_color) + " fill=" + string(fill_enabled) + " fill_color=" + string(fill_color)
            + " thickness=" + string(thickness));
    }
}
