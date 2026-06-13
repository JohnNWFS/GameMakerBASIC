/// @function demos_load_file_local(_idx)
/// @desc Load a demo .bas file from working_directory/demos/ by manifest index.
function demos_load_file_local(_idx) {
    var _url  = global.demos_manifest[_idx][$ "url"];
    var _slash = string_last_pos("/", _url);
    var _fname = string_copy(_url, _slash + 1, string_length(_url) - _slash);
    var _path = working_directory + "demos/" + _fname;
    var _f = file_text_open_read(_path);
    if (_f < 0) {
        show_error_message("Demo file not found: " + _path);
        return;
    }
    var _txt = "";
    while (!file_text_eof(_f)) {
        _txt += file_text_readln(_f) + "\n";
    }
    file_text_close(_f);
    new_program();
    var _n = editor_import_text_to_program(_txt);
    basic_show_message("Loaded: " + global.demos_manifest[_idx][$ "title"]);
}
