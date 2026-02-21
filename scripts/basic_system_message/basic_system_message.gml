	function basic_system_message(_msg, _color) {
	    if (dbg_on(DBG_FLOW)) show_debug_message("=== basic_system_message START ===");
	    if (dbg_on(DBG_FLOW)) show_debug_message("Incoming message: " + string(_msg));
	    if (dbg_on(DBG_FLOW)) show_debug_message("Incoming color arg: " + string(_color));

	    // Do NOT create here — run_program owns creation.
	    if (is_undefined(global.output_lines) || !ds_exists(global.output_lines, ds_type_list)
	    ||  is_undefined(global.output_colors) || !ds_exists(global.output_colors, ds_type_list)) {
	        if (dbg_on(DBG_FLOW)) show_debug_message("basic_system_message: output buffers not initialized; SKIPPING write.");
	        if (dbg_on(DBG_FLOW)) show_debug_message("=== basic_system_message END (skipped) ===");
	        return;
	    }

	    var wrap_width = 40; // keep in sync with PRINT path
	    var col = is_undefined(_color) ? global.current_draw_color : _color;
	    if (dbg_on(DBG_FLOW)) show_debug_message("Using color: " + string(col));

	    var text = string(_msg);
	    if (dbg_on(DBG_FLOW)) show_debug_message("Wrapping text: " + text);

	    while (string_length(text) > wrap_width) {
	        var chunk = string_copy(text, 1, wrap_width);
	        if (dbg_on(DBG_FLOW)) show_debug_message("Adding wrapped chunk: '" + chunk + "'");
	        ds_list_add(global.output_lines, chunk);
	        ds_list_add(global.output_colors, col);
	        text = string_delete(text, 1, wrap_width);
	    }

	   if (dbg_on(DBG_FLOW))  show_debug_message("Adding final remainder: '" + text + "'");
	    ds_list_add(global.output_lines, text);
	    ds_list_add(global.output_colors, col);

	    if (dbg_on(DBG_FLOW)) show_debug_message("=== basic_system_message END ===");
	}
