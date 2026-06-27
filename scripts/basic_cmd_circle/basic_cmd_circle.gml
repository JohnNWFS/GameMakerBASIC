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

/// @function __mode3_ensure_surface()
function __mode3_ensure_surface() {
    if (!variable_global_exists("mode2_surface") || !surface_exists(global.mode2_surface)) {
        mode2_surface_recreate();
    }
    return surface_exists(global.mode2_surface);
}

/// @function __mode3_draw_line(x1,y1,x2,y2,col)
function __mode3_draw_line(_x1, _y1, _x2, _y2, _col) {
    if (!__mode3_ensure_surface()) return;
    surface_set_target(global.mode2_surface);
    draw_set_color(_col);
    draw_line_width(_x1, _y1, _x2, _y2, 1);
    surface_reset_target();
}

/// @function __mode3_paint_at(sx,sy,fill_col)
function __mode3_paint_at(_sx, _sy, _fill_col) {
    if (!__mode3_ensure_surface()) return;
    var sw = surface_get_width(global.mode2_surface);
    var sh = surface_get_height(global.mode2_surface);
    if (_sx < 0 || _sy < 0 || _sx >= sw || _sy >= sh) return;

    var target_col = surface_getpixel(global.mode2_surface, _sx, _sy);
    if (target_col == _fill_col) return;

    var q = ds_queue_create();
    var visited = ds_map_create();
    ds_queue_enqueue(q, _sx);
    ds_queue_enqueue(q, _sy);

    surface_set_target(global.mode2_surface);
    draw_set_color(_fill_col);

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
}

function __draw_read_num(_s, _pos) {
    var L = string_length(_s);
    var p = _pos;
    var _sign = 1;
    if (p <= L && string_char_at(_s, p) == "+") p++;
    else if (p <= L && string_char_at(_s, p) == "-") { _sign = -1; p++; }

    var val = "";
    while (p <= L) {
        var c = string_char_at(_s, p);
        if (c >= "0" && c <= "9") { val += c; p++; }
        else break;
    }
    if (val == "") return { ok: false, value: 0, pos: p };
    return { ok: true, value: _sign * real(val), pos: p };
}

function __draw_read_color(_s, _pos) {
    var num = __draw_read_num(_s, _pos);
    if (num.ok) return { color: basic_parse_color(string(floor(num.value))), pos: num.pos };

    var name = "";
    var p = _pos;
    var L = string_length(_s);
    while (p <= L) {
        var c = string_upper(string_char_at(_s, p));
        if ((c >= "A" && c <= "Z") || (c >= "0" && c <= "9") || c == "_") { name += c; p++; }
        else break;
    }
    if (name != "") return { color: basic_parse_color(name), pos: p };
    return { color: global.draw_color, pos: _pos };
}

function __draw_step_vec(_cmd, _dist, _angle_deg) {
    var ux = 0;
    var uy = 0;
    switch (_cmd) {
        case "U": uy = -1; break;
        case "D": uy = 1; break;
        case "L": ux = -1; break;
        case "R": ux = 1; break;
        case "E": ux = 1;  uy = -1; break;
        case "F": ux = 1;  uy = 1; break;
        case "G": ux = -1; uy = 1; break;
        case "H": ux = -1; uy = -1; break;
        default: return [0, 0];
    }
    var rad = degtorad(_angle_deg);
    var cos_a = cos(rad);
    var sin_a = sin(rad);
    var rx = ux * cos_a - uy * sin_a;
    var ry = ux * sin_a + uy * cos_a;
    return [rx * _dist, ry * _dist];
}

