/// scripts/list_saved_programs/list_saved_programs.gml
function list_saved_programs()
{
    var ed = instance_find(obj_editor, 0);
    if (ed == noone) { show_debug_message("DIR -> no obj_editor instance"); return; }

    if (!variable_instance_exists(ed, "dir_listing")) ed.dir_listing = [];
    if (!variable_instance_exists(ed, "showing_dir_overlay")) ed.showing_dir_overlay = false;

    var save_dir = get_save_directory();
    if (!is_string(save_dir) || string_length(save_dir) == 0) save_dir = working_directory;
    if (!directory_exists(save_dir)) directory_create(save_dir);

    ed.dir_listing = [];
    var mask = save_dir + "*.bas";

    // IMPORTANT FIX: use 0 (no attribute filter) instead of fa_file
    var fname = file_find_first(mask, 0);
    var count = 0;
    while (fname != "") {
        array_push(ed.dir_listing, fname);
        count += 1;
        fname = file_find_next();
    }
    file_find_close();

    if (count == 0) array_push(ed.dir_listing, "No .bas files found.");
    ed.showing_dir_overlay = true;
}
