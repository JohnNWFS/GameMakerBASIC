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

- Core editor/immediate commands: `RUN`, `NEW`, `SAVE`, `LOAD`, `DIR`, `HELP`, `:PASTE`, `:LOADURL`, `QUIT`, `SCREENEDIT`/`SE`, `LIST`, `LIST range`, `GO`/`G`.
- Core BASIC commands: `PRINT`, `LET`, implicit assignment, `GOTO`, `INPUT`, `COLOR`, `CLS`, `END`, `REM`, `PAUSE`, `BEEP`.
- Structured flow: inline `IF`, block `IF`, `ELSEIF`, `ELSE`, `ENDIF`, `FOR`, `NEXT`, `WHILE`, `WEND`, `GOSUB`, `RETURN`.
- Data and arrays: `DATA`, `READ`, `RESTORE`, `DIM`, 1-D and multi-dimensional array assignment/access (`DIM A(M,N)`, `A(I,J) = V`, `V = A(I,J)`).
- Mode and display commands: `MODE`, `BGCOLOR`, `CLSCHAR`, `PSET` (MODE 2 tile form and MODE 3 pixel form), `CHARAT`, `PRINTAT`, `PLOT`, `TILE`, `DRAWSTR`, `BOX`, `FILL`, `HLINE`, `VLINE`, `TILEDEF`, `TILEPX`, `TILECLEAR`, `TILERESTORE`, `TILESAVE`, `TILELOAD`, `FONT`, `FONTSET`, `LOCATE`, `SCROLL`.
- File I/O: `OPEN`, `CLOSE`, `PRINT #n`, `INPUT #n`, `LINE INPUT #n`, `EOF(n)`.
- PRINT layout tokens handled by the command layer: `TAB`, `SPC`, comma zones, and trailing semicolon newline suppression.

## Completed Functions and Operators

