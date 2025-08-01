/// @function handle_basic_command(cmd, arg)
/// @description Routes BASIC commands to the correct function
function handle_basic_command(cmd, arg) {
    show_debug_message("COMMAND DISPATCH: " + cmd + " | ARG: " + arg);

    switch (cmd) {
        case "PRINT":
            show_debug_message("Dispatching to PRINT");
            basic_cmd_print(arg, global.current_line_number);
            break;

        case "LET":
            show_debug_message("Dispatching to LET");
            basic_cmd_let(arg);
            break;

        case "GOTO":
            show_debug_message("Dispatching to GOTO");
            basic_cmd_goto(arg);
            break;

        case "INPUT":
            show_debug_message("Dispatching to INPUT");
            basic_cmd_input(arg);
            break;

        case "COLOR":
            show_debug_message("Dispatching to COLOR");
            basic_cmd_color(arg);
            break;

        case "CLS":
            show_debug_message("Dispatching to CLS");
            basic_cmd_cls();
            break;

        case "IF":
            show_debug_message("Dispatching to IF");
            basic_cmd_if(arg);
            break;

        case "END":
            show_debug_message("Dispatching to END");
            basic_cmd_end();
            break;

        case "REM":
            show_debug_message("REM encountered – skipping (no operation)");
            // REM is a no-op
            break;

        case "GOSUB":
            show_debug_message("Dispatching to GOSUB");
            basic_cmd_gosub(arg);
            break;

        case "RETURN":
            show_debug_message("Dispatching to RETURN");
            basic_cmd_return();
            break;

        case "FOR":
            show_debug_message("Dispatching to FOR");
            basic_cmd_for(arg);
            break;

        case "NEXT":
            show_debug_message("Dispatching to NEXT");
            basic_cmd_next(arg);
            break;

        case "WHILE":
            show_debug_message("Dispatching to WHILE");
            basic_cmd_while(arg);
            break;

        case "WEND":
            show_debug_message("Dispatching to WEND");
            basic_cmd_wend();
            break;

        case "BGCOLOR":
            show_debug_message("Dispatching to BGCOLOR");
            basic_cmd_bgcolor(arg);
            break;

		case "PAUSE":
            show_debug_message("Dispatching to PAUSE");
			basic_cmd_pause();
			break;


        default:
            // Check for implicit LET (e.g. "X = 5")
            if (string_pos("=", cmd + " " + arg) > 0) {
                var full = cmd + " " + arg;
                show_debug_message("IMPLICIT LET detected. Treating as LET: " + full);
                basic_cmd_let(full);
                break;
            }

            show_debug_message("UNKNOWN COMMAND: " + cmd);
            basic_show_message("UNKNOWN COMMAND: " + cmd);
    }
}
