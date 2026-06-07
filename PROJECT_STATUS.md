# NW-BASIC Project Status

This is the canonical project status and engineering checklist for NW-BASIC. Older checklist, planning, debug, and LLM-collaboration notes are archived under `docs/archive/`.

For LLM/Codex collaborators, read `docs/LLM_PROJECT_BRIEF.md` first. It defines the product vision, mode guardrails, documentation expectations, graphics direction, and autotest workflow expectations.

## Architecture Snapshot

- `rm_editor` hosts `obj_globals`, `obj_editor`, `obj_inkey_feeder`, and editor support objects.
- `rm_basic_interpreter` hosts `obj_basic_interpreter` for MODE 0 / MODE 1 text execution.
- `rm_mode1_graphics` hosts `obj_basic_interpreter` plus `obj_mode1_grid` for MODE 2 tile graphics.
- `rm_mode2_pixel` hosts `obj_mode2_surface` plus `obj_basic_interpreter`; MODE 3 now has a surface-backed pixel drawing base.
- Mode switching is controlled by `global.current_mode` and `global.mode_rooms`.
- Preserve the current public mode model: MODE 0 / MODE 1 text, MODE 2 tile graphics with 8/16/32 cell sizes, and MODE 3 pixel room plumbing.

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
- Mode and display commands: `MODE`, `BGCOLOR`, `CLSCHAR`, `PSET` (MODE 2 tile form and MODE 3 pixel form), `CHARAT`, `PRINTAT`, `FONT`, `FONTSET`, `LOCATE`, `SCROLL`.
- File I/O: `OPEN`, `CLOSE`, `PRINT #n`, `INPUT #n`, `LINE INPUT #n`, `EOF(n)`.
- PRINT layout tokens handled by the command layer: `TAB`, `SPC`, comma zones, and trailing semicolon newline suppression.

## Completed Functions and Operators

