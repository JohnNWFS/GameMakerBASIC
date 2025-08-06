function list_saved_programs() {
    if (!variable_instance_exists(obj_editor, "dir_listing")) return;

    obj_editor.dir_listing = [];
    var fname = file_find_first(working_directory + "*.bas", 0); // 0 = file
    while (fname != "") {
        array_push(obj_editor.dir_listing, fname);
        fname = file_find_next();
    }
    file_find_close();

    obj_editor.showing_dir_overlay = true;

    if (array_length(obj_editor.dir_listing) == 0) {
        array_push(obj_editor.dir_listing, "No .bas files found.");
    }
}
