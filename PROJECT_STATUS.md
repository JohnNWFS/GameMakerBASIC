# NW-BASIC Project Status

This is the canonical project status and engineering checklist for NW-BASIC. Older checklist, planning, debug, and LLM-collaboration notes are archived under `docs/archive/`.

For LLM/Codex collaborators, read `docs/LLM_PROJECT_BRIEF.md` first. It defines the product vision, mode guardrails, documentation expectations, graphics direction, and autotest workflow expectations.

## Architecture Snapshot

- `rm_editor` hosts `obj_globals`, `obj_editor`, `obj_inkey_feeder`, and editor support objects.
- `rm_basic_interpreter` hosts `obj_basic_interpreter` for MODE 0 text execution.
- `rm_mode1_graphics` hosts `obj_basic_interpreter` plus `obj_mode1_grid` for tile graphics.
- `rm_mode2_pixel` hosts `obj_basic_interpreter`; pixel-mode behavior is reserved for future expansion.
- Mode switching is controlled by `global.current_mode` and `global.mode_rooms`.
- Preserve the current mode model: MODE 0 text, MODE 1 tile graphics with 8/16/32 cell sizes, and MODE 2 pixel room plumbing.

## Completed Commands

- Core editor/immediate commands: `RUN`, `NEW`, `SAVE`, `LOAD`, `DIR`, `HELP`, `:PASTE`, `:LOADURL`, `QUIT`, `SCREENEDIT`/`SE`, `LIST`, `LIST range`.
- Core BASIC commands: `PRINT`, `LET`, implicit assignment, `GOTO`, `INPUT`, `COLOR`, `CLS`, `END`, `REM`, `PAUSE`, `BEEP`.
- Structured flow: inline `IF`, block `IF`, `ELSEIF`, `ELSE`, `ENDIF`, `FOR`, `NEXT`, `WHILE`, `WEND`, `GOSUB`, `RETURN`.
- Data and arrays: `DATA`, `READ`, `RESTORE`, `DIM`, 1-D and multi-dimensional array assignment/access (`DIM A(M,N)`, `A(I,J) = V`, `V = A(I,J)`).
- Mode and display commands: `MODE`, `BGCOLOR`, `CLSCHAR`, `PSET`, `CHARAT`, `PRINTAT`, `FONT`, `FONTSET`, `LOCATE`, `SCROLL`.
- PRINT layout tokens handled by the command layer: `TAB`, `SPC`, comma zones, and trailing semicolon newline suppression.

## Completed Functions and Operators

- Operators: `+`, `-`, `*`, `/`, `\`, `%`, `MOD`, `^`, `=`, `<>`, `<`, `>`, `<=`, `>=`, `AND`, `OR`.
- Numeric functions: `RND`, `ABS`, `INT`, `EXP`, `LOG`, `LOG10`, `SGN`, `SIN`, `COS`, `TAN`.
- String/conversion functions: `STR$`, `CHR$`, `VAL`, `CHR$`, `LEFT$`, `RIGHT$`, `MID$`, `REPEAT$`, `STRING$`, `LEN`, `ASC`.
- System/input functions: `TIMER`, `TIME$`, `DATE$`, `INKEY$`.
- Mode helper functions: `mode1_get_char`, `mode1_get_color`, `mode1_color_name`.

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
- File I/O: `OPEN`, `CLOSE`, `EOF`, `LINE INPUT #`, `INPUT #`, `PRINT #`, and channel management.
- Array/memory quality-of-life: `ERASE`, optional `OPTION BASE`, 3D+ arrays (2D done), and compatibility behavior review.
- MODE 2 drawing commands: `PSET`/pixel variant, `LINE`, `CIRCLE`, and surface-backed drawing.
- Future graphics: sprite overlay commands and richer MODE 1/2 utilities.

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
