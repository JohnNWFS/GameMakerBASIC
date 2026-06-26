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
    basic_var_ensure();
    
    // Set the help done flag to false initially
    basic_var_set("HELP_DONE", 0);
    
    // Launch the interpreter with the help program
    run_program();
}