- Operators: `+`, `-`, `*`, `/`, `\`, `%`, `MOD`, `^`, `=`, `<>`, `<`, `>`, `<=`, `>=`, `AND`, `OR`.
- Numeric functions: `RND`, `ABS`, `INT`, `EXP`, `LOG`, `LOG10`, `SGN`, `SIN`, `COS`, `TAN`, `SQR`, `ATN`.
- String/conversion functions: `STR$`, `CHR$`, `VAL`, `LEFT$`, `RIGHT$`, `MID$`, `REPEAT$`, `STRING$`, `SPACE$`, `LEN`, `ASC`, `UCASE$`, `LCASE$`, `LTRIM$`, `RTRIM$`, `INSTR`.
- System/input functions: `TIMER`, `TIME$`, `DATE$`, `INKEY$`, `EOF`.
- Mode helper functions: `GETMODE`, `SCREEN` (alias for GETMODE), `POINT` (MODE 3 pixel color readback), `TILECHAR`, `TILECOLOR`, `TILEBIT`, `TILENAME$`, `mode1_get_char`, `mode1_get_color`, `mode1_color_name`.

## Autotest Workflow

- Launch-time autotest is documented in `docs/AUTOTEST_WORKFLOW.md`.
- If `C:\Users\hoffe\Documents\BasicInterpreter\autotest.bas` exists, NW-BASIC auto-loads it and runs it on launch.
- Each autotest run recreates `C:\Users\hoffe\Documents\BasicInterpreter\autotest_output.txt` and mirrors committed text output there for Codex/LLM inspection.
- Add `REM AUTOTEST_SCREENSHOT` anywhere in `autotest.bas` when a visual/window screenshot is needed, especially for MODE 2/3 graphics-mode tests.
- Delete or rename `autotest.bas` to disable autorun and start in the editor normally.
- Broad MODE 2 tile command inventory smoke test lives at `diagnostics/mode2_tile_command_inventory.bas`; copy it to `autotest.bas` and run to audit core text/flow/data/array commands plus tile display commands.
- Custom MODE 2 tile editor smoke test lives at `diagnostics/mode2_custom_tile_editor_smoke.bas`; it defines a tile mask, draws it, saves it, clears it, reloads it, and verifies bits with `TILEBIT`.
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
- Original MODE 2 tile work: interactive tile editor UI, maps, windows/clipping, animation helpers, and examples.
- Future MODE 3 drawing commands: keep `PSET`/loop-based drawing as the classic slow BASIC layer, and add accelerated GML-backed commands that still look like pure BASIC to the user.

## MODE 3 Drawing Command Plan

MODE 3 should support two kinds of pixel graphics commands:

- **Classic/pure BASIC commands:** `PSET`, `POINT`, and explicit BASIC loops. These preserve old 8-bit style graphics programming and are acceptable even when slow.
- **Accelerated GML-backed commands:** BASIC commands that dispatch to GameMaker drawing primitives on the MODE 3 surface. These hide GML from the BASIC user while using the engine for speed.

Initial accelerated command roadmap:

1. `CIRCLE x,y,r[,lineColor[,fillFlag[,fillColor]]]` — outline or filled circle through GameMaker surface drawing.
2. `LINE x1,y1,x2,y2[,color[,thickness]]` — fast line drawing.
3. `BOX x1,y1,x2,y2[,lineColor[,fillFlag[,fillColor[,thickness]]]]` — outline or filled rectangle through GameMaker surface drawing.
4. `PLOT x,y[,color]` — MODE 3 point-drawing alias for `PSET`.
5. `CIRCLEF x,y,r[,color]` — possible future convenience alias for filled circles.
6. `PAINT x,y[,fillColor[,borderColor]]` — flood fill if feasible and performant.
7. Later review candidates from historical BASICs/extensions: `DRAW` vector strings, ellipse/arc options for `CIRCLE`, and sprite/image overlay commands.

## Recently Completed (2026-06-08 session)

- **README command inventory refreshed from code audit (2026-06-08):** Full audit of `handle_basic_command.gml`, `handle_command.gml`, `is_function.gml`, `evaluate_postfix.gml`, and all `basic_cmd_*` scripts. Key corrections vs. prior README:
  - Added missing commands: `LINE` (MODE 3 line drawing), `CIRCLE` (MODE 3), `ON GOTO`/`ON GOSUB`, `RANDOMIZE`, `STOP`, `ERASE`, `OPTION BASE`.
  - Added missing functions: `SQR`, `ATN`, `SPACE$`, `UCASE$`, `LCASE$`, `LTRIM$`, `RTRIM$`, `INSTR`, `STRING$`, `VAL`, `GETMODE()`/`SCREEN()`, `EOF()`.
  - Corrected `LOCATE` argument order (was listed as `col, row`; actual code is `row, col` but stores internally as `col, row` — documented as `LOCATE row, col` per BASIC convention).
  - Corrected `HLINE` and `VLINE` argument order to match implementation.
  - Corrected `BOX` (MODE 3) syntax: uses pixel coordinates and different signature than MODE 2 BOX.
  - Noted that `LOG` and `LOG10` both use base-10 (matching code; `LOG` does not compute natural log).
  - Noted that `STOP` is currently an alias for `END` (not a true breakpoint).
  - Noted that `ERASE` and `OPTION BASE` are already implemented (removed from "Not Yet Implemented").
  - Added File I/O section documenting `OPEN`, `CLOSE`, `PRINT #n`, `INPUT #n`, `LINE INPUT #n`, `EOF(n)`.
  - Added MODE 3 accelerated drawing commands section (`CIRCLE`, `LINE`, `BOX`, `PLOT`/`PSET`).
  - Clarified 2-D array support.
  - README now has a "Planned / Not Yet Implemented" section with accurate scope.

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
- **MODE 2 tile vocabulary expanded:** Added public tile aliases/functions `PLOT`, `TILE`, `DRAWSTR`, `BOX`, `FILL`, `HLINE`, `VLINE`, `TILECHAR`, `TILECOLOR`, and `TILENAME$`. `diagnostics/mode2_tile_command_inventory.bas` validates them with `FAILS=0`.
- **MODE 2 custom tile workflow added:** `TILEDEF`, `TILEPX`, `TILECLEAR`, `TILERESTORE`, `TILESAVE`, and `TILELOAD` let BASIC programs create editable bitmap-mask tiles for selected tile codes while preserving the active font sheet for normal text. `TILERESTORE code` removes a custom override so the active font glyph is used again. `TILEBIT(code,x,y)` reads back custom tile pixels for tests and program logic. `diagnostics/mode2_custom_tile_editor_smoke.bas` verifies define/draw/save/clear/load/readback and visual coexistence with standard text.

## Recently Consolidated

- Empty script resources confirmed as orphan placeholders and removed from the GameMaker resource table.
- Historical LLM notes, debug dumps, TODOs, and alternate README notes archived under `docs/archive/2026-06-06/`.
- Runtime cleanup pass fixed duplicate GOSUB pre-scan, `:LOADURL`, `STRING$` debug logging, stale function-token registry, editor undo plumbing, and HELP menu input generation.
- `README.md` remains the public language manual; this file is the engineering source of truth.
- Block `IF` / `ELSE` / `ENDIF` smoke tests now pass.
- `INKEY$` now flushes stale run-start input and handles modal Enter/letter waits in the current smoke tests.
- Autotest autorun plus `autotest_output.txt` transcript loop added for faster LLM-assisted debugging.
- `diagnostics/mode2_tile_command_inventory.bas` currently passes with `FAILS=0`; it covers LET/assignment, math/operators, strings, arrays, FOR/NEXT, WHILE/WEND, block and inline IF, GOTO, GOSUB/RETURN, DATA/READ/RESTORE including named streams, MODE 2 PRINT/PRINTAT/CHARAT/PSET/PLOT/TILE/DRAWSTR/BOX/FILL/HLINE/VLINE/SCROLL/FONT/FONTSET, `BEEP` no-crash, tile helper functions, and nonblocking `INKEY$` expression use.
- Tile helper functions are still internally named `mode1_get_char`, `mode1_get_color`, and `mode1_color_name`; they remain registered as BASIC expression functions for compatibility.
