/// @function demos_load_manifest_local()
/// @desc Read demos/manifest.json from working_directory and populate global.demos_manifest.
function demos_load_manifest_local() {
    var _path = working_directory + "demos/manifest.json";
    var _f = file_text_open_read(_path);
    if (_f < 0) {
        show_error_message("Demos not found. Expected: " + _path);
        return;
    }
    var _txt = "";
    while (!file_text_eof(_f)) {
        _txt += file_text_readln(_f) + "\n";
    }
    file_text_close(_f);
    var _parsed = json_parse(_txt);
    if (!is_struct(_parsed)) {
        show_error_message("DEMOS: manifest parse error");
        return;
    }
    var _arr = _parsed[$ "demos"];
    if (!is_array(_arr)) {
        show_error_message("DEMOS: manifest missing 'demos' array");
        return;
    }
    global.demos_manifest = _arr;
    demos_show_list();
}
