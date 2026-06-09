# NW-BASIC TODO

## Open


## Completed

- [x] **BEEP tone accuracy** — replaced pitch-shifted C sample playback with generated mono `buffer_s16` tones using equal-tempered A4 = 440 Hz targets, per-note attack/release envelopes, and low-note gain compensation. User-provided recordings showed the old pitch math was close but the sample harmonics/timbre were misleading; generated sound removes that source of error.
- [x] **README examples: audit for syntax-template lines mixed into runnable code** — README code fences now contain runnable BASIC examples rather than syntax templates, and syntax-only lines are expressed as prose.
- [x] **Screen editor (SE) crashes on lines starting with a command word** — `screen_editor_commit_row` and `screen_editor_commit_row_extended` now validate the line-number token before calling `real()`.
- [x] **PRINTAT string parsing** — `basic_cmd_printat` now strips an opening quote defensively so a malformed/partial literal cannot render a stray leading quote.
- [x] **CHR$(10) linefeed in MODE 1/0 PRINT** — `basic_cmd_print_mode1` now treats character code 10 as a real line break and ignores character code 13.
- [x] **Named DATA streams (`DATA @name: v1, v2`)** — runtime DATA handling now consumes the rest of the physical line so `DATA @name:` values are not dispatched as commands; verified with `named_data_stream_readme_diagnostic.bas`.
- [x] **Pre-parser validation coverage audit** — added central command-argument guards and replaced risky user-facing `real()` / `floor(real(...))` conversions in drawing, tile, cursor, file/channel, flow, print spacing, paste/load, and DATA parsing paths. Verified by user with malformed and valid MODE 3 `BOX`/`CIRCLE` smoke tests.
- [x] **Non-ASCII characters in MODE 2 tile font** — MODE 2 text output now maps common Unicode punctuation to ASCII-safe fallbacks before tile rendering, and direct tile writes clamp/map unsupported character codes instead of drawing garbage glyphs.
