# NW-BASIC LLM Project Brief

This document is for Codex, ChatGPT, and any other LLM assisting with NW-BASIC.
Read it before making architectural, language, help-system, or graphics changes.

## Product Vision

NW-BASIC is intended to become a fully functional, delightful BASIC environment,
not a toy demo. The long-term ambition is a best-in-class retro-modern BASIC:
approachable like classic home-computer BASIC, but rich enough for serious text
programs, games, educational examples, and graphics experiments.

The project should eventually rival strong historical BASIC systems in practical
expressiveness while preserving the immediacy of typing line-numbered programs
and seeing them run.

## Core Experience Goals

- Keep the immediate retro feel: line numbers, `RUN`, `LIST`, `SAVE`, `LOAD`,
  `PRINT`, `INPUT`, visible errors, and playful direct experimentation.
- Make the language coherent and learnable. Features should behave consistently
  across commands, functions, editor actions, and HELP examples.
- Treat text mode as a first-class environment, not merely a debug console.
- Treat graphics modes as first-class creative environments, not bolt-ons.
- Preserve the current public mode model unless the user explicitly approves a redesign:
  MODE 0 / MODE 1 text, MODE 2 tile graphics, and MODE 3 pixel/surface graphics plumbing.
- Prefer deterministic smoke tests and small repro BASIC programs before changing
  interpreter GML.
- Maintain or improve the in-app HELP system and README whenever syntax or
  user-facing behavior changes.

## Language Direction

NW-BASIC should grow toward a broad, friendly BASIC command set:

- Text and editor fundamentals: `PRINT`, `INPUT`, `LIST`, `RUN`, `SAVE`, `LOAD`,
  `DIR`, cursor/editing support, screen editing, readable errors, and examples.
- Control flow: inline and block `IF`, `ELSEIF`, `ELSE`, `ENDIF`, `FOR/NEXT`,
  `WHILE/WEND`, `GOTO`, `GOSUB/RETURN`, and future `ON GOTO` / `ON GOSUB`.
- Data: numeric and string variables, arrays, `DATA` / `READ` / `RESTORE`,
  file I/O, and compatibility-friendly array quality-of-life features.
- Strings and math: a wide set of functions such as `INSTR`, `SPACE$`,
  `UCASE$`, `LCASE$`, trim functions, `SQR`, `ATN`, and other common BASIC
  conveniences.
- Input: reliable `INPUT`, `INKEY$`, pause/modal input patterns, and eventually
  richer keyboard/gamepad/mobile-friendly input.
- Sound: keep `BEEP` reliable and expand cautiously where it fits the BASIC feel.

## Graphics Direction

Graphics are part of the project identity.

MODE 2 is tile/character graphics. Preserve and extend its cell-based model:

- Current commands include mode/display helpers such as `MODE`, `BGCOLOR`,
  `CLSCHAR`, `PSET`, `CHARAT`, `PRINTAT`, `PLOT`, `TILE`, `DRAWSTR`, `BOX`,
  `FILL`, `HLINE`, `VLINE`, `TILEDEF`, `TILEPX`, `TILECLEAR`, `TILESAVE`,
  `TILELOAD`, `FONT`, `FONTSET`, `LOCATE`, and `SCROLL`.
- Custom tiles are bitmap masks attached to individual tile codes. The grid
  still stores character code plus foreground/background colors; custom tiles
  override only their selected codes, while all other codes use the active font
  sprite. `TILEBIT(code,x,y)` exists for deterministic readback tests.
- Future MODE 2 work should favor tile-friendly commands, character placement,
  color manipulation, scrolling, interactive tile editing, maps/windows,
  simple animation patterns, and game examples.

MODE 3 is intended for pixel/surface drawing. It is not finished yet.
Future MODE 3 commands should include pixel-perfect drawing tools such as:

- `PSET` / `PLOT`
- `LINE`
- `RECT` / `BOX`
- `CIRCLE`
- `PAINT` / fill behavior if feasible
- color and palette tools
- sprite or image overlay commands if they fit the engine and UX

When implementing graphics, add visual tests. If text transcripts are insufficient,
use the autotest screenshot flag described in `docs/AUTOTEST_WORKFLOW.md`.

## Documentation and HELP Guardrails

The HELP system and manuals are part of the product, not afterthoughts.

- Any new command or function should have a short syntax entry, a plain-English
  explanation, a tiny example, and gotchas.
- HELP examples must use syntax that the interpreter actually supports today.
- Avoid HELP programs that depend on unverified interpreter behavior.
- Keep `README.md` as the public language manual.
- Keep `PROJECT_STATUS.md` as the engineering checklist/source of truth.
- Archive obsolete planning notes rather than letting multiple TODO files compete.

## Testing Expectations for LLMs

Before changing interpreter GML:

1. Write a small NW-BASIC repro in `autotest.bas` or `diagnostics/*.bas`.
2. Run through the normal interpreter path.
3. Read `autotest_output.txt` or inspect a screenshot if requested.
4. Only then patch GML.
5. Rerun the focused repro.
6. Rerun at least one broader smoke test if the change touches shared behavior.

Prefer tests that print clear `PASS`, `FAIL`, and `AUTOTEST PASS/FAIL` lines.

## Engineering Guardrails

- Do not casually break existing modes, editor workflows, or documented commands.
- Do not remove commands or syntax just because a current test does not exercise them.
- Prefer central helpers over scattered instrumentation.
- Prefer small, understandable interpreter fixes over large rewrites.
- Be especially careful with colon-separated statements, inline IF, block IF,
  INPUT resume state, `INKEY$`, array indexing, and mode switching.
- Keep debug and transcript facilities available for future agents.

## Current Fast Test Loop

Use the autotest workflow:

- Put a BASIC test at `C:\Users\hoffe\Documents\BasicInterpreter\autotest.bas`.
- Launch NW-BASIC.
- Read `C:\Users\hoffe\Documents\BasicInterpreter\autotest_output.txt`.
- Add `REM AUTOTEST_SCREENSHOT` in the BASIC file when the result must be judged
  visually.

See `docs/AUTOTEST_WORKFLOW.md` for details.
