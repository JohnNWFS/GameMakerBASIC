# NW-BASIC Project Status

This is the canonical project status and engineering checklist for NW-BASIC. Older checklist, planning, debug, and LLM-collaboration notes are archived under `docs/archive/`.

For LLM/Codex collaborators, read `docs/LLM_PROJECT_BRIEF.md` first. It defines the product vision, mode guardrails, documentation expectations, graphics direction, and autotest workflow expectations.

## Architecture Snapshot

- `rm_editor` hosts `obj_globals`, `obj_editor`, `obj_inkey_feeder`, and editor support objects.
- `rm_basic_interpreter` hosts `obj_basic_interpreter` for MODE 0 text execution.
- `rm_mode1_graphics` hosts `obj_basic_interpreter` plus `obj_mode1_grid` for tile graphics.
- `rm_mode2_pixel` hosts `obj_basic_interpreter`; no pixel drawing surface exists yet (next task).
- Mode switching is controlled by `global.current_mode` and `global.mode_rooms`.
- Preserve the current mode model: MODE 0 text, MODE 1 tile graphics with 8/16/32 cell sizes, and MODE 2 pixel room plumbing.

### Critical MODE-switch fix (committed 2026-06-07)

`obj_basic_interpreter` is destroyed and recreated on every room transition (MODE switch). Two bugs were fixed:

1. `Create_0.gml` reset `global.interpreter_current_line_index = 0` unconditionally. Fixed: only resets when `!global.interpreter_running`.
2. Local `line_index` was always initialised to 0 in Create, then immediately written back to the global at the top of Step, clobbering the preserved value. Fixed: when running, `line_index` is seeded from the global in Create so Step starts at the right line.

See `objects/obj_basic_interpreter/Create_0.gml` lines 23–30.

## Completed Commands

- Core editor/immediate commands: `RUN`, `NEW`, `SAVE`, `LOAD`, `DIR`, `HELP`, `:PASTE`, `:LOADURL`, `QUIT`, `SCREENEDIT`/`SE`, `LIST`, `LIST range`.
- Core BASIC commands: `PRINT`, `LET`, implicit assignment, `GOTO`, `INPUT`, `COLOR`, `CLS`, `END`, `REM`, `PAUSE`, `BEEP`.
- Structured flow: inline `IF`, block `IF`, `ELSEIF`, `ELSE`, `ENDIF`, `FOR`, `NEXT`, `WHILE`, `WEND`, `GOSUB`, `RETURN`.
- Data and arrays: `DATA`, `READ`, `RESTORE`, `DIM`, 1-D and multi-dimensional array assignment/access (`DIM A(M,N)`, `A(I,J) = V`, `V = A(I,J)`).
- Mode and display commands: `MODE`, `BGCOLOR`, `CLSCHAR`, `PSET` (MODE 1 only), `CHARAT`, `PRINTAT`, `FONT`, `FONTSET`, `LOCATE`, `SCROLL`.
- File I/O: `OPEN`, `CLOSE`, `PRINT #n`, `INPUT #n`, `LINE INPUT #n`, `EOF(n)`.
- PRINT layout tokens handled by the command layer: `TAB`, `SPC`, comma zones, and trailing semicolon newline suppression.

## Completed Functions and Operators

