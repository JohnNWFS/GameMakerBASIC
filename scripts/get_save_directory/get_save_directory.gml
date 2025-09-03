/// scripts/get_save_directory/get_save_directory.gml
function get_save_directory()
{
   // Check for HTML5/browser first - return empty string to skip file operations
   if (os_browser != browser_not_a_browser) {
       return ""; // HTML5 - no file system access
   }
   
   var base = "";
   
   // Handle desktop OS types
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
   else if (os_type == os_android) {
       base = "/storage/emulated/0/Documents/BasicInterpreter/";
   }
   else {
       // Unknown desktop OS - fallback to working directory
       base = working_directory;
   }
   
   // If env var resolution failed, fall back to working_directory
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