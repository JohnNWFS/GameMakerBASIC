/// scripts/get_save_directory/get_save_directory.gml
/// Return a REAL (non-sandbox) directory path as a string.
/// Desktop:   %USERPROFILE%\Documents\BasicInterpreter\  (Windows)
///            $HOME/Documents/BasicInterpreter/          (macOS/Linux)
/// HTML5:     "" (we'll handle HTML5 separately)
/// Always returns a string with a trailing slash.

/// scripts/get_save_directory/get_save_directory.gml
/// Returns a REAL (non-sandbox) save directory string with a trailing slash.
/// Desktop:
///   - Windows:  %USERPROFILE%\Documents\BasicInterpreter\
///   - macOS/Linux: $HOME/Documents/BasicInterpreter/
/// Other targets (unknown): fall back to working_directory (sandbox)
function get_save_directory()
{
    var base = "";

    // Handle known desktop OS types only; avoid referencing os_html5 (problematic in your runner)
    if (os_type == os_windows) {
        var user = environment_get_variable("USERPROFILE");
        if (is_string(user) && string_length(user) > 0) {
            base = user + "\\Documents\\BasicInterpreter\\";
        }
    }
    else if (os_type == os_macosx || os_type == os_linux) {
        var home = environment_get_variable("HOME");
        if (is_string(home) && string_length(home) > 0) {
            base = home + "/Documents/BasicInterpreter/";
        }
    }
    else {
        // Unknown / non-desktop (treat as sandbox-safe fallback)
        base = working_directory;
    }

    // If env var resolution failed, also fall back to working_directory
    if (!is_string(base) || string_length(base) == 0) {
        base = working_directory;
    }

    // Ensure trailing slash
    var last = string_copy(base, string_length(base), 1);
    if (last != "/" && last != "\\") {
        if (os_type == os_windows) base += "\\";
        else base += "/";
    }

    return base;
}



/*function get_save_directory() {
    switch(os_type) {
        case os_windows:
            return environment_get_variable("USERPROFILE") + "\\Documents\\BasicInterpreter\\";
            
        case os_macosx:
        case os_linux:
            return environment_get_variable("HOME") + "/Documents/BasicInterpreter/";
            
        case os_android:
            return "/storage/emulated/0/Documents/BasicInterpreter/";
            
        case os_ios:
            return "/Documents/BasicInterpreter/";
            
        case os_browser:
            // HTML5 - use local storage fallback since file system access is limited
            return ""; // Handle separately with localStorage
            
        default:
            return working_directory; // fallback to sandbox
    }
}
*/

