/// Destroys previous records and clears the list.
function editor_html_dir__reset() {
    if (!variable_global_exists("html_dir_files")) {
        global.html_dir_files = ds_list_create();
        return;
    }
    var n = ds_list_size(global.html_dir_files);
    for (var i = 0; i < n; i++) {
        var rec = global.html_dir_files[| i];
        if (ds_exists(rec, ds_type_map)) ds_map_destroy(rec);
    }
    ds_list_clear(global.html_dir_files);
}
