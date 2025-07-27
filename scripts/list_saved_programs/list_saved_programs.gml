/// @desc Lists all .bas files in the working directory and shows them to the user
function list_saved_programs() {
    var files  = "";
    var fname  = file_find_first(working_directory + "*.bas", 0); // 0 = find files
    while (fname != "") {
        files += fname + "\n";
        fname = file_find_next();
    }
    file_find_close();

    if (files == "") {
        files = "No .bas files found.";
    }

    // Use your custom message display so it appears at the bottom of the screen
    basic_show_message(files);
}
