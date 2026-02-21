/// @function _beep_seq_next()
/// @desc Internal: dequeue next note/rest from global.beep_seq_queue and play; arms pause for its duration.
/// Expects: global.beep_samples map like {"C2": snd_beep_c2, "C3": snd_beep_c3, ..., "C6": snd_beep_c6}
function _beep_seq_next()
{
	
	// --- BREAK GUARD: allow ESC to abort mid-sequence ---
	if (variable_global_exists("beep_break_requested") && global.beep_break_requested) {
	    global.beep_break_requested = false;
	    beep_cancel(true); // stop and END
	    return;
	}


    if (!ds_exists(global.beep_seq_queue, ds_type_queue) || ds_queue_size(global.beep_seq_queue) == 0) {
        // Sequence finished: resume after the original statement
        global.beep_seq_active  = false;
        global.pause_in_effect  = false;

        global.interpreter_use_stmt_jump = true;
        global.interpreter_target_line   = global.beep_resume_line;
        global.interpreter_target_stmt   = global.beep_resume_stmt;
        return;
    }

    // --- Ensure the sample map exists; fall back to single sample if not ---
    if (!variable_global_exists("beep_samples") || !ds_exists(global.beep_samples, ds_type_map)) {
        // create a minimal map that points to the single C4 sample if available
        global.beep_samples = ds_map_create();
        if (variable_global_exists("beep_sound")) {
            ds_map_set(global.beep_samples, "C4", global.beep_sound);
        }
    }

    var pack = ds_queue_dequeue(global.beep_seq_queue);
    var n0   = pack[0]; // 'A'..'G' or 'R'
    var acc  = pack[1]; // -1,0,+1
    var beats= pack[2]; // real
    var oofs = pack[3]; // octave offset relative to C4

    // duration
    var bpm  = (is_real(global.beep_tempo) && global.beep_tempo > 0) ? global.beep_tempo : 120;
    var ms   = max(1, round(beats * (60.0 / bpm) * 1000));

    // rest
    if (n0 == "R") {
        if (dbg_on(DBG_FLOW)) show_debug_message("BEEP SEQ: rest " + string(ms) + "ms");
        _beep_arm_pause(ms);
        return;
    }

    // letter-to-semitone from C
    var base = 0;
    switch (n0) {
        case "C": base = 0;  break;
        case "D": base = 2;  break;
        case "E": base = 4;  break;
        case "F": base = 5;  break;
        case "G": base = 7;  break;
        case "A": base = 9;  break;
        case "B": base = 11; break;
    }

    // target octave (relative to C4)
    var target_oct = 4 + oofs;

    // ---- choose nearest base C sample (C2..C6) ----
    var base_oct = clamp(target_oct, 2, 6);
    var snd      = -1;
    var found    = false;

    // try exact, then walk outward to nearest available Cn in the map
    for (var d = 0; d <= 4 && !found; d++) {
        var o1 = clamp(base_oct - d, 2, 6);
        var o2 = clamp(base_oct + d, 2, 6);

        if (ds_map_exists(global.beep_samples, "C" + string(o1))) {
            snd = global.beep_samples[? "C" + string(o1)];
            base_oct = o1;
            found = true;
        }
        if (!found && ds_map_exists(global.beep_samples, "C" + string(o2))) {
            snd = global.beep_samples[? "C" + string(o2)];
            base_oct = o2;
            found = true;
        }
    }

    // absolute fallback: use single C4 sample if nothing mapped
    if (!found) {
        snd = variable_global_exists("beep_sound") ? global.beep_sound : -1;
        base_oct = 4;
    }

    // semitone distance from chosen base
    var semis = base + acc + ((target_oct - base_oct) * 12);

    // pitch factor (use power() in GML)
    var pitch = power(2, semis / 12);

    // play (legacy-safe path)
    if (snd != -1) {
        var inst = audio_play_sound(snd, 0, false);
        if (!is_undefined(audio_sound_pitch)) {
            // Many runtimes accept instance id here; if not, passing the asset id still works
            audio_sound_pitch(inst, pitch);
        }
    } else if (dbg_on(DBG_FLOW)) {
        show_debug_message("BEEP SEQ: no sound asset available; resting " + string(ms) + "ms");
    }

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("BEEP SEQ: " + n0 + " pitch=" + string_format(pitch, 0, 3) + " ms=" + string(ms));
    }

    _beep_arm_pause(ms);
}
