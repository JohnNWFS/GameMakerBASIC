/// Decode a data: URL (base64) into a text string (ASCII/UTF-8)
function editor_html_decode_data_url_to_text(data_url) {
    var comma = string_pos(",", data_url);
    if (comma <= 0) return "";
    var b64 = string_copy(data_url, comma + 1, string_length(data_url) - comma);

    var buf = buffer_base64_decode(b64); // native GMS
    if (buf <= 0) return "";
    buffer_seek(buf, buffer_seek_start, 0);

    var n = buffer_get_size(buf);
    var s = "";
    for (var i = 0; i < n; i++) {
        s += chr(buffer_read(buf, buffer_u8));
    }
    buffer_delete(buf);
    return s;
}