- Operators: `+`, `-`, `*`, `/`, `\`, `%`, `MOD`, `^`, `=`, `<>`, `<`, `>`, `<=`, `>=`, `AND`, `OR`.
- Numeric functions: `RND`, `ABS`, `INT`, `EXP`, `LOG`, `LOG10`, `SGN`, `SIN`, `COS`, `TAN`, `SQR`, `ATN`.
- String/conversion functions: `STR$`, `CHR$`, `VAL`, `LEFT$`, `RIGHT$`, `MID$`, `REPEAT$`, `STRING$`, `SPACE$`, `LEN`, `ASC`, `UCASE$`, `LCASE$`, `LTRIM$`, `RTRIM$`, `INSTR`.
- System/input functions: `TIMER`, `TIME$`, `DATE$`, `INKEY$`, `EOF`.
- Mode helper functions: `GETMODE`, `SCREEN` (alias for GETMODE), `mode1_get_char`, `mode1_get_color`, `mode1_color_name`.

## Autotest Workflow

- Launch-time autotest is documented in `docs/AUTOTEST_WORKFLOW.md`.
- If `C:\Users\hoffe\Documents\BasicInterpreter\autotest.bas` exists, NW-BASIC auto-loads it and runs it on launch.
- Each autotest run recreates `C:\Users\hoffe\Documents\BasicInterpreter\autotest_output.txt` and mirrors committed text output there for Codex/LLM inspection.
- Add `REM AUTOTEST_SCREENSHOT` anywhere in `autotest.bas` when a visual/window screenshot is needed, especially for MODE 1 or future graphics-mode tests.
- Delete or rename `autotest.bas` to disable autorun and start in the editor normally.
- Broad MODE 1 command inventory smoke test lives at `diagnostics/mode1_command_inventory.bas`; copy it to `autotest.bas` and run to audit core text/flow/data/array commands plus MODE 1 display commands.

## Known Cleanup and Bug Backlog

- Review README examples against current syntax, especially arrays, remarks, MODE 1 coordinate order, and function availability.
- Run GameMaker LTS 2026 Feather/build diagnostics and capture any remaining compiler or type warnings.
- Continue HELP browser testing through subtopic selection and page navigation after topic/subtopic input was hardened.
- Update the generated HELP BASIC program: it is currently a brittle/broken BASIC program and should avoid known-bad syntax until interpreter control-flow bugs are fixed.
- Add dedicated manual/interactive inventory tests for `INPUT`, modal `INKEY$`, `PAUSE`, and editor commands (`LIST`, `RUN`, `NEW`, `SAVE`, `LOAD`, `DIR`, `HELP`, `:PASTE`, `:LOADURL`, `SCREENEDIT`, `QUIT`).

## Not Yet Implemented / Future Work

- Random/control flow: `RANDOMIZE`, `STOP`, `ON GOTO`, `ON GOSUB`.
- Additional functions: `FIX`, `CINT`, `PEEK`, `POKE`, and further math/string extensions as needed.
- Array/memory quality-of-life: `ERASE`, optional `OPTION BASE`, 3D+ arrays (2D done), and compatibility behavior review.
- **MODE 2 drawing — NEXT TASK (see section below).**
- Future graphics: sprite overlay commands and richer MODE 1/2 utilities.

## NEXT TASK: MODE 2 Pixel Drawing Surface

`BIGTEST4.bas` (`C:\Users\hoffe\Documents\BasicInterpreter\BIGTEST4.bas`) is the reference test. Copy it to `autotest.bas` and run it to verify progress. The test exercises:

```
110 PSET 10,10
120 PRINT "POINT(10,10)="; POINT(10,10)
```

Currently:
- `PSET x,y` in MODE 2 silently does nothing (the MODE 1 implementation looks for `obj_mode1_grid` which doesn't exist in `rm_mode2_pixel`).
- `POINT(x,y)` is not implemented at all.

### What needs to be built

**1. A persistent GML drawing surface in `rm_mode2_pixel`.**

Add an object — call it `obj_mode2_surface` — to `rm_mode2_pixel`. In its Create event, allocate a surface the size of the room:

```gml
// obj_mode2_surface / Create
global.mode2_surface = surface_create(room_width, room_height);
surface_set_target(global.mode2_surface);
draw_clear(c_black);
surface_reset_target();
```

In its Draw event, draw the surface to screen:

```gml
// obj_mode2_surface / Draw
if (surface_exists(global.mode2_surface)) {
    draw_surface(global.mode2_surface, 0, 0);
}
```

Register `obj_mode2_surface` in the `.yyp` and in `rm_mode2_pixel.yy`. Also guard surface recreation in `obj_basic_interpreter/Create_0.gml` or via a Step in `obj_mode2_surface` — GML surfaces are lost on focus switch and must be recreated.

**2. Implement PSET for MODE 2.**

`PSET` is dispatched from `handle_basic_command.gml`. The existing `basic_cmd_pset` (`scripts/basic_cmd_pset/basic_cmd_pset.gml`) is hardcoded for MODE 1 (looks for `obj_mode1_grid`). Add a MODE 2 branch:

```gml
// In basic_cmd_pset, add before the MODE 1 block:
if (global.current_mode == 2) {
    // Parse: PSET x, y  (color optional, default white)
    var parts = basic_parse_csv_args(arg);
    var px = real(string_trim(parts[0]));
    var py = real(string_trim(parts[1]));
    var col = c_white; // extend later for color arg
    if (surface_exists(global.mode2_surface)) {
        surface_set_target(global.mode2_surface);
        draw_set_color(col);
        draw_point(px, py);
        surface_reset_target();
    }
    return;
}
```

**3. Implement POINT(x,y) function.**

`POINT` is a 2-argument function. Add it to:
- `scripts/is_function/is_function.gml` — add `|| fn == "POINT"`.
- `scripts/evaluate_postfix/evaluate_postfix.gml` — add a `case "POINT":` handler that pops y then x, samples the surface pixel, and pushes the color integer (or -1 if surface doesn't exist):

```gml
case "POINT": {
    var _py = floor(safe_real_pop(stack));
    var _px = floor(safe_real_pop(stack));
    var _col = -1;
    if (variable_global_exists("mode2_surface") && surface_exists(global.mode2_surface)) {
        _col = surface_getpixel(global.mode2_surface, _px, _py);
    }
    array_push(stack, _col);
    break;
}
```

Note: `POINT` takes 2 args. The parser passes them as separate stack pushes (like `INSTR`). Check how `INSTR` is handled in `evaluate_postfix` to confirm the calling convention — it may need an `"POINT2"` token or similar if the tokenizer collapses multi-arg calls.

**4. Add `obj_mode2_surface` to the `.yyp` resource list and `rm_mode2_pixel`.**

Look at how `obj_mode1_grid` is registered in `A_NEW_BASIC_3.yyp` and `A_NEW_BASIC_3.resource_order` as a template, and do the same for `obj_mode2_surface`. Also add it to `rooms/rm_mode2_pixel/rm_mode2_pixel.yy` as an instance.

### Validation

After implementation, copy `BIGTEST4.bas` to `autotest.bas` and run. `POINT(10,10)` should return a non-zero value (white = 16777215) after `PSET 10,10`. The output line should read `POINT(10,10)=16777215` (or whatever `c_white` maps to as an integer).

### Handback to Claude

When PSET and POINT work end-to-end in BIGTEST4:
1. Commit all changes with a descriptive message.
2. Update `PROJECT_STATUS.md`: move MODE 2 pixel drawing from "NEXT TASK" to "Completed Commands", remove this section.
3. Run `diagnostics/mode1_command_inventory.bas` as a regression check (copy to `autotest.bas`, run, confirm `FAILS=0`).
4. Restore `datafiles/autotest.bas` (the 2D array test) to `autotest.bas` in the runtime directory.
5. Leave a note here or in a new `docs/HANDBACK_NOTE.md` describing what was done and what to tackle next (LINE, CIRCLE, etc.).

## Recently Completed (2026-06-07 session)

- **File I/O fully implemented:** `OPEN`, `CLOSE`, `PRINT #n`, `INPUT #n`, `LINE INPUT #n`, `EOF(n)`. Channel state lives in `global.basic_file_handles` and `global.basic_file_modes` (ds_maps, initialised in `obj_globals/Create_0.gml`, cleaned up in `reset_interpreter_state.gml`). New scripts: `basic_cmd_open`, `basic_cmd_close`, `basic_cmd_print_file`, `basic_cmd_file_read`.
- **MODE switch infinite loop fixed:** Two-part bug in `obj_basic_interpreter/Create_0.gml`. See Architecture Snapshot above.
- **SCREEN() function added** as an alias for GETMODE(). Registered in `is_function.gml` and dispatched in `evaluate_postfix.gml`.
- **FONT/FONTSET crash in MODE 0 fixed:** `basic_cmd_font` and `basic_cmd_fontset` were calling `basic_print_system_message` (an instance method on `obj_basic_interpreter`, not reachable from a script). Replaced with `basic_show_message`.
- **2D array tests:** Comprehensive 8-case test passes with FAILS=0. Inline-IF colon bug documented — use block IF/ELSE/ENDIF in tests.
- **New math/string functions:** `SQR`, `ATN`, `SPACE$`, `UCASE$`, `LCASE$`, `LTRIM$`, `RTRIM$`, `INSTR`, `STRING$`.

