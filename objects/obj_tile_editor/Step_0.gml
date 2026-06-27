/// @event obj_tile_editor/Step

if (status_timer > 0) status_timer -= 1;

// --- File picker modes ---
if (ui_mode == "file_load" || ui_mode == "file_save") {
    if (keyboard_check_pressed(vk_escape)) {
        ui_mode = "edit";
        keyboard_string = "";
        exit;
    }

    if (ui_mode == "file_save") {
        if (keyboard_check_pressed(vk_backspace)) {
            if (string_length(filename_input) > 0) {
                filename_input = string_copy(filename_input, 1, string_length(filename_input) - 1);
            }
        }
        if (string_length(keyboard_string) > 0) {
            filename_input += keyboard_string;
            keyboard_string = "";
        }
    }

    var total = array_length(file_list);
    if (keyboard_check_pressed(vk_up)) file_sel = max(0, file_sel - 1);
    if (keyboard_check_pressed(vk_down)) file_sel = min(max(0, total - 1), file_sel + 1);

    if (keyboard_check_pressed(vk_enter)) {
        var fname = "";
        if (ui_mode == "file_save") {
            fname = string_trim(filename_input);
            if (fname == "" && total > 0) fname = file_list[file_sel];
            if (fname == "") fname = last_filename;
        } else {
            if (total <= 0) {
                status_msg = "No .nwtile files found";
                status_timer = 120;
                ui_mode = "edit";
                exit;
            }
            fname = file_list[file_sel];
        }

        if (ui_mode == "file_save") {
            if (custom_tile_save_all(fname)) {
                last_filename = fname;
                status_msg = "Saved " + fname;
            } else {
                status_msg = "Save failed";
            }
        } else {
            if (custom_tile_load_file(fname)) {
                last_filename = fname;
                status_msg = "Loaded " + fname;
                var _ld = custom_tile_get_def(tile_code);
                if (!is_undefined(_ld)) { tile_w = _ld.w; tile_h = _ld.h; }
                else tile_editor_prepare_code(tile_code, tile_w, tile_h);
            } else {
                status_msg = "Load failed";
            }
        }
        status_timer = 180;
        ui_mode = "edit";
        keyboard_string = "";
    }
    exit;
}

// --- Edit mode ---
if (keyboard_check_pressed(vk_escape)) {
    tile_editor_exit(id);
    exit;
}

// Arrow movement with repeat
var moved = false;
var dir_x = 0;
var dir_y = 0;
if (keyboard_check(vk_left)) dir_x = -1;
else if (keyboard_check(vk_right)) dir_x = 1;
else if (keyboard_check(vk_up)) dir_y = -1;
else if (keyboard_check(vk_down)) dir_y = 1;

if (dir_x != 0 || dir_y != 0) {
    var key_id = dir_x * 10 + dir_y;
    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right)
     || keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down)) {
        repeat_key = key_id;
        repeat_timer = 14;
        moved = true;
        cursor_x = clamp(cursor_x + dir_x, 0, tile_w - 1);
        cursor_y = clamp(cursor_y + dir_y, 0, tile_h - 1);
    } else if (repeat_key == key_id) {
        repeat_timer -= 1;
        if (repeat_timer <= 0) {
            repeat_timer = 4;
            moved = true;
            cursor_x = clamp(cursor_x + dir_x, 0, tile_w - 1);
            cursor_y = clamp(cursor_y + dir_y, 0, tile_h - 1);
        }
    }
} else {
    repeat_key = 0;
}

var paint_now = keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter);
if (paint_now || (moved && (keyboard_check(vk_space) || keyboard_check(vk_enter)))) {
    custom_tile_set_bit(tile_code, cursor_x, cursor_y, !erase_mode);
}

if (keyboard_check_pressed(ord("B"))) erase_mode = !erase_mode;

if (keyboard_check_pressed(ord("C"))) {
    color_index += 1;
    fg_color = tile_editor_color_at(color_index);
}

if (keyboard_check_pressed(ord("N"))) {
    tile_code = (tile_code + 1) mod 256;
    var _nd = custom_tile_get_def(tile_code);
    if (is_undefined(_nd)) tile_editor_prepare_code(tile_code, TILE_EDITOR_DEFAULT_SIZE, TILE_EDITOR_DEFAULT_SIZE);
    else { tile_w = _nd.w; tile_h = _nd.h; }
    cursor_x = 0;
    cursor_y = 0;
}

if (keyboard_check_pressed(ord("P"))) {
    tile_code = (tile_code + 255) mod 256;
    var _pd = custom_tile_get_def(tile_code);
    if (is_undefined(_pd)) tile_editor_prepare_code(tile_code, TILE_EDITOR_DEFAULT_SIZE, TILE_EDITOR_DEFAULT_SIZE);
    else { tile_w = _pd.w; tile_h = _pd.h; }
    cursor_x = 0;
    cursor_y = 0;
}

if (keyboard_check_pressed(ord("F"))) tile_editor_flip_h(tile_code);
if (keyboard_check_pressed(ord("V"))) tile_editor_flip_v(tile_code);

if (keyboard_check_pressed(ord("X"))) {
    custom_tile_clear_bits(tile_code);
    status_msg = "Tile cleared";
    status_timer = 90;
}

if (keyboard_check_pressed(ord("R"))) {
    custom_tile_restore_code(tile_code);
    tile_editor_prepare_code(tile_code, tile_w, tile_h);
    status_msg = "Restored to font glyph";
    status_timer = 90;
}

if (keyboard_check_pressed(ord("S"))) {
    file_list = tile_editor_list_nwtile_files();
    file_sel = 0;
    filename_input = last_filename;
    ui_mode = "file_save";
    keyboard_string = "";
}

if (keyboard_check_pressed(ord("L"))) {
    file_list = tile_editor_list_nwtile_files();
    file_sel = 0;
    ui_mode = "file_load";
    keyboard_string = "";
}

// Mouse paint on zoomed grid
var layout = tile_editor_grid_layout(tile_w, tile_h, 16);
var gx0 = layout.margin;
var gy0 = layout.margin + 28;
if (mouse_x >= gx0 && mouse_x < gx0 + layout.grid_w
 && mouse_y >= gy0 && mouse_y < gy0 + layout.grid_h) {
    var mpx = floor((mouse_x - gx0) / layout.zoom);
    var mpy = floor((mouse_y - gy0) / layout.zoom);
    mpx = clamp(mpx, 0, tile_w - 1);
    mpy = clamp(mpy, 0, tile_h - 1);
    if (mouse_check_button_pressed(mb_left) || mouse_check_button(mb_left)) {
        cursor_x = mpx;
        cursor_y = mpy;
        if (mouse_check_button_pressed(mb_left)) {
            custom_tile_set_bit(tile_code, mpx, mpy, !erase_mode);
        }
    }
}