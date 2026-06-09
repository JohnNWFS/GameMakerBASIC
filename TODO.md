# NW-BASIC TODO

## Open

- [ ] **BEEP tone accuracy** — revisit note frequencies; some tones may be off. Verify all notes in the chromatic scale against standard 440 Hz tuning and check octave multipliers.
- [ ] **Screen editor (SE) crashes on lines starting with a command word** — `screen_editor_commit_row` calls `real()` on the line number token but gets the command name instead (e.g. "PRINTAT"), crashing with "unable to convert string to number". Likely a parsing issue when a line has no leading line number or the tokenizer splits incorrectly. Reproduce by editing any line in SE that begins with a BASIC command.
- [ ] **PRINTAT string parsing** — in some cases PRINTAT appears to include the opening `"` as a visible character in the output (observed in MODE 2, 32 demo). Audit string-literal stripping in the PRINTAT argument parser.
- [ ] **Non-ASCII characters in MODE 2 tile font** — the tile font only covers ASCII; non-ASCII characters (e.g. em dash `—`, smart quotes) render as wrong or garbage glyphs. Either restrict MODE 2 strings to ASCII or map common Unicode characters to safe fallbacks.
- [ ] **CHR$(10) linefeed in MODE 1/0 PRINT** — `CHR$(10)` embedded in a string does not cause the drawer to start a new line at column 0; it continues as if drawing sequentially from the same string. The draw and wrap logic needs to detect the character and treat it as a proper line break.

