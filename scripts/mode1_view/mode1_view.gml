/// MODE 2 viewport — clip drawing to a rectangular cell region.

function mode1_view_ensure() {
    if (!variable_global_exists("mode2_view") || !is_struct(global.mode2_view)) {
        mode1_view_reset();
    }
}

function mode1_view_reset() {
    global.mode2_view = {
        active: false,
        x: 0,
        y: 0,
        w: 0,
        h: 0
    };
}

function mode1_view_active() {
    mode1_view_ensure();
    return global.mode2_view.active;
}

function mode1_view_set(_x, _y, _w, _h) {
    mode1_view_ensure();
    var grid_obj = instance_find(obj_mode1_grid, 0);
    var max_c = (instance_exists(grid_obj)) ? grid_obj.grid_cols : 40;
    var max_r = (instance_exists(grid_obj)) ? grid_obj.grid_rows : 25;

    _x = clamp(floor(_x), 0, max(0, max_c - 1));
    _y = clamp(floor(_y), 0, max(0, max_r - 1));
    _w = clamp(floor(_w), 1, max_c - _x);
    _h = clamp(floor(_h), 1, max_r - _y);

    global.mode2_view = {
        active: true,
        x: _x,
        y: _y,
        w: _w,
        h: _h
    };
    dbg_log(DBG_FLOW, "VIEW: (" + string(_x) + "," + string(_y) + ") " + string(_w) + "x" + string(_h));
}

function mode1_view_off() {
    mode1_view_reset();
    dbg_log(DBG_FLOW, "VIEW OFF");
}

function mode1_view_contains(_col, _row) {
    mode1_view_ensure();
    if (!global.mode2_view.active) return true;
    var v = global.mode2_view;
    return (_col >= v.x && _col < v.x + v.w && _row >= v.y && _row < v.y + v.h);
}

function mode1_view_print_limits() {
    mode1_view_ensure();
    var grid_obj = instance_find(obj_mode1_grid, 0);
    var cols = (instance_exists(grid_obj)) ? grid_obj.grid_cols : 40;
    var rows = (instance_exists(grid_obj)) ? grid_obj.grid_rows : 25;

    if (!global.mode2_view.active) {
        return { left: 0, top: 0, right: cols - 1, bottom: rows - 1 };
    }

    var v = global.mode2_view;
    return {
        left: v.x,
        top: v.y,
        right: v.x + v.w - 1,
        bottom: v.y + v.h - 1
    };
}