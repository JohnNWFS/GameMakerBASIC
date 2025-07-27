// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function handle_command(command) {
	
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
            if (cmd_params == "") {
                save_program();
            } else {
                save_program_as(cmd_params);
            }
            break;
            
        case "LOAD":
            if (cmd_params == "") {
                show_error_message("FILENAME REQUIRED");
            } else {
                load_program_from(cmd_params);
            }
            break;
			
		case "DIR":
        list_saved_programs();
        break;

		case ":PASTE":
		editor_handle_paste_command();
		break;

			
        default:
            show_error_message("SYNTAX ERROR");
            break;
    }
 }