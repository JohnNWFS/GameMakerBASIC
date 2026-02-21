/// @function inkey_enqueue_ext(sc, cap)
function inkey_enqueue_ext(sc, cap) {
    inkey_enq(chr(0) + chr(sc), cap);
}