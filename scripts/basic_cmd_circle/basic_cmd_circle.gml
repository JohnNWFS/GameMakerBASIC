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
    if (!basic_require_arg_count(args, "CIRCLE", 3, 6, "x,y,r[,lineColor[,fillFlag[,fillColor]]]")) return;

    var cx_arg = basic_eval_number_arg(args[0], "CIRCLE", "x");
    var cy_arg = basic_eval_number_arg(args[1], "CIRCLE", "y");
    var radius_arg = basic_eval_number_arg(args[2], "CIRCLE", "r");
    if (!cx_arg.ok || !cy_arg.ok || !radius_arg.ok) return;
    var cx = cx_arg.value;
    var cy = cy_arg.value;
    var radius = abs(radius_arg.value);
    var line_color = (array_length(args) >= 4) ? basic_parse_color(string_trim(args[3])) : c_white;
    var fill_enabled = false;
    if (array_length(args) >= 5) {
        var fill_arg = basic_eval_bool_arg(args[4], "CIRCLE", "fillFlag");
        if (!fill_arg.ok) return;
        fill_enabled = fill_arg.value;
    }
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
    if (!basic_require_arg_count(args, "LINE", 4, 6, "x1,y1,x2,y2[,color[,thickness]]")) return;

    var x1_arg = basic_eval_number_arg(args[0], "LINE", "x1");
    var y1_arg = basic_eval_number_arg(args[1], "LINE", "y1");
    var x2_arg = basic_eval_number_arg(args[2], "LINE", "x2");
    var y2_arg = basic_eval_number_arg(args[3], "LINE", "y2");
    if (!x1_arg.ok || !y1_arg.ok || !x2_arg.ok || !y2_arg.ok) return;
    var x1 = x1_arg.value;
    var y1 = y1_arg.value;
    var x2 = x2_arg.value;
    var y2 = y2_arg.value;
    var line_color = (array_length(args) >= 5) ? basic_parse_color(string_trim(args[4])) : c_white;
    var thickness = 1;
    if (array_length(args) >= 6) {
        var thick_arg = basic_eval_number_arg(args[5], "LINE", "thickness");
        if (!thick_arg.ok) return;
        thickness = max(1, thick_arg.value);
    }

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
    if (!basic_require_arg_count(args, "BOX", 4, 8, "x1,y1,x2,y2[,lineColor[,fillFlag[,fillColor[,thickness]]]]")) return;

    var x1_arg = basic_eval_number_arg(args[0], "BOX", "x1");
    var y1_arg = basic_eval_number_arg(args[1], "BOX", "y1");
    var x2_arg = basic_eval_number_arg(args[2], "BOX", "x2");
    var y2_arg = basic_eval_number_arg(args[3], "BOX", "y2");
    if (!x1_arg.ok || !y1_arg.ok || !x2_arg.ok || !y2_arg.ok) return;
    var x1 = x1_arg.value;
    var y1 = y1_arg.value;
    var x2 = x2_arg.value;
    var y2 = y2_arg.value;
    var line_color = (array_length(args) >= 5) ? basic_parse_color(string_trim(args[4])) : c_white;
    var fill_enabled = false;
    if (array_length(args) >= 6) {
        var fill_arg = basic_eval_bool_arg(args[5], "BOX", "fillFlag");
        if (!fill_arg.ok) return;
        fill_enabled = fill_arg.value;
    }
    var fill_color = (array_length(args) >= 7) ? basic_parse_color(string_trim(args[6])) : line_color;
    var thickness = 1;
    if (array_length(args) >= 8) {
        var thick_arg = basic_eval_number_arg(args[7], "BOX", "thickness");
        if (!thick_arg.ok) return;
        thickness = max(1, thick_arg.value);
    }

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

/// @function basic_cmd_paint(arg)
/// @syntax PAINT x, y [, color]
/// @desc Flood-fill on the MODE 3 pixel surface (4-connected).
function basic_cmd_paint(arg) {
    if (global.current_mode != 3) {
        dbg_log(DBG_FLOW, "PAINT: only available in MODE 3 pixel graphics");
        return;
    }

    var args = basic_parse_csv_args(arg);
    if (!basic_require_arg_count(args, "PAINT", 2, 3, "x,y[,color]")) return;

    var px_arg = basic_eval_int_arg(args[0], "PAINT", "x");
    var py_arg = basic_eval_int_arg(args[1], "PAINT", "y");
    if (!px_arg.ok || !py_arg.ok) return;
    var sx = px_arg.value;
    var sy = py_arg.value;
    var fill_col = (array_length(args) >= 3) ? basic_parse_color(string_trim(args[2])) : c_white;

    if (!variable_global_exists("mode2_surface") || !surface_exists(global.mode2_surface)) {
        mode2_surface_recreate();
    }
    if (!surface_exists(global.mode2_surface)) return;

    var sw = surface_get_width(global.mode2_surface);
    var sh = surface_get_height(global.mode2_surface);
    if (sx < 0 || sy < 0 || sx >= sw || sy >= sh) return;

    var target_col = surface_getpixel(global.mode2_surface, sx, sy);
    if (target_col == fill_col) return;

    var q = ds_queue_create();
    var visited = ds_map_create();
    ds_queue_enqueue(q, sx);
    ds_queue_enqueue(q, sy);

    surface_set_target(global.mode2_surface);
    draw_set_color(fill_col);

    while (ds_queue_size(q) > 0) {
        var cy = ds_queue_dequeue(q);
        var cx = ds_queue_dequeue(q);
        var key = string(cx) + "," + string(cy);
        if (ds_map_exists(visited, key)) continue;
        if (cx < 0 || cy < 0 || cx >= sw || cy >= sh) continue;
        if (surface_getpixel(global.mode2_surface, cx, cy) != target_col) continue;

        ds_map_set(visited, key, true);
        draw_point(cx, cy);

        ds_queue_enqueue(q, cx + 1); ds_queue_enqueue(q, cy);
        ds_queue_enqueue(q, cx - 1); ds_queue_enqueue(q, cy);
        ds_queue_enqueue(q, cx);     ds_queue_enqueue(q, cy + 1);
        ds_queue_enqueue(q, cx);     ds_queue_enqueue(q, cy - 1);
    }

    surface_reset_target();
    ds_queue_destroy(q);
    ds_map_destroy(visited);
    dbg_log(DBG_FLOW, "PAINT MODE3: seed (" + string(sx) + "," + string(sy) + ") fill=" + string(fill_col));
}
