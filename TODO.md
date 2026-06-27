# NW-BASIC TODO

## Open

**Only remaining README backlog:** MODE 2 tile platform (§3 below). All other planned items (FIX/CINT, 3-D arrays, RESUME, ERR/ERL, BSAVE/BLOAD, DRAW) are done.

---

### 1. `FIX` and `CINT` — done (`stress_fix_cint.bas`)

---

### 2. 3-D arrays — done (`stress_arrays_3d.bas`)

Verified integers, ASC/CHR$ character codes, strings, variable indices, sum, ERASE/REDIM. No engine changes required.

---

### 3. MODE 2 tile platform (large — multiple sessions)

Runtime tile *commands* exist (`TILEDEF`, `TILEPX`, `TILESAVE`/`TILELOAD`, etc. — see `mode2_custom_tile_editor_smoke.bas`). Backlog is **authoring UI** and **map/window** semantics.

#### 3A. Interactive tile editor UI — done (`TILEEDIT` / `TE`)

| Task | Notes | Done when |
|------|-------|-----------|
| 3A.1 Design: entry point | `TILEEDIT` / `TE` from editor room (README) | Done |
| 3A.2 Pixel grid UI | 16×16 default; zoomed grid + live preview | Done — `obj_tile_editor` |
| 3A.3 Bind to existing storage | `custom_tile_set_bit` / `custom_tile_defs` | Done |
| 3A.4 Save/load hooks | `custom_tile_save_all` / `custom_tile_load_file` | Done |
| 3A.5 Diagnostics | `diagnostics/mode2_tile_editor_interactive.bas` | Manual TILEEDIT + 3 autotest asserts |

#### 3B. Tile maps — done (`mode2_tile_map_smoke.bas`)

| Task | Notes | Done when |
|------|-------|-----------|
| 3B.1 Map data model | `global.tile_maps` — per-cell char/fg/bg | Done |
| 3B.2 Map render pass | `tile_map_blit_to_grid` — one redraw per `MAPDRAW` | Done |
| 3B.3 BASIC surface | `MAPNEW`, `MAPLOAD`, `MAPSAVE`, `MAPSET`, `MAPDRAW` | Done — README |

#### 3C. Window / clipping

| Task | Notes | Done when |
|------|-------|-----------|
| 3C.1 Viewport state | Origin + width/height on tile grid (and MODE 3 analogue?) | Internal API stable |
| 3C.2 Clip `PRINT`/`PRINTAT`/`TILE`/`SCROLL` | Drawing outside viewport is clipped or rejected per spec | Diagnostic with border frame |
| 3C.3 BASIC commands (optional) | e.g. `VIEW x,y,w,h` / `VIEW OFF` | README + smoke if exposed |

**Depends on:** 3A before 3B/3C is nice but not strict  
**Blocks:** nothing else on roadmap

---

### 4. `DRAW` vector strings — done (`mode3_draw_vectors.bas`)

QBASIC-style `DRAW "…"` on MODE 3; pen/scale/angle persist across calls within a run.

---

### 5. `RESUME` / `RESUME NEXT` — done (`stress_on_error_resume.bas`)

Fault line index + stmt index saved on trap; `RESUME` / `RESUME NEXT` use statement-level jump.

---

### 6. `ERR` and `ERL` — done (`stress_err_erl.bas`)

---

### 7. `BSAVE` / `BLOAD` — done (`stress_peek_bsave.bas`)

NWBMEM1 binary format; paths under `Documents/BasicInterpreter/` with `.nwmem` default extension.

---

### Suggested implementation order

1. **FIX / CINT** — quick win, docs closure  
2. **3-D arrays** — likely small if audit shows code already supports it  
3. **RESUME + ERR/ERL** — completes error-trapping story  
4. **BSAVE / BLOAD** — optional, builds on PEEK map  
5. **DRAW** — self-contained MODE 3 feature  
6. **Tile platform (3A → 3B → 3C)** — largest UX chunk; can parallel with 4–5

---

## Completed

- [x] **BEEP tone accuracy** — replaced pitch-shifted C sample playback with generated mono `buffer_s16` tones using equal-tempered A4 = 440 Hz targets, per-note attack/release envelopes, and low-note gain compensation. User-provided recordings showed the old pitch math was close but the sample harmonics/timbre were misleading; generated sound removes that source of error.
- [x] **README examples: audit for syntax-template lines mixed into runnable code** — README code fences now contain runnable BASIC examples rather than syntax templates, and syntax-only lines are expressed as prose.
- [x] **Screen editor (SE) crashes on lines starting with a command word** — `screen_editor_commit_row` and `screen_editor_commit_row_extended` now validate the line-number token before calling `real()`.
- [x] **PRINTAT string parsing** — `basic_cmd_printat` now strips an opening quote defensively so a malformed/partial literal cannot render a stray leading quote.
- [x] **CHR$(10) linefeed in MODE 1/0 PRINT** — `basic_cmd_print_mode1` now treats character code 10 as a real line break and ignores character code 13.
- [x] **Named DATA streams (`DATA @name: v1, v2`)** — runtime DATA handling now consumes the rest of the physical line so `DATA @name:` values are not dispatched as commands; verified with `named_data_stream_readme_diagnostic.bas`.
- [x] **Pre-parser validation coverage audit** — added central command-argument guards and replaced risky user-facing `real()` / `floor(real(...))` conversions in drawing, tile, cursor, file/channel, flow, print spacing, paste/load, and DATA parsing paths. Verified by user with malformed and valid MODE 3 `BOX`/`CIRCLE` smoke tests.
- [x] **Non-ASCII characters in MODE 2 tile font** — MODE 2 text output now maps common Unicode punctuation to ASCII-safe fallbacks before tile rendering, and direct tile writes clamp/map unsupported character codes instead of drawing garbage glyphs.
