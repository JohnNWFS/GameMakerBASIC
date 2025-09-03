/// @event obj_globals/Async - HTTP
// This event only triggers when an HTTP request completes
// async_load is automatically valid here

var req_id = ds_map_find_value(async_load, "id");
if (!variable_global_exists("http_tags")) exit;
if (!ds_map_exists(global.http_tags, req_id)) exit;

var tag  = ds_map_find_value(global.http_tags, req_id);
var stat = ds_map_find_value(async_load, "status"); // 0 = OK
var body = ds_map_find_value(async_load, "result");

// Clean up the tag immediately
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