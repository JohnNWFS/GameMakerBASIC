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

    _beep_prepare_queue();

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

        _beep_enqueue_note(n0, acc, beats, cur_oct);
        added += 1;
    }

    if (added <= 0) {
        basic_syntax_error("BEEP: no playable notes parsed",
            global.current_line_number, global.interpreter_current_stmt_index, "BEEP_EMPTY2");
        return;
    }

    _beep_begin_sequence();

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("BEEP: queued " + string(added) + " notes; pausing until sequence completes");
    }
}

/// @function basic_cmd_tempo(arg)
/// @desc Set BEEP/PLAY tempo in beats per minute.
function basic_cmd_tempo(arg)
{
    var result = basic_eval_number_arg(arg, "TEMPO", "tempo");
    if (!result.ok) return;

    var bpm = result.value;
    if (bpm <= 0) {
        basic_arg_error("TEMPO", "tempo must be greater than 0");
        return;
    }

    global.beep_tempo = clamp(bpm, 20, 600);
    if (dbg_on(DBG_FLOW)) show_debug_message("TEMPO: " + string(global.beep_tempo));
}

/// @function basic_cmd_play(arg)
/// @desc Play a small MML subset: T, O, L, notes A-G, #/+/-, R/P rests, <, >, dotted notes.
function basic_cmd_play(arg)
{
    if (global.beep_waiting || (variable_global_exists("beep_seq_active") && global.beep_seq_active)) {
        if (dbg_on(DBG_FLOW)) show_debug_message("PLAY: already active; ignoring re-trigger");
        return;
    }

    var raw = string_trim(arg);
    if (raw == "") {
        basic_syntax_error("PLAY requires an MML string, e.g., PLAY \"T120 O4 L8 CDEFGAB>C\"",
            global.current_line_number, global.interpreter_current_stmt_index, "PLAY_BAD_ARGS");
        return;
    }

    var mml = string(basic_evaluate_expression_v2(raw));
    if (string_length(mml) == 0) {
        basic_syntax_error("PLAY string cannot be empty",
            global.current_line_number, global.interpreter_current_stmt_index, "PLAY_EMPTY");
        return;
    }

    _beep_prepare_queue();

    var added = 0;
    var i = 1;
    var L = string_length(mml);
    var cur_oct = 0;       // MML O4 maps to BEEP O0.
    var default_len = 4;   // L4 = quarter note = 1 beat.

    while (i <= L) {
        var ch = string_upper(string_char_at(mml, i));

        if (ch == " " || ch == chr(9) || ch == ",") {
            i += 1;
            continue;
        }

        if (ch == ">") {
            cur_oct = clamp(cur_oct + 1, -6, 6);
            i += 1;
            continue;
        }

        if (ch == "<") {
            cur_oct = clamp(cur_oct - 1, -6, 6);
            i += 1;
            continue;
        }

        // MN / MS / ML — note style (maps to beep_note_gate)
        if (ch == "M" && i + 1 <= L) {
            var nxt = string_upper(string_char_at(mml, i + 1));
            if (nxt == "N" || nxt == "S" || nxt == "L") {
                if (nxt == "N") global.beep_note_gate = 0.875; // normal  ~7/8
                if (nxt == "S") global.beep_note_gate = 0.50;  // staccato half
                if (nxt == "L") global.beep_note_gate = 1.00;  // legato  full
                i += 2;
                continue;
            }
            // unrecognised M-command — fall through to unknown-token error
        }

        if (ch == "T" || ch == "O" || ch == "L" || ch == "V") {
            var control = ch;
            i += 1;
            var digits = "";
            while (i <= L) {
                var dch = string_char_at(mml, i);
                if (ord(dch) < ord("0") || ord(dch) > ord("9")) break;
                digits += dch;
                i += 1;
            }

            if (digits == "") {
                basic_syntax_error("PLAY control " + control + " requires a number",
                    global.current_line_number, global.interpreter_current_stmt_index, "PLAY_BAD_CONTROL");
                return;
            }

            var num = real(digits);
            if (control == "T") {
                if (num <= 0) {
                    basic_syntax_error("PLAY tempo must be greater than 0",
                        global.current_line_number, global.interpreter_current_stmt_index, "PLAY_BAD_TEMPO");
                    return;
                }
                global.beep_tempo = clamp(num, 20, 600);
            } else if (control == "O") {
                cur_oct = clamp(num - 4, -6, 6);
            } else if (control == "V") {
                // V0-V15: map to 0.0-1.0 gain (standard MML range)
                global.beep_volume = clamp(num / 15, 0, 1);
            } else {
                if (num <= 0) {
                    basic_syntax_error("PLAY default length must be greater than 0",
                        global.current_line_number, global.interpreter_current_stmt_index, "PLAY_BAD_LENGTH");
                    return;
                }
                default_len = num;
            }
            continue;
        }

        // N — absolute note number (0-95, where N48 = middle C / C4)
        if (ch == "N") {
            i += 1;
            var n_digits = "";
            while (i <= L) {
                var ndch = string_char_at(mml, i);
                if (ord(ndch) < ord("0") || ord(ndch) > ord("9")) break;
                n_digits += ndch;
                i += 1;
            }
            if (n_digits == "") {
                basic_syntax_error("PLAY N requires a note number (0-95)",
                    global.current_line_number, global.interpreter_current_stmt_index, "PLAY_BAD_N");
                return;
            }
            var n_num = real(n_digits);

            // Consume optional length
            var nl_digits = "";
            if (i <= L && string_char_at(mml, i) == ",") {
                i += 1;
                while (i <= L) {
                    var nldch = string_char_at(mml, i);
                    if (ord(nldch) < ord("0") || ord(nldch) > ord("9")) break;
                    nl_digits += nldch;
                    i += 1;
                }
            }
            var n_denom = (nl_digits == "") ? default_len : real(nl_digits);
            if (n_denom <= 0) n_denom = default_len;
            var n_beats = 4.0 / n_denom;

            // N48 = C4; convert to semitone offset from A4 for frequency calc
            // Semitone 0=C, 1=C#, ..., in octave = floor(n/12), note = n mod 12
            var n_oct  = floor(n_num / 12);   // 0..7; N48 → oct 4
            var n_semi = n_num mod 12;         // 0=C,1=C#,...,11=B
            // Map semitone to letter + accidental
            var _note_letters = ["C","C","D","D","E","F","F","G","G","A","A","B"];
            var _note_accs    = [0,   1,  0,  1,  0,  0,  1,  0,  1,  0,  1,  0];
            var n_letter = _note_letters[n_semi];
            var n_acc    = _note_accs[n_semi];
            var n_oct_offset = clamp(n_oct - 4, -6, 6);
            _beep_enqueue_note(n_letter, n_acc, n_beats, n_oct_offset);
            added += 1;
            continue;
        }

        if (ch == "A" || ch == "B" || ch == "C" || ch == "D" || ch == "E" || ch == "F" || ch == "G" || ch == "R" || ch == "P") {
            var n0 = (ch == "P") ? "R" : ch;
            var acc = 0;
            i += 1;

            if (n0 != "R" && i <= L) {
                var ach = string_char_at(mml, i);
                if (ach == "#" || ach == "+") {
                    acc = 1;
                    i += 1;
                } else if (ach == "-") {
                    acc = -1;
                    i += 1;
                }
            }

            var len_digits = "";
            while (i <= L) {
                var lch = string_char_at(mml, i);
                if (ord(lch) < ord("0") || ord(lch) > ord("9")) break;
                len_digits += lch;
                i += 1;
            }

            var denom = (len_digits == "") ? default_len : real(len_digits);
            if (denom <= 0) {
                basic_syntax_error("PLAY note length must be greater than 0",
                    global.current_line_number, global.interpreter_current_stmt_index, "PLAY_BAD_NOTE_LENGTH");
                return;
            }

            var beats = 4.0 / denom;
            // Consume all dots: each adds half the current value (standard MML)
            while (i <= L && string_char_at(mml, i) == ".") {
                beats *= 1.5;
                i += 1;
            }

            _beep_enqueue_note(n0, acc, beats, cur_oct);
            added += 1;
            continue;
        }

        basic_syntax_error("PLAY cannot parse '" + ch + "' in " + raw,
            global.current_line_number, global.interpreter_current_stmt_index, "PLAY_BAD_TOKEN");
        return;
    }

    if (added <= 0) {
        basic_syntax_error("PLAY: no playable notes parsed",
            global.current_line_number, global.interpreter_current_stmt_index, "PLAY_EMPTY2");
        return;
    }

    _beep_begin_sequence();

    if (dbg_on(DBG_FLOW)) {
        show_debug_message("PLAY: queued " + string(added) + " notes; pausing until sequence completes");
    }
}

function _beep_prepare_queue()
{
    if (!variable_global_exists("beep_seq_queue") || !ds_exists(global.beep_seq_queue, ds_type_queue)) {
        global.beep_seq_queue = ds_queue_create();
    } else {
        ds_queue_clear(global.beep_seq_queue);
    }
}

function _beep_enqueue_note(n0, acc, beats, oct)
{
    var pack = array_create(4);
    pack[0] = n0;
    pack[1] = acc;
    pack[2] = beats;
    pack[3] = oct;
    ds_queue_enqueue(global.beep_seq_queue, pack);
}

function _beep_begin_sequence()
{
    global.beep_seq_active   = true;
    global.beep_resume_line  = global.interpreter_current_line_index;
    global.beep_resume_stmt  = global.interpreter_current_stmt_index + 1;

    _beep_seq_next();
    global.pause_in_effect = true;
}
