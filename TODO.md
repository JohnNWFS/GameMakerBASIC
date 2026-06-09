# NW-BASIC TODO

## Open

- [ ] **BEEP tone accuracy** — revisit note frequencies; some tones may be off. Verify all notes in the chromatic scale against standard 440 Hz tuning and check octave multipliers.
- [ ] **CHR$(10) linefeed in MODE 1/0 PRINT** — `CHR$(10)` embedded in a string does not cause the drawer to start a new line at column 0; it continues as if drawing sequentially from the same string. The draw and wrap logic needs to detect the character and treat it as a proper line break.

