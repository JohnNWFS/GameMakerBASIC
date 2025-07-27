function basic_cmd_color(arg) {
    var color_arg = string_upper(string_trim(arg));
    var new_color = c_green; // Default fallback
    
    // Check for RGB(...) pattern
    if (string_copy(color_arg, 1, 4) == "RGB(" && string_char_at(color_arg, string_length(color_arg)) == ")") {
        var inner = string_copy(color_arg, 5, string_length(color_arg) - 5); // Remove RGB( and )
        var parts = string_split(inner, ",");
        if (array_length(parts) == 3) {
            var r = real(string_trim(parts[0]));
            var g = real(string_trim(parts[1]));
            var b = real(string_trim(parts[2]));
            // Clamp and set color
            r = clamp(r, 0, 255);
            g = clamp(g, 0, 255);
            b = clamp(b, 0, 255);
            new_color = make_color_rgb(r, g, b);
        } else {
            show_debug_message("?COLOR ERROR: Invalid RGB format: " + arg);
            return;
        }
    } else {
        // Named colors
        switch (color_arg) {
            case "RED": new_color = c_red; break;
            case "GREEN": new_color = c_green; break;
            case "BLUE": new_color = c_blue; break;
            case "WHITE": new_color = c_white; break;
            case "YELLOW": new_color = c_yellow; break;
            case "CYAN": new_color = c_teal; break;
            case "MAGENTA": new_color = c_fuchsia; break;
            case "BLACK": new_color = c_black; break;
            default:
                show_debug_message("?COLOR ERROR: Unknown color '" + arg + "'");
				new_color = global.basic_text_color; //default color if unknown
                return;
        }
    }
    
    // ✅ ONLY change the current draw color, NEVER change basic_text_color
    global.current_draw_color = new_color;
}