/// @function basic_cmd_draw(arg)
/// @syntax DRAW "command string"
/// @desc QBASIC-style vector graphics on the MODE 3 pixel surface.
function basic_cmd_draw(arg) {
    if (global.current_mode != 3) {
        dbg_log(DBG_FLOW, "DRAW: only available in MODE 3 pixel graphics");
        return;
    }

    var s = string(basic_evaluate_expression_v2(string_trim(arg)));
    if (string_length(s) <= 0) {
        basic_syntax_error("DRAW requires a command string",
            global.current_line_number, global.interpreter_current_stmt_index, "DRAW_SYNTAX");
        return;
    }

    if (!variable_global_exists("draw_pen_x")) {
        global.draw_pen_x = 0;
        global.draw_pen_y = 0;
        global.draw_scale = 4;
        global.draw_angle = 0;
        global.draw_color = c_white;
    }
    global.draw_color = global.current_draw_color;

    var L = string_length(s);
    var i = 1;
    var blank = false;
    var paint_after = false;

    while (i <= L) {
        var ch = string_upper(string_char_at(s, i));
        if (ch == " " || ch == ",") { i++; continue; }

        if (ch == "B") { blank = true; i++; continue; }
        if (ch == "P") { paint_after = true; i++; continue; }
        if (ch == "N") { blank = false; paint_after = false; i++; continue; }

        if (ch == "M") {
            i++;
            var rel_x = (i <= L && string_char_at(s, i) == "+");
            if (i <= L && string_char_at(s, i) == "+") i++;
            var rel_y = false;
            var nxr = __draw_read_num(s, i);
            if (!nxr.ok) {
                basic_syntax_error("DRAW M requires x,y coordinates",
                    global.current_line_number, global.interpreter_current_stmt_index, "DRAW_SYNTAX");
                return;
            }
            i = nxr.pos;
            while (i <= L && (string_char_at(s, i) == " " || string_char_at(s, i) == ",")) i++;
            if (i <= L && string_char_at(s, i) == "+") { rel_y = true; i++; }
            var nyr = __draw_read_num(s, i);
            if (!nyr.ok) {
                basic_syntax_error("DRAW M requires x,y coordinates",
                    global.current_line_number, global.interpreter_current_stmt_index, "DRAW_SYNTAX");
                return;
            }
            i = nyr.pos;
            var tx = rel_x ? (global.draw_pen_x + nxr.value) : nxr.value;
            var ty = rel_y ? (global.draw_pen_y + nyr.value) : nyr.value;
            if (!blank) __mode3_draw_line(global.draw_pen_x, global.draw_pen_y, tx, ty, global.draw_color);
            global.draw_pen_x = tx;
            global.draw_pen_y = ty;
            if (paint_after) __mode3_paint_at(floor(tx), floor(ty), global.draw_color);
            blank = false;
            continue;
        }

        if (ch == "C") {
            i++;
            var cc = __draw_read_color(s, i);
            global.draw_color = cc.color;
            i = cc.pos;
            continue;
        }

        if (ch == "S") {
            i++;
            var ns = __draw_read_num(s, i);
            if (ns.ok) global.draw_scale = max(1, ns.value);
            i = ns.ok ? ns.pos : i;
            continue;
        }

        if (ch == "A") {
            i++;
            var na = __draw_read_num(s, i);
            if (na.ok) global.draw_angle = na.value;
            i = na.ok ? na.pos : i;
            continue;
        }

        if (ch == "U" || ch == "D" || ch == "L" || ch == "R"
         || ch == "E" || ch == "F" || ch == "G" || ch == "H") {
            i++;
            var nn = __draw_read_num(s, i);
            var n = nn.ok ? nn.value : 1;
            i = nn.ok ? nn.pos : i;
            var dist = n * global.draw_scale / 4;
            var dxy = __draw_step_vec(ch, dist, global.draw_angle);
            var tx = global.draw_pen_x + dxy[0];
            var ty = global.draw_pen_y + dxy[1];
            if (!blank) __mode3_draw_line(global.draw_pen_x, global.draw_pen_y, tx, ty, global.draw_color);
            global.draw_pen_x = tx;
            global.draw_pen_y = ty;
            if (paint_after) __mode3_paint_at(floor(tx), floor(ty), global.draw_color);
            blank = false;
            continue;
        }

        basic_syntax_error("DRAW: unknown command '" + ch + "' in string",
            global.current_line_number, global.interpreter_current_stmt_index, "DRAW_SYNTAX");
        return;
    }

    dbg_log(DBG_FLOW, "DRAW MODE3: pen=(" + string(global.draw_pen_x) + "," + string(global.draw_pen_y)
        + ") scale=" + string(global.draw_scale) + " angle=" + string(global.draw_angle));
}