## Recently Consolidated

- Empty script resources confirmed as orphan placeholders and removed from the GameMaker resource table.
- Historical LLM notes, debug dumps, TODOs, and alternate README notes archived under `docs/archive/2026-06-06/`.
- Runtime cleanup pass fixed duplicate GOSUB pre-scan, `:LOADURL`, `STRING$` debug logging, stale function-token registry, editor undo plumbing, and HELP menu input generation.
- `README.md` remains the public language manual; this file is the engineering source of truth.
- Block `IF` / `ELSE` / `ENDIF` smoke tests now pass.
- `INKEY$` now flushes stale run-start input and handles modal Enter/letter waits in the current smoke tests.
- Autotest autorun plus `autotest_output.txt` transcript loop added for faster LLM-assisted debugging.
- `diagnostics/mode1_command_inventory.bas` currently passes with `FAILS=0`; it covers LET/assignment, math/operators, strings, arrays, FOR/NEXT, WHILE/WEND, block and inline IF, GOTO, GOSUB/RETURN, DATA/READ/RESTORE including named streams, MODE 1 PRINT/PRINTAT/CHARAT/PSET/SCROLL/FONT/FONTSET, `BEEP` no-crash, and nonblocking `INKEY$` expression use.
- MODE 1 helper functions are now registered as BASIC expression functions: `mode1_get_char`, `mode1_get_color`, and `mode1_color_name`.
