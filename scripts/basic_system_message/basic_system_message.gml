	function basic_system_message(_msg, _color) {
	    dbg_log(DBG_FLOW, "=== basic_system_message START ===");
	    dbg_log(DBG_FLOW, "Incoming message: " + string(_msg));
	    dbg_log(DBG_FLOW, "Incoming color arg: " + string(_color));

	    // Do NOT create here — run_program owns creation.
	    if (is_undefined(global.output_lines) || !ds_exists(global.output_lines, ds_type_list)
	    ||  is_undefined(global.output_colors) || !ds_exists(global.output_colors, ds_type_list)) {
	        if (dbg_on(DBG_FLOW)) show_debug_message("basic_system_message: output buffers not initialized; SKIPPING write.");
	        dbg_log(DBG_FLOW, "=== basic_system_message END (skipped) ===");
	        return;
	    }

	    var wrap_width = 40; // keep in sync with PRINT path
	    var col = is_undefined(_color) ? global.current_draw_color : _color;
	    dbg_log(DBG_FLOW, "Using color: " + string(col));

	    var text = string(_msg);
	    dbg_log(DBG_FLOW, "Wrapping text: " + text);

	    while (string_length(text) > wrap_width) {
	        var chunk = string_copy(text, 1, wrap_width);
	        dbg_log(DBG_FLOW, "Adding wrapped chunk: '" + chunk + "'");
	        basic_output_commit(chunk, col);
	        text = string_delete(text, 1, wrap_width);
	    }

	   dbg_log(DBG_FLOW, "Adding final remainder: '" + text + "'");
	    basic_output_commit(text, col);

	    dbg_log(DBG_FLOW, "=== basic_system_message END ===");
	}
