/// Keep GUI layer synced to browser viewport (rotation / resize).
if (kb_active) {
    var _sw = display_get_width();
    var _sh = display_get_height();
    if (_sw >= 100 && _sh >= 100) {
        display_set_gui_size(_sw, _sh);
        if (kb_visible) {
            var _row_h0 = max(48, floor(_sh * 0.07));
            KB_H = 6 * (_row_h0 + 2) + 6;
        }
    }
}

/// Handle touch input: toggle tab + keyboard keys.
if (!kb_active) exit;
if (!device_mouse_check_button_pressed(0, mb_left)) exit;

var _tx = device_mouse_x_to_gui(0);
var _ty = device_mouse_y_to_gui(0);

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
if (_gw < 100) _gw = room_width;
if (_gh < 100) _gh = room_height;

// ── Toggle tab hit-test ───────────────────────────────────────────────────────
// Tab position mirrors Draw_64: above keyboard when visible, bottom-right when hidden.
var _tab_w  = 80;
var _tab_h  = 32;
var _row_h2 = max(48, floor(_gh * 0.07));
var _kb_h2  = 6 * (_row_h2 + 2) + 6;
var _tab_y2 = kb_visible ? (_gh - _kb_h2 - _tab_h) : (_gh - _tab_h);
if (_tx >= _gw - _tab_w && _ty >= _tab_y2 && _ty <= _tab_y2 + _tab_h) {
    mobile_kb_set_visible(!kb_visible);
    exit;
}

if (!kb_visible) exit;

// ── Keyboard key hit-test ────────────────────────────────────────────────────
var _row_h = max(48, floor(_gh * 0.07));
var _gap   = 2;
var _kb_h  = 6 * (_row_h + _gap) + 6;
var _kb_y  = _gh - _kb_h;

if (_ty < _kb_y - 2) exit;  // tap above keyboard — pass through to game

var _layout = [
    [["ESC","ESC",1.5],["F1","F1",1],["F2","F2",1],["F3","F3",1],["F4","F4",1],["F5","F5",1],["<-","LEFT",1],["->","RIGHT",1],["BKSP","BACKSPACE",1.5]],
    [["1","1",1],["2","2",1],["3","3",1],["4","4",1],["5","5",1],["6","6",1],["7","7",1],["8","8",1],["9","9",1],["0","0",1],["\"","\"",1],[":",":",1]],
    [["Q","Q",1],["W","W",1],["E","E",1],["R","R",1],["T","T",1],["Y","Y",1],["U","U",1],["I","I",1],["O","O",1],["P","P",1],["(","(",1],[")",")",1]],
    [["A","A",1],["S","S",1],["D","D",1],["F","F",1],["G","G",1],["H","H",1],["J","J",1],["K","K",1],["L","L",1],[";",";",1],["ENT","ENTER",2]],
    [["SHF","SHIFT",1.5],["Z","Z",1],["X","X",1],["C","C",1],["V","V",1],["B","B",1],["N","N",1],["M","M",1],[",",",",1],[".",".",1],["/","/",1],["+","+",1]],
    [["CAPS","CAPS",1.5],["SPACE","SPACE",4],["-","-",1],["=","=",1],["*","*",1],["<","<",1],[">",">",1],["CLR","CLR",1.5]]
];

var _nr = array_length(_layout);
for (var _ri = 0; _ri < _nr; _ri++) {
    var _row = _layout[_ri];
    var _nk  = array_length(_row);
    var _ry  = _kb_y + 3 + _ri * (_row_h + _gap);

    if (_ty < _ry || _ty > _ry + _row_h) continue;

    var _tu = 0;
    for (var _ki = 0; _ki < _nk; _ki++) _tu += real(_row[_ki][2]);
    var _uw = _gw / _tu;

    var _kx = 0;
    for (var _ki = 0; _ki < _nk; _ki++) {
        var _key = _row[_ki][1];
        var _kw  = real(_row[_ki][2]) * _uw;

        if (_tx >= _kx && _tx < _kx + _kw) {
            mobile_kb_handle_key(_key);
            exit;
        }
        _kx += _kw;
    }
}
