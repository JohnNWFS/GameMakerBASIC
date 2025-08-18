/// @script basic_cmd_color
/// @description Change text color (and optional background): COLOR fg[, bg]
function basic_cmd_color(arg) {
    // Split into up to two parts: foreground and optional background
    ///
	// Split on commas, but not inside parentheses
		var parts = [];
		var current = "";
		var paren_depth = 0;
		var trimmed_arg = string_trim(arg);

		for (var i = 1; i <= string_length(trimmed_arg); i++) {
		    var ch = string_char_at(trimmed_arg, i);
		    if (ch == "(") {
		        paren_depth++;
		        current += ch;
		    } else if (ch == ")") {
		        paren_depth--;
		        current += ch;
		    } else if (ch == "," && paren_depth == 0) {
		        array_push(parts, string_trim(current));
		        current = "";
		    } else {
		        current += ch;
		    }
		}
		if (string_trim(current) != "") {
		    array_push(parts, string_trim(current));
		}
	
	///
    var fgStr = string_upper(string_trim(parts[0]));
    var bgStr = (array_length(parts) > 1)
                ? string_upper(string_trim(parts[1]))
                : "";

    // Helper: parse a single color spec (named or RGB), returns -1 on error
    var parse_color = function(colSpec) {
        // RGB(r,g,b) form?
        if (string_copy(colSpec, 1, 4) == "RGB("
            && string_char_at(colSpec, string_length(colSpec)) == ")")
        {
            var inner = string_copy(colSpec, 5, string_length(colSpec) - 5);
            var comps = string_split(inner, ",");
            if (array_length(comps) == 3) {
                var r = clamp(real(string_trim(comps[0])), 0, 255);
                var g = clamp(real(string_trim(comps[1])), 0, 255);
                var b = clamp(real(string_trim(comps[2])), 0, 255);
                return make_color_rgb(r, g, b);
            } else {
                return -1;
            }
        }
        // Named color lookup
        if (ds_map_exists(global.colors, colSpec)) {
            return global.colors[? colSpec];
        }
        return -1;
    };

    // Parse and apply foreground
    var fgCol = parse_color(fgStr);
    if (fgCol >= 0) {
        global.basic_text_color   = fgCol;
        global.current_draw_color = fgCol;
    } else {
        show_debug_message("?COLOR ERROR: Unknown foreground color '" + fgStr + "'");
    }

    // Parse and apply background (if provided)
    if (bgStr != "") {
        var bgCol = parse_color(bgStr);
        if (bgCol >= 0) {
            global.background_draw_color   = bgCol;
            global.background_draw_enabled = true;
        } else {
            show_debug_message("?COLOR ERROR: Unknown background color '" + bgStr + "'");
        }
    }
}
