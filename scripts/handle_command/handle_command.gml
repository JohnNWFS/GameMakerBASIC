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

        case "GO":
        case "G":
            go_program_line(cmd_params);
            break;
            
        case "RUN":
            run_program();
            break;
            
        case "NEW":
            new_program();
            break;
            
        case "SAVE":
            if (os_type == os_gxgames || os_browser != browser_not_a_browser) {
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
   dbg_log(DBG_FLOW, "[CHECK] wrapper exists=" + string(function_exists(s)));
   dbg_log(DBG_FLOW, "[CHECK] raw exists=" + string(function_exists(r)));
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
    if (os_type == os_gxgames || os_browser != browser_not_a_browser) {
        var p = string_trim(cmd_params);
        var P = string_upper(p);
        if (P == "" || P == "SHOW") {
            // Show VFS (IndexedDB) saved programs — persists between sessions
            list_saved_programs();
        } else if (P == "IMPORT" || P == "PROMPT") {
            // Open file picker to import a .bas file from the user's disk into VFS
            editor_html_dir_prompt();
        } else if (string_copy(P, 1, 4) == "OPEN") {
            var arg = string_trim(string_delete(p, 1, 4));
            if (string_length(arg) == 0) {
                show_error_message("Usage: DIR OPEN <filename>");
            } else {
                editor_html_dir_open(arg);
            }
        } else if (P != "") {
            editor_html_dir_open(p);
        }
    } else {
        list_saved_programs();
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

   dbg_log(DBG_FLOW, "[PASTE] Bound. Click the game, then press Ctrl/Cmd+V.");
}
break;





	    case ":KB":
	    case ":KEYBOARD":
	    {
	        if (instance_exists(obj_mobile_kb)) {
	            obj_mobile_kb.kb_visible = !obj_mobile_kb.kb_visible;
	        }
	        break;
	    }

	    case ":LOADURL":
	        // Expect the rest of the input line to be the URL
	        import_from_url(string_trim(cmd_params));
	        break;

	    case ":DEMOS":
	    {
	        var _arg = string_trim(cmd_params);
	        var _is_desktop = (os_type != os_gxgames && os_browser == browser_not_a_browser);
	        if (!variable_global_exists("http_tags")) global.http_tags = ds_map_create();
	        if (_arg == "") {
	            if (!variable_global_exists("demos_manifest") || array_length(global.demos_manifest) == 0) {
	                if (_is_desktop) {
	                    demos_load_manifest_local();
	                } else {
	                    basic_show_message("Fetching demos from server...");
	                    var _req = http_get("https://johnnwfs.net/NW-BASIC/demos/manifest.json");
	                    global.http_tags[? _req] = ":DEMOS_MANIFEST";
	                }
	            } else {
	                demos_show_list();
	            }
	        } else if (string_digits(_arg) == _arg && real(_arg) >= 1) {
	            var _idx = real(_arg) - 1;
	            if (_is_desktop) {
	                if (!variable_global_exists("demos_manifest") || array_length(global.demos_manifest) == 0) {
	                    demos_load_manifest_local();
	                }
	                if (variable_global_exists("demos_manifest") && _idx >= 0 && _idx < array_length(global.demos_manifest)) {
	                    demos_load_file_local(_idx);
	                } else {
	                    show_error_message("No demo " + _arg + ". Type :DEMOS to see the list.");
	                }
	            } else {
	                if (!variable_global_exists("demos_manifest") || array_length(global.demos_manifest) == 0) {
	                    global.__demos_pending_load = real(_arg);
	                    basic_show_message("Fetching demos from server...");
	                    var _req2 = http_get("https://johnnwfs.net/NW-BASIC/demos/manifest.json");
	                    global.http_tags[? _req2] = ":DEMOS_MANIFEST";
	                } else {
	                    if (_idx >= 0 && _idx < array_length(global.demos_manifest)) {
	                        global.__demos_loading = true;
	                        import_from_url(global.demos_manifest[_idx][$ "url"]);
	                    } else {
	                        show_error_message("No demo " + _arg + ". Type :DEMOS to see the list.");
	                    }
	                }
	            }
	        } else {
	            show_error_message("Usage: :DEMOS  or  :DEMOS N");
	        }
	        break;
	    }
		
		

		case "QUIT":	
		case "Q":
		quit_program()
		break;

        case "SCREENEDIT":
        case "SE":
            start_screen_editor();
            break;

        case "TILEEDIT":
        case "TE":
            start_tile_editor();
            break;


			
    case "SPRITE":
        bas_sprite_command(cmd_params);
        break;

        default:
            show_error_message("SYNTAX ERROR");
            break;
    }
 }