- Operators: `+`, `-`, `*`, `/`, `\`, `%`, `MOD`, `^`, `=`, `<>`, `<`, `>`, `<=`, `>=`, `AND`, `OR`.
- Numeric functions: `RND`, `ABS`, `INT`, `EXP`, `LOG`, `LOG10`, `SGN`, `SIN`, `COS`, `TAN`, `SQR`, `ATN`.
- String/conversion functions: `STR$`, `CHR$`, `VAL`, `LEFT$`, `RIGHT$`, `MID$`, `REPEAT$`, `STRING$`, `SPACE$`, `LEN`, `ASC`, `UCASE$`, `LCASE$`, `LTRIM$`, `RTRIM$`, `INSTR`.
- System/input functions: `TIMER`, `TIME$`, `DATE$`, `INKEY$`, `EOF`.
- Mode helper functions: `GETMODE`, `SCREEN` (alias for GETMODE), `POINT` (MODE 3 pixel color readback), `mode1_get_char`, `mode1_get_color`, `mode1_color_name`.

## Autotest Workflow

- Launch-time autotest is documented in `docs/AUTOTEST_WORKFLOW.md`.
- If `C:\Users\hoffe\Documents\BasicInterpreter\autotest.bas` exists, NW-BASIC auto-loads it and runs it on launch.
- Each autotest run recreates `C:\Users\hoffe\Documents\BasicInterpreter\autotest_output.txt` and mirrors committed text output there for Codex/LLM inspection.
- Add `REM AUTOTEST_SCREENSHOT` anywhere in `autotest.bas` when a visual/window screenshot is needed, especially for MODE 2/3 graphics-mode tests.
- Delete or rename `autotest.bas` to disable autorun and start in the editor normally.
- Broad MODE 2 tile command inventory smoke test lives at `diagnostics/mode2_tile_command_inventory.bas`; copy it to `autotest.bas` and run to audit core text/flow/data/array commands plus tile display commands.
- MODE 3 pixel visual inventory smoke test lives at `diagnostics/mode3_pixel_visual_inventory.bas`; it uses `AUTOTEST_SCREENSHOT`, draws visible `PSET` color markers, prints `POINT()` readbacks, and waits in MODE 3 for screenshot inspection.

## Known Cleanup and Bug Backlog

- Review README examples against current syntax, especially arrays, remarks, MODE 2 coordinate order, and function availability.
- Run GameMaker LTS 2026 Feather/build diagnostics and capture any remaining compiler or type warnings.
- Continue HELP browser testing through subtopic selection and page navigation after topic/subtopic input was hardened.
- Update the generated HELP BASIC program: it is currently a brittle/broken BASIC program and should avoid known-bad syntax until interpreter control-flow bugs are fixed.
- Add dedicated manual/interactive inventory tests for `INPUT`, modal `INKEY$`, `PAUSE`, and editor commands (`LIST`, `RUN`, `NEW`, `SAVE`, `LOAD`, `DIR`, `HELP`, `:PASTE`, `:LOADURL`, `SCREENEDIT`, `QUIT`).

## Not Yet Implemented / Future Work

- Random/control flow: `RANDOMIZE`, `STOP`, `ON GOTO`, `ON GOSUB`.
- Additional functions: `FIX`, `CINT`, `PEEK`, `POKE`, and further math/string extensions as needed.
- Array/memory quality-of-life: `ERASE`, optional `OPTION BASE`, 3D+ arrays (2D done), and compatibility behavior review.
- Original MODE 2 tile work: broaden tile-friendly commands, editable character/tile workflows, and examples.
- Future MODE 3 drawing commands: `LINE`, `RECT`/`BOX`, `CIRCLE`, fill/paint behavior, sprite overlay commands, and richer MODE 2/3 utilities.

## Recently Completed (2026-06-07 session)

- **File I/O fully implemented:** `OPEN`, `CLOSE`, `PRINT #n`, `INPUT #n`, `LINE INPUT #n`, `EOF(n)`. Channel state lives in `global.basic_file_handles` and `global.basic_file_modes` (ds_maps, initialised in `obj_globals/Create_0.gml`, cleaned up in `reset_interpreter_state.gml`). New scripts: `basic_cmd_open`, `basic_cmd_close`, `basic_cmd_print_file`, `basic_cmd_file_read`.
- **MODE switch infinite loop fixed:** Two-part bug in `obj_basic_interpreter/Create_0.gml`. See Architecture Snapshot above.
- **SCREEN() function added** as an alias for GETMODE(). Registered in `is_function.gml` and dispatched in `evaluate_postfix.gml`.
- **FONT/FONTSET crash in MODE 0 fixed:** `basic_cmd_font` and `basic_cmd_fontset` were calling `basic_print_system_message` (an instance method on `obj_basic_interpreter`, not reachable from a script). Replaced with `basic_show_message`.
- **2D array tests:** Comprehensive 8-case test passes with FAILS=0. Inline-IF colon bug documented — use block IF/ELSE/ENDIF in tests.
- **New math/string functions:** `SQR`, `ATN`, `SPACE$`, `UCASE$`, `LCASE$`, `LTRIM$`, `RTRIM$`, `INSTR`, `STRING$`.
- **MODE 3 pixel surface implemented:** `obj_mode2_surface` now owns a room-sized GML surface in `rm_mode2_pixel`, recreates it if surfaces are lost, and draws it behind interpreter text. `PSET x,y[,color]` draws a MODE 3 pixel and `POINT(x,y)` returns the pixel color.
- **MODE 2/3 PRINT improved:** MODE 2 tile `PRINT` and MODE 3 pixel/text overlay `PRINT` now preserve mixed semicolon/comma expression output, so output like `PRINT "POINT(10,10)="; POINT(10,10)` is preserved.
- **MODE 3 visual verification added:** `diagnostics/mode3_pixel_visual_inventory.bas` confirms `MODE 3`, text overlay `PRINT`, `CLS`, `PSET`, and `POINT()` together by pausing in MODE 3 for screenshot inspection. Verified readbacks: white `16777215`, red `255`, green `32768`, blue `16711680`.
- **Public mode numbers remapped:** MODE 0 remains a text compatibility alias, MODE 1 is public text mode, MODE 2 is tile/character graphics, and MODE 3 is pixel/surface graphics. Validation after remap: MODE 2 tile inventory reports `FAILS=0`, MODE 3 pixel visual inventory shows text plus pixel markers and correct `POINT()` readbacks, and MODE 1 text alias smoke prints `SCREEN=1`.

## Recently Consolidated

- Empty script resources confirmed as orphan placeholders and removed from the GameMaker resource table.
- Historical LLM notes, debug dumps, TODOs, and alternate README notes archived under `docs/archive/2026-06-06/`.
- Runtime cleanup pass fixed duplicate GOSUB pre-scan, `:LOADURL`, `STRING$` debug logging, stale function-token registry, editor undo plumbing, and HELP menu input generation.
- `README.md` remains the public language manual; this file is the engineering source of truth.
- Block `IF` / `ELSE` / `ENDIF` smoke tests now pass.
- `INKEY$` now flushes stale run-start input and handles modal Enter/letter waits in the current smoke tests.
- Autotest autorun plus `autotest_output.txt` transcript loop added for faster LLM-assisted debugging.
- `diagnostics/mode2_tile_command_inventory.bas` currently passes with `FAILS=0`; it covers LET/assignment, math/operators, strings, arrays, FOR/NEXT, WHILE/WEND, block and inline IF, GOTO, GOSUB/RETURN, DATA/READ/RESTORE including named streams, MODE 2 PRINT/PRINTAT/CHARAT/PSET/SCROLL/FONT/FONTSET, `BEEP` no-crash, and nonblocking `INKEY$` expression use.
- Tile helper functions are still internally named `mode1_get_char`, `mode1_get_color`, and `mode1_color_name`; they remain registered as BASIC expression functions for compatibility.
