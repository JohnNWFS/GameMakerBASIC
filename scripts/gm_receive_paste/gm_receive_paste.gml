/// scripts/gm_receive_paste.gml
function gm_receive_paste(_text) {
    global.import_text  = is_string(_text) ? _text : "";
    global.import_ready = (global.import_text != "");
    show_error_message("Import received."); // visible confirmation
}
