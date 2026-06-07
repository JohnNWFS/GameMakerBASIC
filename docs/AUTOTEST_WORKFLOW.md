# NW-BASIC Autotest Workflow

This project has a launch-time BASIC autotest hook for fast Codex/LLM debugging.
Use it when you want to write a small NW-BASIC program, relaunch the GameMaker
runner, and inspect the program output from a file instead of copying console text.

## Files and Paths

- Test input file: `C:\Users\hoffe\Documents\BasicInterpreter\autotest.bas`
- Text transcript file: `C:\Users\hoffe\Documents\BasicInterpreter\autotest_output.txt`
- Bootstrap script: `scripts/autotest_bootstrap/autotest_bootstrap.gml`
- Transcript helper: `scripts/basic_output_commit/basic_output_commit.gml`
- Bootstrap call site: `objects/obj_editor/Step_0.gml`
- Transcript reset call site: `scripts/run_program/run_program.gml`

## Launch Behavior

When the editor reaches its Step event, `autotest_bootstrap()` checks whether
`autotest.bas` exists in the normal BASIC save directory.

If the file exists:

1. NW-BASIC loads `autotest.bas`.
2. NW-BASIC immediately calls `run_program()`.
3. `run_program()` deletes/recreates `autotest_output.txt`.
4. Committed screen output is appended to `autotest_output.txt`.
5. When the program ends, the transcript receives the same final footer text:
   `Program has ended - ESC or ENTER to return`

If `autotest.bas` does not exist, NW-BASIC starts normally in the editor.

## Transcript Format

A normal transcript begins with:

```text
# NW-BASIC AUTOTEST TRANSCRIPT
# MODE=TEXT
# SCREENSHOT=OPTIONAL
```

Then it contains the committed text-mode output, with trailing screen padding
removed for readability.

Example:

```text
# NW-BASIC AUTOTEST TRANSCRIPT
# MODE=TEXT
# SCREENSHOT=OPTIONAL

NW-BASIC AUTOTEST
AUTORUN OK
2+3=5
PASS AUTOTEST

Program has ended - ESC or ENTER to return
```

## Screenshot Flag

For graphics-mode or visual tests, put this marker anywhere in `autotest.bas`:

```basic
5 REM AUTOTEST_SCREENSHOT
```

The transcript header will change to:

```text
# MODE=SCREENSHOT
# SCREENSHOT=REQUESTED
```

That tells Codex or another LLM to inspect the running window visually rather
than trusting text output alone.

## Important Implementation Notes

- Do not call `autotest_bootstrap()` from `obj_editor` Create. That is too early.
  `global.config` and other globals may not be ready yet.
- `obj_globals` must create `global.config` before spawning `obj_editor`.
- `autotest_bootstrap()` is guarded so it refuses to run before `global.config`
  exists.
- `basic_output_commit()` is the central helper for adding visible text lines
  to `global.output_lines` and mirroring those lines to the transcript.
- `basic_wrap_and_commit()`, `basic_cmd_print()`, `basic_cmd_input()`, and
  `basic_system_message()` should route committed text through
  `basic_output_commit()` whenever possible.
- Direct drawing code, MODE 1 tile graphics, and other visual-only output will
  not appear in `autotest_output.txt`; use `AUTOTEST_SCREENSHOT` for those.

## Typical LLM Test Loop

1. Write or overwrite `C:\Users\hoffe\Documents\BasicInterpreter\autotest.bas`.
2. Launch NW-BASIC with GameMaker or `gm-cli`.
3. Wait for the program to end or reach the desired visual state.
4. Read `C:\Users\hoffe\Documents\BasicInterpreter\autotest_output.txt`.
5. If the header says `SCREENSHOT=REQUESTED`, inspect or capture the Runner
   window as well.

To disable autorun, rename or delete `autotest.bas`.
