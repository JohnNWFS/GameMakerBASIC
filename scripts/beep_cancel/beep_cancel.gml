/// @function beep_cancel(_end_program)
/// @desc Immediately abort any active BEEP sequence, stop audio, clear pause, and (optionally) END.
function beep_cancel(_end_program)
{
    // Stop current beep (instance or asset-safe)
    if (variable_global_exists("beep_instance")) {
        var inst = global.beep_instance;
        if (!is_undefined(inst)) {
            if (audio_is_playing(inst)) audio_stop_sound(inst);
        }
        global.beep_instance = -1;
    }

    // Clear any queued notes
    if (variable_global_exists("beep_seq_queue") && ds_exists(global.beep_seq_queue, ds_type_queue)) {
        ds_queue_clear(global.beep_seq_queue);
    }

    // Reset beep/BEEP-seq state
    global.beep_seq_active  = false;
    global.beep_waiting     = false;
    global.pause_in_effect  = false;
    if (variable_global_exists("beep_deadline_ms")) global.beep_deadline_ms = 0;

    // Ensure we won’t “resume after this segment”
    global.interpreter_use_stmt_jump = false;
    global.interpreter_target_line   = -1;
    global.interpreter_target_stmt   = 0;

    if (_end_program) {
        // Use your NW-BASIC system message helper (consistent wrap/color)
        var sys_col = variable_global_exists("system_message_color")
            ? global.system_message_color
            : (variable_global_exists("basic_text_color") ? global.basic_text_color : c_white);

        basic_system_message("ESC pressed, Beep sequence stopped, program ending.", sys_col);

        // End immediately (same effect as END)
        global.interpreter_running = false;
        global.program_has_ended   = true;
    }
}
