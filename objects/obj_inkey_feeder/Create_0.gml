/// @description obj_inkeyfeeder/create.gml
// You can write your code in this editor
// Make sure queue exists even if we entered a different room first
if (!variable_global_exists("__inkey_queue")) {
    global.__inkey_queue = ds_queue_create();
}
// Optional: if you want it to survive room switches
persistent = true;

 _CAP = 128;
