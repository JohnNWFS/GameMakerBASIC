/// @script dbg_macros.gml
#macro DBG_PARSE  1     // tokenizer, parser, DIM/LET parsing
#macro DBG_EVAL   2     // postfix eval, expression values
#macro DBG_FLOW   4     // IF/WHILE/GOTO/GOSUB flow
#macro DBG_IO     8     // INPUT/PRINT/UI prompts
#macro DBG_ARRAY  16    // array get/set, DIM
#macro DBG_PERF   32    // performance
#macro DBG_STEP   64    // Execution
#macro DBG_EXEC   128	// EXEC
#macro DBG_ALL    0x7fffffff

/*
DEBUG MASKING — HOW TO USE (READ THIS FIRST)
============================================

## WHAT THIS FILE IS

These `#macro` lines define **compile-time constants** used to *categorize* your
debug logs. They are simple bit flags (1, 2, 4, …) that you OR together to
decide which kinds of messages should print at runtime.

```
#macro DBG_PARSE  1     // tokenizer & parser chatter
#macro DBG_EVAL   2     // postfix evaluation & expression results
#macro DBG_FLOW   4     // IF/WHILE/WEND/GOTO/GOSUB decisions
#macro DBG_IO     8     // INPUT/PRINT/UI prompts & commits
#macro DBG_ARRAY  16    // DIM + array get/set + bounds logs
#macro DBG_ALL    0x7fffffff  // convenience: everything on
```

> IMPORTANT: Macros must live at **top level** (not inside a function). Keep
> this file as-is; don’t wrap these lines in a function.

## REQUIRED COMPANION (dbg.gml)

You also have two helper functions defined in `dbg.gml`:

```
function dbg_on(cat) -> bool
    // Returns TRUE if the category bit is enabled in global.debug_mask.
    // Very cheap; use around *occasional* logs.

function dbg(cat, msg) -> void
    // Prints a message if the category bit is enabled AND you haven’t
    // exceeded the per-frame quota. Use inside tight loops to avoid FPS hits.
```

Both helpers rely on these globals, which you should initialize once in your
interpreter’s Create/Init event:

```
if (!variable_global_exists("debug_mask")) {
    global.debug_mask        = DBG_ALL;   // start verbose; tune later
    global.dbg_frame_quota   = 1200;      // max logs per frame before dropping
    global.dbg_frame_count   = 0;         // internal counter (do not set manually)
    global.dbg_dropped_count = 0;         // internal counter (do not set manually)
}
```

And reset the quota each frame (Step Start of the interpreter object):

```
global.dbg_frame_count = 0;
if (global.dbg_dropped_count > 0) {
    show_debug_message("DBG: dropped " + string(global.dbg_dropped_count) + " lines this frame");
    global.dbg_dropped_count = 0;
}
```

## HOW TO WRAP EXISTING LOGS

You have hundreds of `show_debug_message(...)` calls. Wrap them gradually:

• High-volume / in loops (tokenizer, postfix, array hot-paths) → **use `dbg()`**
This enforces the per-frame quota automatically.
BEFORE:
show\_debug\_message("TOKENIZER: Char\[" + string(i) + "]='" + c + "'");
AFTER:
dbg(DBG\_PARSE, "TOKENIZER: Char\[" + string(i) + "]='" + c + "'");

• Low-volume / occasional (flow decisions, one-off prints) → **use `dbg_on()`**
This is a tiny mask check; then you call `show_debug_message` yourself.
BEFORE:
show\_debug\_message("WEND: Condition is TRUE — looping");
AFTER:
if (dbg\_on(DBG\_FLOW)) show\_debug\_message("WEND: Condition is TRUE — looping");

Tip: It’s fine to mix both styles. Prefer `dbg()` anywhere that can spam.

## WHAT EACH MASK MEANS (AND WHERE TO USE IT)

• DBG\_PARSE
Use on: tokenizer (`basic_tokenize_expression_v2`), parser/splitters,
command lexing (verb/arg extraction).
Goal: see how text becomes tokens. No evaluation yet.

• DBG\_EVAL
Use on: postfix creation/evaluation, math/operator application, variable loads.
Goal: see stack pushes/pops and numeric/string results.

• DBG\_FLOW
Use on: `basic_cmd_if/_if_inline`, `basic_cmd_while`, `basic_cmd_wend`,
loop stack push/pop, `GOTO/GOSUB/RETURN` target resolution.
Goal: follow control flow decisions and jumps.

• DBG\_IO
Use on: `basic_cmd_input`, `basic_cmd_print`, wrapping/commit pipeline,
prompt emission, input state flips.
Goal: ensure prompts and outputs render and input mode is toggled correctly.

• DBG\_ARRAY
Use on: `basic_cmd_dim`, `basic_array_get`, `basic_array_set`, bounds checks.
Goal: track sizes, indices, auto-grow, and OOB warnings.

• DBG\_ALL
Convenience macro: enable all categories at once.

## HOW TO TURN CATEGORIES ON/OFF

At runtime (debugger Watch window, a script, or once in Create):

```
// All off:
global.debug_mask = 0;

// Only FLOW:
global.debug_mask = DBG_FLOW;

// Only IO:
global.debug_mask = DBG_IO;

// FLOW + IO together:
global.debug_mask = DBG_FLOW | DBG_IO;

// Everything on:
global.debug_mask = DBG_ALL;
```

You can also toggle bits on the fly:

```
// Flip the PARSE bit:
global.debug_mask ^= DBG_PARSE;
```

If you temporarily cranked the quota for a heavy trace, put it back:

```
global.dbg_frame_quota = 1200;    // typical safe value
// (set larger, e.g., 100000, if you want to capture *everything* for a short run)
```

## OPTIONAL: QUICK HOTKEY TO CYCLE VERBOSITY

Add this to the interpreter object’s Step (or Step Begin):

```
if (keyboard_check_pressed(vk_f9)) {
    var next = (global.debug_mask == 0)
        ? (DBG_FLOW | DBG_IO)   // useful day-to-day
        : (global.debug_mask == (DBG_FLOW | DBG_IO) ? DBG_ALL : 0);
    global.debug_mask = next;
    show_debug_message("DBG: mask now = " + string(next));
}
```

## COMMON PITFALLS & TIPS

• Macros not recognized → Ensure this file (`dbg_macros.gml`) is a separate
script asset with **only** the `#macro` lines at top level. If you still see
“variable not defined” on a macro name, **Clean** the project and rebuild.

• Compile order → Place `dbg_macros.gml` near the top of your Scripts folder so
everything else sees it. (Macros are compile-time, but ordering can trip
partial rebuilds.)

• Use `dbg()` for anything inside loops; it’s quota-aware. If you use
`dbg_on()` + `show_debug_message(...)` in a hot loop you can still tank FPS.

• Migration strategy → You don’t need to wrap everything at once. Start with:
tokenizer (DBG\_PARSE), evaluation (DBG\_EVAL), flow (DBG\_FLOW). That usually
kills 90% of the spam while keeping the most actionable signal.

## EXAMPLES (COPY/PASTE)

Tokenizer char echo (quota-aware):
dbg(DBG\_PARSE, "TOKENIZER: Char\[" + string(i) + "] = '" + string\_char\_at(s, i) + "'");

Flow decision:
if (dbg\_on(DBG\_FLOW))
show\_debug\_message("IF: result=" + string(result) + " → " + (result ? "THEN" : "ELSE"));

Input prompt emission:
dbg(DBG\_IO, "INPUT: Prompt='" + rawPrompt + "' → var=" + varName);

Array set:
dbg(DBG\_ARRAY, "ARRAY SET: " + name + "\[" + string(idx) + "] = " + string(val));

## QUICK START

1. Keep these macros here (top level).
2. Ensure `dbg.gml` exists with `dbg_on` and `dbg`.
3. Initialize the globals in Create, reset counters in Step Start.
4. Wrap high-volume logs with `dbg(cat, msg)`, occasional logs with `dbg_on`.
5. Control verbosity by setting `global.debug_mask` at runtime:
   • All off: 0
   • Only FLOW: DBG\_FLOW
   • Only IO: DBG\_IO
   • FLOW + IO: DBG\_FLOW | DBG\_IO
   • Everything: DBG\_ALL
6. If things feel slow, reduce the mask and/or lower `global.dbg_frame_quota`.

That’s it. You keep the power of your detailed logs without drowning the Runner.
*/
