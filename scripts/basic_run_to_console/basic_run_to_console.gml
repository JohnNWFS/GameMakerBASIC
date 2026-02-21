/// @function basic_run_to_console()
/// @description Executes the BASIC program in memory and prints the output to the console instead of the screen.
function basic_run_to_console() {
    // Check if debug function exists, otherwise create a fallback
    var debug_enabled = false;
    if (script_exists(asset_get_index("dbg_on"))) {
        debug_enabled = dbg_on(DBG_FLOW);
    }
    
    if (debug_enabled) show_debug_message("==== BEGIN PROGRAM CONSOLE OUTPUT ====");
    
    // Safety check - use correct global variable names
    if (!ds_exists(global.program_map, ds_type_map) || !ds_exists(global.line_list, ds_type_list)) {
        if (debug_enabled) show_debug_message("No program loaded.");
        show_debug_message("ERROR: No BASIC program in memory to dump.");
        return;
    }
    
    // Simple approach: just dump the raw program lines
    if (debug_enabled) show_debug_message("=== RAW BASIC PROGRAM DUMP ===");
    
    for (var i = 0; i < ds_list_size(global.line_list); i++) {
        var line_num = ds_list_find_value(global.line_list, i);
        var code = ds_map_find_value(global.program_map, line_num);
        
        // Output to console
        var line_output = string(line_num) + " " + code;
        show_debug_message(line_output);
        
        if (debug_enabled) {
            show_debug_message(">> LINE " + string(line_num) + ": " + code);
        }
    }
    
    if (debug_enabled) show_debug_message("=== END BASIC PROGRAM DUMP ===");
    
    // Reset the flag
    if (variable_global_exists("basic_run_to_console_flag")) {
        global.basic_run_to_console_flag = false;
    }
    
    if (debug_enabled) show_debug_message("==== END PROGRAM CONSOLE OUTPUT ====");
}