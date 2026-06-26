/// basic_normvar(name) -> canonical variable key
function basic_normvar(_name) {
    return string_upper(string_trim(string(_name)));
}

/// Ensure global.basic_variables exists as a struct (modern GML store).
function basic_var_ensure() {
    if (!variable_global_exists("basic_variables") || !is_struct(global.basic_variables)) {
        global.basic_variables = {};
    }
}

function basic_var_exists(_key) {
    basic_var_ensure();
    return variable_struct_exists(global.basic_variables, basic_normvar(_key));
}

function basic_var_get(_key, _default = undefined) {
    basic_var_ensure();
    var k = basic_normvar(_key);
    if (!variable_struct_exists(global.basic_variables, k)) return _default;
    return global.basic_variables[$ k];
}

function basic_var_set(_key, _val) {
    basic_var_ensure();
    global.basic_variables[$ basic_normvar(_key)] = _val;
}

/// True when a value can be used as a numeric array index or expression operand.
function basic_is_number_val(_v) {
    return is_real(_v) || is_int64(_v);
}

/// Coerce BASIC numeric operands (real, int64, or numeric string) to real.
function basic_coerce_number(_v, _default = 0) {
    if (basic_is_number_val(_v)) return real(_v);
    if (is_string(_v) && basic_looks_numeric(_v)) return real(_v);
    return _default;
}

/// Split on commas not inside quotes or nested parentheses.
function basic_split_top_commas(_s) {
    var parts = [];
    var _dl = 0;
    var _dq = false;
    var start = 1;
    var L = string_length(_s);
    for (var i = 1; i <= L; i++) {
        var ch = string_char_at(_s, i);
        if (ch == "\"") _dq = !_dq;
        if (!_dq) {
            if (ch == "(") _dl++;
            else if (ch == ")") _dl = max(0, _dl - 1);
            else if (ch == "," && _dl == 0) {
                array_push(parts, string_trim(string_copy(_s, start, i - start)));
                start = i + 1;
            }
        }
    }
    if (start <= L) {
        array_push(parts, string_trim(string_copy(_s, start, L - start + 1)));
    }
    return parts;
}

/// Destroy legacy ds_list array storage only (native GML arrays need no release).
function basic_array_release_storage(_storage) {
    if (is_real(_storage) && ds_exists(_storage, ds_type_list)) {
        ds_list_destroy(_storage);
    }
}

/// basic_looks_numeric(s) -> bool  (no regex; robust enough for BASIC)
function basic_looks_numeric(_s) {
    var s = string_trim(string(_s));
    if (s == "") return false;
    var digits = 0;
    for (var i = 1; i <= string_length(s); i++) {
        var c = ord(string_char_at(s, i));
        if ((c >= 48 && c <= 57)) digits++;                     // 0..9
        else if (c == 46 || c == 45) { /* '.' or leading '-' */ }
        else return false;
    }
    return digits > 0;
}
