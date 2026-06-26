/// Return byte size for a file, or -1 if unavailable.
function list_saved_programs__file_size(_path) {
    if (!file_exists(_path)) return -1;
    var bf = file_bin_open(_path, 0);
    var fsize = file_bin_size(bf);
    file_bin_close(bf);
    return fsize;
}

/// Add a DIR row if this filename is not already listed (case-insensitive).
function list_saved_programs__add_entry(_ed, _path, _name, _readonly) {
    if (!file_exists(_path)) return;
    for (var i = 0; i < array_length(_ed.dir_listing); i++) {
        if (string_lower(_ed.dir_listing[i]) == string_lower(_name)) return;
    }
    array_push(_ed.dir_listing, _name);
    array_push(_ed.dir_paths, _path);
    array_push(_ed.dir_readonly, _readonly);
    array_push(_ed.dir_sizes, list_saved_programs__file_size(_path));
}

/// scripts/list_saved_programs/list_saved_programs.gml
function list_saved_programs()
{
    var ed = instance_find(obj_editor, 0);
    if (ed == noone) { dbg_log(DBG_IO, "[DIR] no obj_editor instance"); return; }

    if (!variable_instance_exists(ed, "dir_listing"))         ed.dir_listing = [];
    if (!variable_instance_exists(ed, "dir_paths"))           ed.dir_paths = [];
    if (!variable_instance_exists(ed, "dir_readonly"))        ed.dir_readonly = [];
    if (!variable_instance_exists(ed, "dir_sizes"))           ed.dir_sizes = [];
    if (!variable_instance_exists(ed, "showing_dir_overlay")) ed.showing_dir_overlay = false;

    var save_dir = get_save_directory();
    if (!is_string(save_dir) || string_length(save_dir) == 0) save_dir = working_directory;
    if (!directory_exists(save_dir)) directory_create(save_dir);

    ed.dir_save_dir = save_dir;
    ed.dir_listing  = [];
    ed.dir_paths    = [];
    ed.dir_readonly = [];
    ed.dir_sizes    = [];

    var mask = save_dir + "*.bas";
    var fname = file_find_first(mask, 0);
    var count = 0;
    while (fname != "") {
        list_saved_programs__add_entry(ed, save_dir + fname, fname, false);
        count += 1;
        fname = file_find_next();
    }
    file_find_close();

    // Bundled .bas files ship with the runner (datafiles/) but live outside the save folder.
    list_saved_programs__add_entry(ed, working_directory + "autotest.bas", "autotest.bas", true);

    count = array_length(ed.dir_listing);
    if (count == 0) {
        array_push(ed.dir_listing, "No .bas files found.");
        array_push(ed.dir_paths, "");
        array_push(ed.dir_readonly, false);
        array_push(ed.dir_sizes, -1);
    }

    ed.dir_sel                 = 0;
    ed.dir_page                = 0;
    ed.dir_page_size           = 1;
    ed.dir_sorted_by           = "name";
    ed.dir_filter              = "";
    ed.dir_preview_on          = false;
    ed.dir_confirm_active      = false;
    ed.dir_confirm_index       = -1;
    ed.dir_mouse_hover_row     = -1;
    ed.dir_mouse_hover_action  = "";

    ed.showing_dir_overlay = true;

    dbg_log(DBG_IO, "[DIR] open path=" + save_dir + " files=" + string(count));
}