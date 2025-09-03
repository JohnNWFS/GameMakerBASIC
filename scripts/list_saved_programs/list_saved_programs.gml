/// scripts/list_saved_programs/list_saved_programs.gml
function list_saved_programs()
{
    var ed = instance_find(obj_editor, 0);
    if (ed == noone) { if (dbg_on(DBG_IO)) show_debug_message("[DIR] no obj_editor instance"); return; }

    if (!variable_instance_exists(ed, "dir_listing"))          ed.dir_listing = [];
    if (!variable_instance_exists(ed, "showing_dir_overlay"))  ed.showing_dir_overlay = false;

    var save_dir = get_save_directory();
    if (!is_string(save_dir) || string_length(save_dir) == 0) save_dir = working_directory;
    if (!directory_exists(save_dir)) directory_create(save_dir);

    // Persist save dir for actions
    ed.dir_save_dir = save_dir;

    // Build listing (.bas only)
    ed.dir_listing = [];
    var mask = save_dir + "*.bas";
    var fname = file_find_first(mask, 0); // IMPORTANT: 0 = no attribute filter
    var count = 0;
    while (fname != "") {
        array_push(ed.dir_listing, fname);
        count += 1;
        fname = file_find_next();
    }
    file_find_close();
    if (count == 0) array_push(ed.dir_listing, "No .bas files found.");

    // Initialize overlay state (ASCII UI)
    ed.dir_sel                 = 0;           // selected row (0-based in view)
    ed.dir_page                = 0;           // current page (0-based)
    ed.dir_page_size           = 1;           // will be recomputed in Draw each frame
    ed.dir_sorted_by           = "name";      // future use: "name"|"date"|"size"
    ed.dir_filter              = "";          // future filter text
    ed.dir_preview_on          = false;       // optional preview pane toggle
    ed.dir_confirm_active      = false;       // delete confirm modal
    ed.dir_confirm_index       = -1;          // which file index is pending delete
    ed.dir_mouse_hover_row     = -1;          // hover state (optional)
    ed.dir_mouse_hover_action  = "";          // ""|"load"|"del"

    ed.showing_dir_overlay = true;

    if (dbg_on(DBG_IO)) show_debug_message("[DIR] open path=" + save_dir + " files=" + string(count));
}
