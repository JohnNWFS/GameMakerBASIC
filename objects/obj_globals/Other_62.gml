/// @event obj_globals/Async - HTTP
// This event only triggers when an HTTP request completes
// async_load is automatically valid here

var req_id = ds_map_find_value(async_load, "id");
var stat   = ds_map_find_value(async_load, "status");

if (!variable_global_exists("http_tags")) exit;
if (!ds_map_exists(global.http_tags, req_id)) exit;

var tag  = ds_map_find_value(global.http_tags, req_id);
var body = ds_map_find_value(async_load, "result");

if (stat == -1) exit;
ds_map_delete(global.http_tags, req_id);

if (tag == ":LOADURL") {
    if (stat == 0 && is_string(body)) {
        var n = editor_import_text_to_program(body);
        show_error_message("Imported " + string(n) + " line(s) from URL.");
    } else {
        var sc = ds_map_find_value(async_load, "http_status");
        show_error_message("LOADURL failed (status=" + string(sc) + ").");
    }
}

if (tag == ":DEMOS_MANIFEST") {
    if (stat == 0 && is_string(body)) {
        var _parsed = json_parse(body);
        if (!is_struct(_parsed)) {
            show_error_message("DEMOS: unexpected response format (not a struct)");
        } else {
        var _arr = _parsed[$ "demos"];
        if (!is_array(_arr)) {
            show_error_message("DEMOS: manifest missing 'demos' array\n" + string_copy(body, 1, 200));
        } else {
        global.demos_manifest = _arr;
        demos_show_list();
        if (variable_global_exists("__demos_pending_load") && global.__demos_pending_load > 0) {
            var _idx = global.__demos_pending_load - 1;
            global.__demos_pending_load = 0;
            if (_idx >= 0 && _idx < array_length(global.demos_manifest)) {
                import_from_url(global.demos_manifest[_idx][$ "url"]);
            }
        }
        }}
    } else {
        var _sc2 = ds_map_find_value(async_load, "http_status");
        show_error_message("Could not fetch demos list (HTTP " + string(_sc2) + " stat=" + string(stat) + ").");
    }
}