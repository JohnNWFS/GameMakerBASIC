# NW-BASIC TODO

## Open

Task breakdown for README “Planned / Not Yet Implemented” backlog. Order is a suggested sequence; tile work and DRAW are independent tracks.

---

### 1. `FIX` and `CINT` — done (`stress_fix_cint.bas`)

---

### 2. 3-D arrays — done (`stress_arrays_3d.bas`)

Verified integers, ASC/CHR$ character codes, strings, variable indices, sum, ERASE/REDIM. No engine changes required.

---

### 3. MODE 2 tile platform (large — multiple sessions)

Runtime tile *commands* exist (`TILEDEF`, `TILEPX`, `TILESAVE`/`TILELOAD`, etc. — see `mode2_custom_tile_editor_smoke.bas`). Backlog is **authoring UI** and **map/window** semantics.

#### 3A. Interactive tile editor UI

| Task | Notes | Done when |
|------|-------|-----------|
| 3A.1 Design: entry point | From SE menu, MODE 2 program, or dedicated key — document choice | Short design note in `docs/` or TODO |
| 3A.2 Pixel grid UI | 16×16 (or configurable) edit surface for one tile code | Mouse/keys paint bits; live preview on grid |
| 3A.3 Bind to existing storage | Read/write same structures as `TILEPX` / `TILEBIT` | Edits visible to `TILE` / `TILEBIT` in BASIC |
| 3A.4 Save/load hooks | Wire UI to `TILESAVE` / `TILELOAD` paths (or shared GML helpers) | Round-trip matches smoke test |
| 3A.5 Diagnostics | `diagnostics/mode2_tile_editor_interactive.bas` + manual checklist | User-verified once |

#### 3B. Tile maps

| Task | Notes | Done when |
|------|-------|-----------|
| 3B.1 Map data model | 2-D layer of tile codes + optional per-cell FG/BG | Defined in GML; not required in BASIC syntax v1 |
| 3B.2 Map render pass | Blit map to MODE 2 grid faster than per-`TILE` loops | Demo scrolls 40×25+ map at usable frame rate |
| 3B.3 BASIC surface (optional) | e.g. `MAPLOAD`, `MAPSET`, `MAPDRAW` — or defer | README documents what shipped |

#### 3C. Window / clipping

| Task | Notes | Done when |
|------|-------|-----------|
| 3C.1 Viewport state | Origin + width/height on tile grid (and MODE 3 analogue?) | Internal API stable |
| 3C.2 Clip `PRINT`/`PRINTAT`/`TILE`/`SCROLL` | Drawing outside viewport is clipped or rejected per spec | Diagnostic with border frame |
| 3C.3 BASIC commands (optional) | e.g. `VIEW x,y,w,h` / `VIEW OFF` | README + smoke if exposed |

**Depends on:** 3A before 3B/3C is nice but not strict  
**Blocks:** nothing else on roadmap

---

### 4. `DRAW` vector strings (medium — ~2 sessions)

Classical turtle-style `DRAW "…"` (QBASIC/GW-BASIC subset). MODE 3 only; shares pen state with `LINE`/`PSET` where sensible.

| Task | Notes | Done when |
|------|-------|-----------|
| 4.1 Command grammar | `DRAW "command string"` — document supported letters (`U D L R`, `E F G H`, `M`, `C`, `S`, `A`, `B`, `P`, `N`, etc.) | README table of supported ops |
| 4.2 Parser + interpreter hook | New command in `handle_basic_command`; relative/absolute move | Invalid token → syntax error |
| 4.3 Renderer | Update pen position, optional `DRAW` scale angle | Matches QBASIC subset on test vectors |
| 4.4 Diagnostics | `diagnostics/mode3_draw_vectors.bas` — square, star, relative `M` | Visual + `POINT()` spot checks |
| 4.5 README | Example + “under consideration” → implemented | Autotest if non-interactive |

**Depends on:** MODE 3 drawing stable (already is)  
**Blocks:** nothing

---

### 5. `RESUME` / `RESUME NEXT` — done (`stress_on_error_resume.bas`)

Fault line index + stmt index saved on trap; `RESUME` / `RESUME NEXT` use statement-level jump.

---

### 6. Optional: `ERR` and `ERL` (small — ~½ session)

| Task | Notes | Done when |
|------|-------|-----------|
| 6.1 `ERL` function | Return `global.err_last_line` (or 0 if no trap) | Handler prints line |
| 6.2 `ERR` function | Map NW-BASIC error kinds to numeric codes (document table) | Division / syntax / out-of-data codes |
| 6.3 README | Document code table + handler example | Listed under optional/planned until shipped |

**Depends on:** error trap frame from §5 (can ship `ERL` earlier using existing `err_last_line`)  
**Blocks:** nothing

---

### 7. Optional: `BSAVE` / `BLOAD` on PEEK map (medium — ~1 session)

Virtual map lives in `global.peek_poke_mem` (`basic_peek` / `basic_poke` in `basic_memory.gml`). Not real hardware RAM.

| Task | Notes | Done when |
|------|-------|-----------|
| 7.1 File format | Simple header: magic, start addr, length, raw bytes | Document in README |
| 7.2 `BSAVE "file", addr, length` | Serialize range from peek map (unset addrs = 0) | Round-trip test |
| 7.3 `BLOAD "file", addr` | Load into map at offset; optional length from file | Round-trip test |
| 7.4 Channel/path rules | Reuse existing `OPEN`/path conventions or require quoted filename only | Consistent with `TILESAVE` |
| 7.5 Diagnostics | `diagnostics/stress_peek_bsave.bas` | Autotest PASS |

**Depends on:** PEEK/POKE (done)  
**Blocks:** nothing

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
