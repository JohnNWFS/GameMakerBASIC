# NW-BASIC Potential Fixes & Observations

**Review Date**: 2026-06-25
**Reviewer**: Grok (read-only analysis)
**Scope**: Full codebase review with emphasis on "reinventing the wheel" vs. native GML capabilities.

---

## Executive Summary

NW-BASIC is a remarkably complete and ambitious embedded BASIC interpreter. The functionality (editor, three graphics modes, structured control flow, arrays, DATA, file I/O, sprites, generated sound, HELP system, autotest workflow) is impressive for a GameMaker project.

The code style is very "classic GML" (pre-2.3/2.3+ idioms): heavy use of `ds_map`/`ds_list`/`ds_stack`, one function per script file, pervasive globals, and manual char-by-char parsing. It gets the job done but creates maintenance burden and duplicates work that modern GML handles elegantly.

**Biggest areas of reinvention (ranked by impact):**

1. **BASIC arrays** — manual ds_list + flattening instead of native GML arrays.
2. **MODE 2 tile grid** — 1D array of structs with manual math instead of `ds_grid` or 2D arrays.
3. **User sprite system** — massive parallel state machine + hex parsing + object-per-sprite instead of leveraging GameMaker sprites/surfaces.
4. **Variable storage & many other collections** — ds_map everywhere.
5. **Tokenizer / statement splitter** — lots of duplicated quote-aware scanning logic.
6. **General ds_* usage in 2026** instead of structs + arrays.

The interpreter core (tokenizer, shunting-yard, postfix evaluator, command dispatch) is *necessary* reinvention for hosting a language — those are not candidates for "just use GML".

---

## Overall Code Quality Opinion

