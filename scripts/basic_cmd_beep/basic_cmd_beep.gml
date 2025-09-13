/// @function basic_cmd_beep(arg)
/// @desc Play one or more pitched “piezo” beeps in sequence, with rests and inline octave changes.
/// Syntax:
///   BEEP <spec> [<spec> ...]
/// spec := <NOTE><DUR> | O<oct>
/// NOTE: A..G (optional # or b) or R (rest)
/// DUR : beats; 1=quarter, 2=half, 4=whole, 0.5=eighth, 0=sixteenth (=0.25)
/// O<oct> applies to subsequent notes until changed (relative to C4 = middle C)
function basic_cmd_beep(arg)
{
	// --- persisted octave across BEEP calls (default 0 = C4) ---
var cur_oct = 0;
if (variable_global_exists("beep_current_oct") && is_real(global.beep_current_oct)) {
    cur_oct = clamp(round(global.beep_current_oct), -6, 6); // safety bounds
}


    var s = string_trim(arg);
    if (s == "") {
        basic_syntax_error("BEEP requires at least one note, e.g., BEEP C1",
            global.current_line_number, global.interpreter_current_stmt_index, "BEEP_BAD_ARGS");
        return;
    }

    // If a sequence is already running, ignore re-trigger safely
    if (global.beep_waiting || (variable_global_exists("beep_seq_active") && global.beep_seq_active)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("BEEP: already active; ignoring re-trigger");
        return;
    }

    // Simple whitespace tokenizer
    var toks = [];
    {
        var i = 1, L = string_length(s), start = 1;
        while (i <= L) {
            if (string_char_at(s, i) == " ") {
                if (i > start) array_push(toks, string_trim(string_copy(s, start, i - start)));
                start = i + 1;
            }
            i++;
        }
        if (start <= L) array_push(toks, string_trim(string_copy(s, start, L - start + 1)));
    }
    if (array_length(toks) <= 0) {
        basic_syntax_error("BEEP: nothing to play",
            global.current_line_number, global.interpreter_current_stmt_index, "BEEP_EMPTY");
        return;
    }

    // Ensure queue exists
    if (!variable_global_exists("beep_seq_queue") || !ds_exists(global.beep_seq_queue, ds_type_queue)) {
        global.beep_seq_queue = ds_queue_create();
    } else {
        ds_queue_clear(global.beep_seq_queue);
    }

    var cur_oct = 0; // relative to C4
    var added   = 0;

    // Parse each token: either O<oct> or <NOTE><DUR>
    for (var k = 0; k < array_length(toks); k++) {
        var t = string_upper(string_trim(toks[k]));
        if (t == "") continue;

        // Octave change
        if (string_copy(t, 1, 1) == "O") {
            var orest = string_copy(t, 2, string_length(t) - 1);
            if (string_length(orest) == 0 || !is_numeric_string(orest)) {
                basic_syntax_error("BEEP O<octave> expects integer, e.g., O-1 or O2",
                    global.current_line_number, global.interpreter_current_stmt_index, "BEEP_BAD_OCT");
                return;
            }
            cur_oct = real(orest);
			global.beep_current_oct = cur_oct;  // persist for subsequent BEEP calls

            continue;
        }

        // NOTE + optional accidental + duration
        var n0 = string_char_at(t, 1);
        if (!(n0 == "A" || n0 == "B" || n0 == "C" || n0 == "D" || n0 == "E" || n0 == "F" || n0 == "G" || n0 == "R")) {
            basic_syntax_error("BEEP token '"+t+"' must start with A..G or R (rest), or O<octave>",
                global.current_line_number, global.interpreter_current_stmt_index, "BEEP_BAD_TOKEN");
            return;
        }

        var pos = 2;
        var acc = 0;
        if (pos <= string_length(t)) {
            var ch = string_char_at(t, pos);
            if (ch == "#" || ch == "B") { acc = (ch == "#") ? 1 : -1; pos += 1; }
        }

        var dur_str = string_copy(t, pos, string_length(t) - (pos - 1));
        if (string_length(dur_str) == 0 || !is_numeric_string(dur_str)) {
            basic_syntax_error("BEEP note '"+t+"' requires numeric duration (e.g., C1, A#0.5, R1)",
                global.current_line_number, global.interpreter_current_stmt_index, "BEEP_BAD_DUR");
            return;
        }

        var beats = real(dur_str);
        if (beats == 0) beats = 0.25;
        if (beats < 0) {
            basic_syntax_error("BEEP duration must be non-negative",
                global.current_line_number, global.interpreter_current_stmt_index, "BEEP_BAD_DUR");
            return;
        }

        // Enqueue compact tuple [note, acc, beats, oct]
        var pack = array_create(4);
        pack[0] = n0;       // 'A'..'G' or 'R'
        pack[1] = acc;      // -1,0,+1
        pack[2] = beats;    // real
        pack[3] = cur_oct;  // integer
        ds_queue_enqueue(global.beep_seq_queue, pack);
        added += 1;
    }

    if (added <= 0) {
        basic_syntax_error("BEEP: no playable notes parsed",
            global.current_line_number, global.interpreter_current_stmt_index, "BEEP_EMPTY2");
        return;
    }

    // Mark sequence active and remember where to resume after all notes
    global.beep_seq_active   = true;
    global.beep_resume_line  = global.interpreter_current_line_index;
    global.beep_resume_stmt  = global.interpreter_current_stmt_index + 1;

    // Kick off the first note (do NOT schedule resume yet)
    _beep_seq_next(); // separate script

    // Hold interpreter until sequence completes
    global.pause_in_effect = true;

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("BEEP: queued " + string(added) + " notes; pausing until sequence completes");
    }
}
