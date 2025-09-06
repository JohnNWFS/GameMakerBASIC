/// @function paste_line(index, text)
/// @description Called by JavaScript for each line of pasted text
function paste_line(index, text) {
    ds_list_add(paste_buffer, string(text));
   if (dbg_on(DBG_FLOW)) show_debug_message("PASTE_MANAGER: Received line " + string(index) + ": " + string_copy(string(text), 1, 50) + "...");
}