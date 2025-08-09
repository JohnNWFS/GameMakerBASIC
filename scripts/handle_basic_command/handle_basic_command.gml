/// @function handle_basic_command(cmd, arg)
/// @description Routes BASIC commands (and multiple colon-separated statements) to the correct functions
function handle_basic_command(cmd, arg) {
    // Rebuild the full statement (so we catch any colons in the original)
    var full = string_trim(cmd + (string_length(arg) ? " " + arg : ""));

    // Split on unquoted, top-level colons.
    // (Reuse your split_on_unquoted_semicolons logic, but look for ':' instead of ';'.)
    var parts = split_on_unquoted_colons(full);

    // Dispatch each sub-statement in turn
    for (var i = 0; i < array_length(parts); i++) {
        var stmt = string_trim(parts[i]);
        if (stmt == "") continue;

        show_debug_message("DISPATCH PART: " + stmt);

        // Strip any trailing REM
        stmt = strip_basic_remark(stmt);

        // Pull off the verb vs. the rest
        var sp = string_pos(" ", stmt);
        var verb, rest;
        if (sp > 0) {
            verb = string_upper(string_copy(stmt, 1, sp - 1));
            rest = string_trim(string_copy(stmt, sp + 1, string_length(stmt)));
        } else {
            verb = string_upper(stmt);
            rest = "";
        }

        show_debug_message("COMMAND DISPATCH: " + verb + " | ARG: " + rest);

        switch (verb) {
            case "PRINT":
                basic_cmd_print(rest, global.current_line_number);
                break;
            case "LET":
                basic_cmd_let(rest);
                break;
            case "GOTO":
                basic_cmd_goto(rest);
                break;
            case "INPUT":
                basic_cmd_input(rest);
                break;
            case "COLOR":
                basic_cmd_color(rest);
                break;
            case "CLS":
                basic_cmd_cls();
                break;
            case "IF":
                basic_cmd_if(rest);
                break;
            case "ELSEIF":
                basic_cmd_elseif(rest);
                break;
            case "ELSE":
                basic_cmd_else();
                break;
            case "ENDIF":
                basic_cmd_endif();
                break;
            case "FOR":
                basic_cmd_for(rest);
                break;
            case "NEXT":
                basic_cmd_next(rest);
                break;
            case "WHILE":
                basic_cmd_while(rest);
                break;
            case "WEND":
                basic_cmd_wend();
                break;
            case "GOSUB":
                basic_cmd_gosub(rest);
                break;
            case "RETURN":
                basic_cmd_return();
                break;
            case "BGCOLOR":
                basic_cmd_bgcolor(rest);
                break;
            case "PAUSE":
                basic_cmd_pause();
                break;
            case "MODE":
                basic_cmd_mode(rest);
                break;
            case "CLSCHAR":
                basic_cmd_clschar(rest);
                break;
            case "PSET":
                basic_cmd_pset(rest);
                break;
            case "CHARAT":
                basic_cmd_charat(rest);
                break;
            case "PRINTAT":
                basic_cmd_printat(rest);
                break;
            case "FONT":
                basic_cmd_font(rest);
                break;
            case "DIM":
                // Preallocate zero-filled 1-D arrays; inclusive upper bound (0..N)
                basic_cmd_dim(rest);
                break;
            case "END":
                basic_cmd_end();
                break;
            case "REM":
                // no-op
                break;
            default:
                // implicit LET?  e.g.  "X = 5"
                if (string_pos("=", verb + " " + rest) > 0) {
                    basic_cmd_let(verb + " " + rest);
                } else {
                    basic_show_message("UNKNOWN COMMAND: " + verb);
                }
                break;
        }
    }
}

