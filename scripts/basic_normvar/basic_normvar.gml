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
