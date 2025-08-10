function dbg_on(cat) {
    return (global.debug_mask & cat) != 0;
}

