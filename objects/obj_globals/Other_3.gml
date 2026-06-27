/// @event obj_globals/Game_End
global.inkey_mode = false;
basic_memory_shutdown();

// Interpreter instance may still own a local program list until it is destroyed.
if (instance_exists(obj_basic_interpreter)) {
    with (obj_basic_interpreter) {
        if (variable_instance_exists(id, "interpreter_current_program")) {
            basic_ds_release(interpreter_current_program);
            interpreter_current_program = undefined;
        }
    }
}