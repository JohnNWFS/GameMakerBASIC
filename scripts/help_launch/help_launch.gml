/// help_launch()
function help_launch() {
    // Always build the help topics to ensure they're current
    help_build_topics();
    
    // Save current program state
    help_snapshot_program();
    
    // Build the help browser program
    help_build_program();
    
    // Set help active flag
    global.help_active = true;
    
    // Initialize BASIC variables if they don't exist
    if (!variable_global_exists("basic_variables")) {
        global.basic_variables = ds_map_create();
    }
    
    // Set the help done flag to false initially
    global.basic_variables[? "HELP_DONE"] = 0;
    
    // Launch the interpreter with the help program
    run_program();
}