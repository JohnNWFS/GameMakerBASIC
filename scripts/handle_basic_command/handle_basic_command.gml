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
	
        default:
            basic_show_message("UNKNOWN COMMAND: " + cmd);
    }
}