### Strengths
- Very strong testing discipline (autotest.bas + diagnostics/*.bas + AUTOTEST_SCREENSHOT).
- Careful attention to classic BASIC semantics (OPTION BASE, 1-based arrays, colon statements, REM rules, etc.).
- Good separation of concerns in many command scripts.
- Excellent debug/logging infrastructure for LLM-assisted development.
- Graphics modes are first-class (especially the MODE 2 custom tiles + MODE 3 surface).
- Sound generation is sophisticated and correct (buffer synthesis).
- File I/O channels correctly wrap GML primitives.
- Room/MODE switching and state preservation logic was fixed thoughtfully.

### Weaknesses
- **Extremely high file count** from "one function = one script resource". Navigation and refactoring are painful.
- Heavy global mutable state + complex "pause dance" (pause_in_effect, resume_stmt_index, etc.) makes control flow hard to follow.
- Repeated parsing logic (colons, REM stripping, CSV, colors, quotes) across many files.
- Manual memory management of dozens of ds_* structures; easy to leak or double-destroy.
- Performance micro-inefficiencies (sort line_list every step, repeated scans).
- Some functions still use older GML patterns even though newer helpers exist (e.g., `string_split` is used in places but custom splitters duplicate work).
- Very few structs; almost everything is ds_* or raw arrays of primitives.

---

## Reinventing the Wheel — Specific Callouts

### 1. BASIC Arrays (Highest Impact)

**Location**: `basic_cmd_dim.gml`, `basic_array_init.gml`, `basic_array_get.gml`, `basic_array_set.gml`, `basic_assign_to_array.gml`, evaluate_postfix array handling, `global.basic_arrays`, `global.basic_array_dims`

**Current approach**:
- Name → ds_list (flat storage)
- Separate ds_map for dimension sizes
- Manual row-major stride calculation in get/set
- Option base handling done in GML code

**GML already does this better**:
- Since GMS 2.3, `[]` arrays support true multi-dimensional access: `arr[3,4] = 99; val = arr[i,j];`
- Native arrays are garbage-collected, support `array_length()`, `array_resize()`, `array_create()`, etc.
- No manual flattening, no separate dim map, far less code.

**Recommendation**: Migrate BASIC arrays to native GML arrays (with wrapper for OPTION BASE and the BASIC name table). Keep the variable name → array mapping (or use a struct).

**Importance**: **Critical** (maintenance + bugs + performance)

---

### 2. MODE 2 Tile Grid

**Location**: `obj_mode1_grid/Create_0.gml`, `Draw_0.gml`, `mode1_grid_*` scripts (`mode1_grid_set`, `mode1_grid_fill`, etc.), TILE/PRINTAT/CHARAT commands.

**Current approach**:
- `grid = array_create(cols * rows)` (1D)
- Manual `i = x + y * cols`
- Each cell is a struct `{char, fg, bg}`
- Many manual loops to fill/clear/scroll

**Better GML options**:
- `ds_grid` is literally designed for this (rectangular cell data with region operations, add, copy, etc.).
- Or true 2D array: `grid[col][row] = {char,fg,bg};`
- `ds_grid_set_region`, `ds_grid_add_disk` etc. would simplify BOX/FILL/SCROLL dramatically.

**Importance**: **High**

---

### 3. Custom Sprite System (SPRITE DEF / SHOW / etc.)

**Location**: `bas_sprite_*` family, `obj_bas_sprite`, `bas_sprite_command`, `bas_sprite_build`, `bas_sprite_fn`

**Current approach**:
- 9+ parallel global arrays indexed by slot (defined, pixels, mode, fg, bg, gmspr, visible, x, y, angle, scale, inst...)
- Manual hex string → bit array parsing
- Spawns `obj_bas_sprite` instances
- Separate mono vs color path
- Manual collision via `SPRITEHIT`

**GML is vastly better suited**:
- Use actual GML `sprite_*` functions + `sprite_create_from_surface` or vertex buffers.
- Or, for retro pixel art, just keep pixel data in a 2D array/surface and draw it directly in one place (no per-sprite objects).
- Rotation/scaling/collision already exist (`draw_sprite_ext`, `point_distance`, `collision_circle`).

This is one of the largest areas of reinvented wheel in the project.

**Importance**: **High**

---

### 4. Variable Storage & General Data Structures

**Location**: `global.basic_variables = ds_map_create()`, many other globals in `obj_globals/Create_0.gml`

**Current**: Everything is ds_map keyed by uppercased string name.

**Modern alternative**:
- A single `global.vars = {}` struct (or a dedicated struct per scope later).
- For case-insensitive lookup you can still normalize keys or use a small wrapper.
- Structs + `variable_struct_*` functions are cleaner, have better introspection, and don't require `ds_exists` checks everywhere.

Many other internal structures (undo stack, history, config, help) could be arrays/structs.

**Importance**: **Medium-High** (improves safety + modernity)

---

### 5. Quote-Aware & REM-Aware Splitting (Duplicated Logic)

**Files**: `split_on_unquoted_colons.gml`, `split_on_unquoted_commas.gml`, `split_on_unquoted_semicolons.gml`, multiple places in `handle_basic_command`, `basic_cmd_dim`, `basic_cmd_open`, tokenizer, etc.

There are several hand-written state machines that scan for top-level delimiters while tracking `"` and `(` depth + apostrophe comments.

**Observation**: This is *somewhat* justified because BASIC statement rules are not simple `string_split`. However:
- The logic is duplicated in at least 5-6 places.
- A single robust `split_basic_statements`, `split_csv_basic`, `find_top_level` helper would be better.

Also note they already use the built-in `string_split` in some newer code (e.g. array indices). Inconsistency.

**Importance**: **Medium**

---

### 6. Color System

`global.colors` ds_map + `basic_parse_color` + custom `__hex_byte` / `__hex_nibble`.

GML already gives you:
- `c_red`, `c_green`, etc.
- `make_color_rgb(r,g,b)`
- `make_color_hsv`
- `color_get_red` etc.

The name lookup map is convenient for BASIC users. The hex parser could be simplified using `int64("0x"+...)` or `real` tricks in modern GML.

**Importance**: **Low-Medium** (works, but could be thinner)

---

### 7. Tokenizer & Expression Parser

**Files**: `basic_tokenize_expression_v2.gml`, `infix_to_postfix.gml`, `evaluate_postfix.gml`, `basic_evaluate_expression_v2.gml`

This is **core language implementation**. It is not "reinventing the wheel" in the bad sense — you must write a parser for a custom language.

However:
- The tokenizer is extremely verbose char-by-char.
- `infix_to_postfix` has special cases for arrays, zero-arg functions, STRING$, etc. that make it fragile.
- Lots of manual string manipulation instead of using newer string functions.

**Not a candidate for "use GML function instead"** — but could be refactored for clarity.

**Importance**: Observational / Refactor only

---

### 8. Audio (BEEP/PLAY)

Uses `buffer_create`, `buffer_write`, `audio_create_buffer_sound`, `audio_play_sound`, envelopes, etc.

**This is actually good use of GML**, not reinvention. GameMaker does not expose a simple "play tone at frequency" function. Building waveforms via buffers is the documented advanced path.

The complexity lives in the right place (dedicated beep scripts).

**Verdict**: Keep / only simplify if desired. Not a "GML would be better" situation.

---

### 9. File I/O Channels

Thin wrapper around `file_text_open_read/write/append`, `file_text_close`, `file_text_read_string`, etc. + channel map.

This correctly delivers the classic BASIC `#n` experience. Appropriate use of GML primitives.

**Verdict**: Fine.

---

### 10. Manual Memory / Reset Hygiene

`reset_interpreter_state.gml` and various Destroy events do a lot of `ds_map_clear`, `ds_list_destroy` etc.

The system is complex enough that leaks or use-after-destroy bugs are likely over time (especially across MODE switches and repeated RUN/NEW).

**Recommendation**:
- Centralize creation of all major ds structures in one place.
- Consider a "resource registry" or just aggressive use of structs/arrays that don't need explicit destroy.
- Add more defensive `if (ds_exists(...))` or move to structs.

**Importance**: **Medium** (correctness over long sessions)

---

### 11. Other Smaller Reinventions / Opportunities

- Manual line number sorting in Step every frame (`ds_list_sort` on `global.line_list`).
- Custom `string_is_number`, `string_split_spaces`, `is_numeric_string` when GML has `string_digits`, `string_is_real`? (check current GML).
- Custom CSV/arg parsing (`basic_parse_csv_args`) — could use `string_split` + quote stripping.
- Manual `current_time` based TIMER vs using GML timing.
- Lots of `string_char_at` + `string_copy` loops that could use newer `string_*` functions or regex (GML has limited regex).
- Editor undo uses ds_list of strings; could be a struct array.

---

## Prioritized Potential Fixes List

| # | Area | Suggested Change | Importance | Effort | Notes |
|---|------|------------------|------------|--------|-------|
| 1 | Arrays | Replace ds_list+flattening with native GML multi-dim arrays | **Critical** | High | Biggest maintenance win |
| 2 | MODE 2 Grid | Switch to `ds_grid` (or 2D array of structs) | **High** | Medium | Unlocks region ops, simpler scroll/fill |
| 3 | Sprites | Replace parallel arrays + obj_bas_sprite with surfaces + direct draw or real sprite resources | **High** | High | Massive simplification |
| 4 | Data structures | Prefer structs + arrays over ds_map/ds_list where possible | High | Medium | Especially variables, config, font_sheets |
| 5 | Statement splitting | Consolidate all quote-aware splitters into 2-3 robust helpers | Medium | Medium | Reduce duplication |
| 6 | Memory management | Audit + centralize all ds_* creation/destruction; add guards | Medium | Medium | Prevent leaks |
| 7 | Color parsing | Simplify hex path using int64 / modern conversion | Low | Low | Polish |
| 8 | Tokenizer | Refactor for readability; extract common char scanning | Low-Medium | Medium | Not correctness issue |
| 9 | Performance | Stop sorting line_list every Step; cache gosub targets better | Medium | Low | Micro-optimization |
| 10 | Editor | Consider using a single data model (array of strings) instead of parallel maps/lists | Medium | Medium | Current dual storage (program_map + line_list + program_lines) is confusing |
| 11 | General | Reduce number of tiny script resources by grouping related functions | Low | High | Quality-of-life for developers |
| 12 | BEEP | (Optional) Extract waveform generation into a reusable module | Low | Low | Already good |
| 13 | File I/O | (Optional) Consider `buffer_*` for binary + text in future | Low | Low | Current text I/O is sufficient |

---

## Non-Functional / Process Recommendations

- Add a small "architecture" document describing the three main data models (program storage, variables/arrays, MODE 2 grid).
- Consider a lightweight "BASIC value" struct (type tag + value) instead of relying on GML's loose typing + "$" suffix convention everywhere.
- Increase use of `struct` for complex state (beep sequence, screen editor, etc.).
- When adding new commands, prefer calling GML drawing functions directly in the accelerated MODE 3 path (already done for CIRCLE/LINE/BOX — good precedent).

---

## Conclusion

The project succeeds because the authors were willing to implement a *lot* of classic language machinery on top of GameMaker. The places where it reinvents unnecessarily are exactly the areas where GML has strong data structures and resource types (arrays, ds_grid, sprites/surfaces, structs).

Addressing #1 (arrays) and #2 (grid) would give the biggest reduction in custom code while improving reliability. The sprite system (#3) is the most expensive reinvention currently.

The interpreter logic itself (parser, evaluator, command handlers) is appropriately custom and should largely stay.

This is a solid foundation that would benefit from a "modern GML" pass on the data representation layers.

---

*End of report. No code was modified during this review.*
