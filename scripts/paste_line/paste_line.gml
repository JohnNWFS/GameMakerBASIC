/// @function paste_line(index, text)
/// @description Called by JavaScript for each line of pasted text
function paste_line(index, text) {
    ds_list_add(paste_buffer, string(text));
   dbg_log(DBG_FLOW, "PASTE_MANAGER: Received line " + string(index) + ": " + string_copy(string(text), 1, 50) + "...");
}