// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function handle_command(command) {
//	show_debug_message("HANDLE_COMMAND called with: " + string(command) + " - paste_manager_exists: " + string(instance_exists(obj_paste_manager)));
   
var original_command = string_trim(command);
    command = string_upper(original_command);
    
    // Split command from parameters to preserve case in filenames
    var space_pos = string_pos(" ", command);
    var cmd_word = "";
    var cmd_params = "";
    
    if (space_pos > 0) {
        cmd_word = string_copy(command, 1, space_pos - 1);
        cmd_params = string_trim(string_copy(original_command, space_pos + 1, string_length(original_command)));
    } else {
        cmd_word = command;
    }
    
    switch (cmd_word) {
        case "LIST":
            if (cmd_params == "") {
                list_program();
            } else {
                list_program_range(cmd_params);
            }
            break;
            
        case "RUN":
            run_program();
            break;
            
        case "NEW":
            new_program();
            break;
            
        case "SAVE":
            if (os_browser != browser_not_a_browser) {
                // HTML build → use browser_file_tools download dialog
                if (cmd_params == "") {
                    editor_html_save_program();
                } else {
                    editor_html_save_program_as(cmd_params);
                }
            } else {
                // Desktop build → use file system save
                if (cmd_params == "") {
                    save_program();
                } else {
                    save_program_as(cmd_params);
                }
            }
            break;

case "CHECK_SAVE_FUNCS":
{
    var s = "browser_show_save_dialog";
    var r = "browser_show_save_dialog_raw";
   if (dbg_on(DBG_FLOW)) show_debug_message("[CHECK] wrapper exists=" + string(function_exists(s)));
   if (dbg_on(DBG_FLOW)) show_debug_message("[CHECK] raw exists=" + string(function_exists(r)));
    break;
}


            
        case "LOAD":
            if (cmd_params == "") {
                show_error_message("FILENAME REQUIRED");
            } else {
                load_program_from(cmd_params);
            }
            break;

		
case "DIR":
    if (os_browser != browser_not_a_browser) {
        var p = string_trim(cmd_params);
        var P = string_upper(p);
        if (P == "" || P == "PROMPT") {
            editor_html_dir_prompt();
        } else if (P == "SHOW") {
            editor_html_dir_show();
        } else if (string_copy(P, 1, 4) == "OPEN") {
            var arg = string_trim(string_delete(p, 1, 4)); // after "OPEN"
            if (string_length(arg) == 0) {
                show_message("Usage: DIR OPEN <index|filename>");
            } else {
                editor_html_dir_open(arg);
            }
        } else if (P != "") {  // Only try to open if there's actually a parameter
            // convenience: if they pass a number or name directly
            editor_html_dir_open(p);
        }
        // Remove the bare else clause that was causing the double call
    } else {
        // Windows: your original code path
        if (cmd_params == "") {
            list_saved_programs();
        } else {
            list_saved_programs(); // preserve your param behavior
        }
    }
    break;

case "HELP":
	help_launch();
	break

case ":PASTE":
{
    // Desktop build: native clipboard
    if (os_browser == browser_not_a_browser) {
        editor_handle_paste_command();
        break;
    }

		editor_html_handle_paste_command();

   if (dbg_on(DBG_FLOW)) show_debug_message("[PASTE] Bound. Click the game, then press Ctrl/Cmd+V.");
}
break;





	    case ":LOADURL":
	        // Expect the rest of the input line to be the URL
	        // If your parser provides 'args', use that. Otherwise, adapt to your arg var.
	        import_from_url(string_trim(args));
	        break;
		
		

		case "QUIT":	
		case "Q":
		quit_program()
		break;

        case "SCREENEDIT":
        case "SE":
            start_screen_editor();
            break;


			
        default:
            show_error_message("SYNTAX ERROR");
            break;
    }
 }