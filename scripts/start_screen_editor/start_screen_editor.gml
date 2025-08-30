// FILE: scripts/start_screen_editor/start_screen_editor.gml
/// @function start_screen_editor()
/// @description Launch the full-screen C64-style editor

function start_screen_editor() {
    show_debug_message("COMMAND: start_screen_editor called");
    
    if (global.screen_edit_mode) {
        show_debug_message("COMMAND: Screen editor already active");
        basic_show_message("Screen editor already active");
        return;
    }
    
    show_debug_message("COMMAND: Setting screen_edit_mode = true and creating obj_screen_editor");
    global.screen_edit_mode = true;
    instance_create_layer(0, 0, "Instances", obj_screen_editor);
    
    basic_show_message("Entering screen edit mode...");
}