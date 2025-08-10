function dbg(cat, msg) {
    // Off fast-path
    if ((global.debug_mask & cat) == 0) return;

    // Per-frame quota (avoid tanking fps)
    if (global.dbg_frame_count >= global.dbg_frame_quota) {
        global.dbg_dropped_count++;
        return;
    }
    global.dbg_frame_count++;
    show_debug_message(msg);
}
