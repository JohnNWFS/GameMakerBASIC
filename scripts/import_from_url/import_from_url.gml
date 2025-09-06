/// @function import_from_url(_url)
/// @desc Fetch text at URL, then import into the editor as numbered lines.
function import_from_url(_url) {
    if (!is_string(_url) || _url == "") {
        show_error_message("Usage: :LOADURL <http(s)://...>");
        return;
    }
    if (!variable_global_exists("http_tags")) global.http_tags = ds_map_create();

    var req = http_get(_url);
    // Store a tag so we know why this request happened
    ds_map_replace(global.http_tags, req, ":LOADURL");
   if (dbg_on(DBG_FLOW)) show_debug_message("[LOADURL] GET -> " + _url + " (req=" + string(req) + ")");
}
