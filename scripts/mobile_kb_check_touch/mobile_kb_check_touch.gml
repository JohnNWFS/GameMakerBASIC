/// Call from obj_editor Step_0 when showing_html_kb = true.
/// Checks all active touch points against the keyboard layout and handles the first hit.
function mobile_kb_check_touch() {
    // Only act on a fresh press this frame
    if (!device_mouse_check_button_pressed(0, mb_left)) exit;

    var _tx = device_mouse_x(0);
    var _ty = device_mouse_y(0);

    var _rw  = room_width;
    var _rh  = room_height;
    var _row_h = 38;
    var _gap   = 2;
    var _kb_h  = 6 * (_row_h + _gap) + 6;
    var _kb_y  = _rh - _kb_h;

    // Outside keyboard area?
    if (_ty < _kb_y - 2) exit;

    var _layout = [
        [["ESC","ESC",1.5],["F1","F1",1],["F2","F2",1],["F3","F3",1],["F4","F4",1],["F5","F5",1],["<-","LEFT",1],["->","RIGHT",1],["BKSP","BACKSPACE",1.5]],
        [["1","1",1],["2","2",1],["3","3",1],["4","4",1],["5","5",1],["6","6",1],["7","7",1],["8","8",1],["9","9",1],["0","0",1],["\"","\"",1],[":",":",1]],
        [["Q","Q",1],["W","W",1],["E","E",1],["R","R",1],["T","T",1],["Y","Y",1],["U","U",1],["I","I",1],["O","O",1],["P","P",1],["(","(",1],[")",")","1"]],
        [["A","A",1],["S","S",1],["D","D",1],["F","F",1],["G","G",1],["H","H",1],["J","J",1],["K","K",1],["L","L",1],[";",";",1],["ENT","ENTER",2]],
        [["SHF","SHIFT",1.5],["Z","Z",1],["X","X",1],["C","C",1],["V","V",1],["B","B",1],["N","N",1],["M","M",1],[",",",",1],[".",".","1"],["/","/",1],["+","+",1]],
        [["CAPS","CAPS",1.5],["SPACE","SPACE",4],["-","-",1],["=","=",1],["*","*",1],["<","<",1],[">",">",1],["CLR","ESC",1.5]]
    ];

    var _nr = array_length(_layout);
    for (var _ri = 0; _ri < _nr; _ri++) {
        var _row = _layout[_ri];
        var _nk  = array_length(_row);
        var _ry  = _kb_y + 3 + _ri * (_row_h + _gap);

        if (_ty < _ry || _ty > _ry + _row_h) continue;

        var _tu = 0;
        for (var _ki = 0; _ki < _nk; _ki++) _tu += real(_row[_ki][2]);
        var _uw = _rw / _tu;

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
}
