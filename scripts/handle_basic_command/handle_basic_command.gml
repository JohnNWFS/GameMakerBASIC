/// @function handle_basic_command(cmd, arg)
/// @description Routes BASIC commands to the correct function
function handle_basic_command(cmd, arg) {
    switch (cmd) {
        case "PRINT":
            basic_cmd_print(arg);
            break;

        case "LET":
            basic_cmd_let(arg);
            break;

        case "GOTO":
            basic_cmd_goto(arg);
            break;

        case "INPUT":
            basic_cmd_input(arg);
            break;

        case "COLOR":
            basic_cmd_color(arg);
            break;

        case "CLS":
            basic_cmd_cls();
            break;

        case "IF":
            basic_cmd_if(arg);
            break;

        case "END":
            basic_cmd_end();
            break;

        case "REM":
            // REM is a no-op, no function call needed
            break;

        case "GOSUB":
            basic_cmd_gosub(arg);
            break;

        case "RETURN":
            basic_cmd_return();
            break;

        case "FOR":
			basic_cmd_for(arg);
            break;

        case "NEXT":
            basic_cmd_next(arg);
            break;

		case "WHILE":
		    basic_cmd_while(arg);
		    break;

		case "WEND":
		    basic_cmd_wend();
		    break;


        default:
            basic_show_message("UNKNOWN COMMAND: " + cmd);
    }
}
