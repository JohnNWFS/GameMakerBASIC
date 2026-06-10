/// @function _beep_seq_next()
/// @desc Internal: dequeue next note/rest from global.beep_seq_queue and play; arms pause for its duration.
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
        dbg_log(DBG_FLOW, "BEEP SEQ: rest " + string(ms) + "ms");
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

    var note_semitone = base + acc;
    var absolute_semitone_from_a4 = ((target_oct - 4) * 12) + note_semitone - 9;
    var target_hz = 440.0 * power(2, absolute_semitone_from_a4 / 12);

    var gain = (variable_global_exists("beep_volume") && is_real(global.beep_volume)) ? global.beep_volume : 1.0;
    if (target_hz < 90) gain *= 1.35;
    else if (target_hz < 140) gain *= 1.2;
    gain = clamp(gain, 0, 2);

    if (variable_global_exists("beep_instance") && is_real(global.beep_instance) && global.beep_instance >= 0) {
        audio_stop_sound(global.beep_instance);
        global.beep_instance = -1;
    }

    _beep_release_generated_sound();

    var gate = (variable_global_exists("beep_note_gate") && is_real(global.beep_note_gate))
        ? clamp(global.beep_note_gate, 0.50, 1.00)
        : 0.90;
    var tone_ms = max(1, round(ms * gate));
    var tone = _beep_create_generated_tone(target_hz, tone_ms, gain);
    global.beep_generated_sound = tone[0];
    global.beep_generated_buffer = tone[1];
    global.beep_instance = audio_play_sound(global.beep_generated_sound, 0, false);

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("BEEP SEQ: " + n0 + " target=" + string_format(target_hz, 0, 2)
            + "Hz generated"
            + " gain=" + string_format(gain, 0, 2)
            + " gate=" + string_format(gate, 0, 2)
            + " ms=" + string(ms));
    }

    _beep_arm_pause(ms);
}

function _beep_release_generated_sound()
{
    if (variable_global_exists("beep_generated_sound") && !is_undefined(global.beep_generated_sound) && global.beep_generated_sound != -1) {
        audio_free_buffer_sound(global.beep_generated_sound);
        global.beep_generated_sound = -1;
    }

    if (variable_global_exists("beep_generated_buffer") && !is_undefined(global.beep_generated_buffer) && global.beep_generated_buffer != -1) {
        buffer_delete(global.beep_generated_buffer);
        global.beep_generated_buffer = -1;
    }
}

function _beep_create_generated_tone(_hz, _ms, _gain)
{
    var sample_rate = (variable_global_exists("beep_sample_rate") && is_real(global.beep_sample_rate))
        ? clamp(round(global.beep_sample_rate), 8000, 48000)
        : 44100;

    var sample_count = max(1, round(sample_rate * max(1, _ms) / 1000));
    var byte_count = sample_count * 2;
    var buf = buffer_create(byte_count, buffer_fixed, 1);
    buffer_seek(buf, buffer_seek_start, 0);

    var amp = clamp(0.42 * _gain, 0, 0.92);
    var phase_step = (6.283185307179586 * _hz) / sample_rate;
    var attack = max(1, min(round(sample_rate * 0.006), sample_count div 4));
    var release = max(1, min(round(sample_rate * 0.010), sample_count div 4));

    for (var i = 0; i < sample_count; i++) {
        var env = 1.0;
        if (i < attack) {
            env = i / attack;
        } else if (i >= sample_count - release) {
            env = max(0, (sample_count - 1 - i) / release);
        }

        var sample = sin(i * phase_step) * amp * env;
        buffer_write(buf, buffer_s16, round(clamp(sample, -1, 1) * 32767));
    }

    var snd = audio_create_buffer_sound(buf, buffer_s16, sample_rate, 0, byte_count, audio_mono);
    return [snd, buf];
}
