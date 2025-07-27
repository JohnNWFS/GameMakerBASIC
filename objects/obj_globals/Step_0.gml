// obj_globals Step Event
if (room == rm_editor) {
    if (!instance_exists(obj_editor)) {
        instance_create_layer(0, 0, "Instances", obj_editor);
    }
}
