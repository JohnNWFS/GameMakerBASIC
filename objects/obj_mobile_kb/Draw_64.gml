/// Draw GUI — renders the keyboard in GUI/screen coordinates on top of every room.
if (!kb_active) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
if (_gw <= 0) _gw = room_width;
if (_gh <= 0) _gh = room_height;

if (!kb_visible) exit;

var _row_h = 38;
var _gap   = 2;
var _rows  = 6;
var _kb_h  = _rows * (_row_h + _gap) + 6;
var _kb_y  = _gh - _kb_h;

// Background
draw_set_color(make_color_rgb(18, 18, 18));
draw_rectangle(0, _kb_y - 2, _gw, _gh, false);

draw_set_font(fnt_basic_12);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

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

    var _tu = 0;
    for (var _ki = 0; _ki < _nk; _ki++) _tu += real(_row[_ki][2]);
    var _uw = _gw / _tu;

    var _kx = 0;
    for (var _ki = 0; _ki < _nk; _ki++) {
        var _lbl = _row[_ki][0];
        var _key = _row[_ki][1];
        var _kw  = real(_row[_ki][2]) * _uw;

        var _is_active = (_key == "SHIFT" && kb_shift) || (_key == "CAPS" && kb_caps);
        var _is_mod    = (_key == "SHIFT" || _key == "CAPS" || _key == "ENTER" || _key == "BACKSPACE" || _key == "ESC");
        var _is_fn     = (string_copy(_key,1,1) == "F" && string_length(_key) == 2);

        if (_is_active)      draw_set_color(make_color_rgb(40,160,60));
        else if (_is_mod)    draw_set_color(make_color_rgb(55,55,55));
        else if (_is_fn)     draw_set_color(make_color_rgb(35,35,75));
        else                 draw_set_color(make_color_rgb(45,45,45));

        draw_rectangle(_kx + 1, _ry + 1, _kx + _kw - 2, _ry + _row_h - 2, false);

        var _disp = _lbl;
        if (string_length(_key) == 1 && _key >= "A" && _key <= "Z") {
            var _lower = kb_caps ? !kb_shift : kb_shift;
            _disp = _lower ? string_lower(_lbl) : _lbl;
        }

        draw_set_color(c_white);
        draw_text(_kx + _kw * 0.5, _ry + _row_h * 0.5, _disp);
        _kx += _kw;
    }
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
