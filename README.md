# NW-BASIC

A custom-built BASIC interpreter and code editor created using **GameMaker Studio**. This project aims to recreate the feel of early home computer BASIC environments, while growing into a serious retro-modern BASIC with strong text programming, tile graphics, and pixel drawing support.

> **Built for fun**, educational exploration, and retro coding joy — this project is co-developed using LLMs (Large Language Models) to assist with iterative code design, debugging, and feature expansion.

---

## Project Goals

- Build a **fully functional** interpreted BASIC environment from scratch
- Grow toward a broad, high-quality BASIC command set for text programs, games, education, and creative coding
- Treat text mode, tile graphics, and pixel/surface graphics as first-class programming environments
- Run on **GameMaker Studio** and be easily portable to **Android devices**
- Maintain a lightweight and nostalgic programming feel
- Encourage experimentation, creativity, and fun with retro-style code

---

## System Requirements

- **GameMaker Studio 2.3+** required for development
- **Target platforms**: Windows, Android, HTML5
- **Save files location**: Documents/BasicInterpreter/ (desktop)
- **Line number range**: 1-65535
- **Memory**: Automatic garbage collection
- **Touch support**: Android optimized with directional regions

---

# BASIC Language Reference Manual

## Table of Contents
- [Program Structure](#program-structure)
- [Variables and Data Types](#variables-and-data-types)
- [Arrays](#arrays)
- [Input/Output Commands](#inputoutput-commands)
- [Sound Commands](#sound-commands)
- [Program Control](#program-control)
- [Mode Control](#mode-control)
- [MODE 2 Commands (Tile Graphics)](#mode-2-commands-tile-graphics)
- [MODE 3 Commands (Pixel Graphics)](#mode-3-commands-pixel-graphics)
- [Sprite System](#sprite-system)
- [File I/O](#file-io)
- [Math Functions](#math-functions)
- [String Functions](#string-functions)
- [System Functions](#system-functions)
- [Data Handling](#data-handling)
- [Color Control](#color-control)
- [Operators](#operators)
- [Editor Commands](#editor-commands)
- [Browser (Web) Edition](#browser-web-edition)
- [Error Handling](#error-handling)
- [Programming Tips](#programming-tips)
- [Example Programs](#example-programs)

---

## Program Structure

### Line Numbers
Every statement in NW-BASIC begins with a line number. Lines run in numerical order from lowest to highest unless a command redirects execution. Comments can be added with `REM` or an apostrophe `'` — anything after them on the line is ignored.

```basic
10 PRINT "This program starts at line 10."
20 PRINT "Line 20 runs next."
30 PRINT "Line numbers control program order."
40 PAUSE
50 END
```

- Line numbers: 1-65535
- Lines executed in order unless redirected by GOTO/GOSUB
- Comments: `REM` or `'` (apostrophe)

### Multiple Statements
You can put more than one command on a single line by separating them with a colon. Each runs in order, left to right.

```basic
10 PRINT "This line prints three separate messages:"
20 PRINT "A" : PRINT "B" : PRINT "C"
30 PAUSE
40 END
```

---

## Variables and Data Types

### Variable Assignment
Use assignment to store values for later. `LET` is accepted but optional, so `LET X = 5` and `X = 5` both assign a value to `X`.

```basic
10 LET X = 5
20 A$ = "HELLO"
30 Y = X + 10       ' LET is optional
40 PRINT "X ="; X; "  A$ ="; A$; "  Y ="; Y
50 PAUSE
60 END
```

- Numeric variables default to 0 if read before being set.
- String variables default to `""` if read before being set.
- Variable names are case-insensitive. `score` and `SCORE` are the same variable.

---

## Arrays

An array is a named list of values, all accessed by the same variable name using an index number in parentheses. Use `DIM` to declare an array before using it. Arrays can hold numbers or strings, be one-dimensional (a list), two-dimensional (a grid), or three-dimensional, and are **1-based by default** — `DIM A(10)` gives you `A(1)` through `A(10)`.

```basic
10 DIM A(10)           ' 1-D array with indices 1-10 (10 elements)
20 DIM B(5), C$(20)    ' Multiple declarations in one statement
30 DIM M(3, 4)         ' 2-D array: valid indices (1..3, 1..4)
35 DIM V(2, 3, 2)      ' 3-D array: valid indices (1..2, 1..3, 1..2)
40 A(3) = 42           ' Set element
50 PRINT A(3)          ' Read element
60 M(1, 2) = 99        ' Set 2-D element
65 V(2, 3, 1) = 7     ' Set 3-D element
70 PRINT M(1, 2)       ' Read 2-D element
75 PRINT V(2, 3, 1)    ' Read 3-D element
80 PAUSE
90 END
```

- Arrays are **1-based** by default (index 1 through N).
- Use `OPTION BASE 0` to switch to 0-based indexing (index 0 through N).
- 1-D, 2-D, and 3-D arrays are supported. Numeric arrays hold integers/reals; string arrays use a `$` suffix (`DIM T$(2,2,2)`). Store character codes in numeric arrays with `ASC`/`CHR$` when you need single-character cells. Arrays must be declared with `DIM` before use.
- `ERASE name` removes an array from memory and frees its storage. After erasing, you can `DIM` the same name again with a different size.

```basic
10 DIM SCORES(5)
20 FOR I = 1 TO 5
30   SCORES(I) = I * 10
40 NEXT I
50 PRINT "Before ERASE: SCORES(3) ="; SCORES(3)
60 ERASE SCORES
70 DIM SCORES(10)      ' Re-declare with a bigger size
80 SCORES(7) = 99
90 PRINT "After ERASE and re-DIM: SCORES(7) ="; SCORES(7)
100 PAUSE
110 END
```

```basic
10 PRINT "Switching arrays to OPTION BASE 0."
20 OPTION BASE 0        ' Arrays use indices 0..N
30 DIM A(10)            ' A(0) through A(10)
40 A(0) = 100
50 A(10) = 1000
60 PRINT "A(0)="; A(0); "  A(10)="; A(10)
70 PAUSE
80 END
```

---

## Input/Output Commands

### PRINT
`PRINT` outputs text and values to the screen. Items are separated by semicolons (no space) or commas (tab-stop spacing). A trailing semicolon keeps the cursor on the same line so the next PRINT continues there.

```basic
10 X = 42
20 A = 1 : B = 2 : C = 3
30 PRINT "Hello World"
40 PRINT X                  ' Print variable
50 PRINT "X="; X            ' Semicolon: no space between items
60 PRINT A, B, C            ' Comma: tab-stop spacing
70 PRINT "Hi ";             ' Trailing semicolon suppresses newline
80 PRINT "there"
90 PRINT TAB(10); "here"    ' TAB(n) moves to column n
100 PRINT SPC(5); "spaced"  ' SPC(n) inserts n spaces
110 PAUSE
120 END
```

**Special print behavior:**
- `;` suppresses the newline and prints the next item immediately.
- `,` advances to the next tab zone (approximately every 14 characters).
- `TAB(n)` and `SPC(n)` work inside PRINT statements.
- `+` concatenates strings: `PRINT "Hello " + name$`

### INPUT

Collect a value from the user and store it in a variable. String variables
end with `$`; numeric variables do not. The optional prompt is printed before
the cursor — use `,` or `;` to separate the prompt string from the variable.
With no prompt, a `?` is shown automatically.

```basic
10 INPUT "Your name: ", N$
20 INPUT "Your age: ", AGE
30 PRINT "Hello, "; N$; "!"
40 PRINT "In 10 years you will be "; AGE + 10; "."
50 PAUSE
60 END
```

*Sample run:*
The program prompts for a name and age, then echoes both values back in complete sentences.

- `,` and `;` both work as the separator between the prompt and the variable.
- With no prompt (`INPUT X`), a `?` is displayed automatically.
- String variables (`N$`, `A$`, ...) accept any text; numeric variables accept numbers.

### CLS
`CLS` clears the screen. What it clears depends on the current mode.

```basic
10 PRINT "This text appears before CLS."
20 PAUSE
30 CLS
40 PRINT "CLS cleared the text screen."
50 PRINT "In MODE 2 it clears tiles; in MODE 3 it clears pixels."
60 PAUSE
70 END
```

### PAUSE
`PAUSE` halts program execution and waits for the user to press Enter before continuing. Useful for letting the user read output before the program moves on.

```basic
10 PRINT "Read this line, then press ENTER."
20 PAUSE
30 PRINT "The program continued after PAUSE."
40 PAUSE
50 END
```

### LOCATE (MODE 2 only)
`LOCATE` moves the tile-mode text cursor so the next `PRINT` appears at that position. Syntax: `LOCATE row, col` using **1-based** row and column numbers (BASIC-style). This differs from `PRINTAT`, which uses **0-based column, row** order.

```basic
10 MODE 2
20 PRINTAT 0, 0, "LOCATE moves the PRINT cursor.", YELLOW, BLACK
30 PAUSE
40 CLS
50 LOCATE 6, 11      ' 1-based row 6, column 11
60 PRINT "Hello!"    ' Printed at that position
70 LOCATE 11, 2
80 PRINT "Done."
90 PAUSE
100 END
```
LOCATE has no effect in MODE 1 text mode.

### SCROLL (MODE 2 only)
`SCROLL` shifts the entire tile grid one or more positions in a given direction. Content that moves off one edge does not wrap — those cells are cleared to spaces. The example below uses a variable `S` to track where the tile content currently starts, adjusting it after each scroll so the prompt always appears just below the content.
```basic
10 MODE 2
15 LET S = 10
20 FOR I = 1 TO 10
30   PRINTAT 0, I-1, "Row " + STR$(I), WHITE, BLACK
40 NEXT I
50 GOSUB 500
60 PRINTAT 0, S, "Press ENTER to scroll up 3...", YELLOW, BLACK
70 PAUSE
80 SCROLL UP, 3
85 LET S = S - 3
90 GOSUB 500
100 PRINTAT 0, S, "Press ENTER to scroll down 1...", YELLOW, BLACK
110 PAUSE
120 SCROLL DOWN, 1
125 LET S = S + 1
130 GOSUB 500
140 PRINTAT 0, S, "Press ENTER to scroll left 2...", YELLOW, BLACK
150 PAUSE
160 SCROLL LEFT, 2
170 GOSUB 500
180 PRINTAT 0, S, "Press ENTER to scroll right 1...", YELLOW, BLACK
190 PAUSE
200 SCROLL RIGHT, 1
210 END
500 FOR R = S TO 20
510   PRINTAT 0, R, "                                        ", BLACK, BLACK
520 NEXT R
530 RETURN
```

---

## Sound Commands

### TEMPO — Music Speed
`TEMPO` sets the speed used by `BEEP` and `PLAY`. Use it when a song or sound effect should play faster or slower without rewriting every note length. The value is beats per minute, and the default is `120`.

Syntax: `TEMPO bpm`

The program below plays the same five-note phrase at two different speeds. The note lengths do not change; only the tempo changes.

```basic
10 PRINT "TEMPO DEMO"
20 PRINT "The same phrase plays slowly, then quickly."
30 PAUSE
40 TEMPO 80
50 PRINT "TEMPO 80: slow quarter notes."
60 BEEP O0 C1 D1 E1 F1 G2
70 TEMPO 150
80 PRINT "TEMPO 150: the same notes move faster."
90 BEEP O0 C1 D1 E1 F1 G2
100 TEMPO 120
110 PRINT "Tempo restored to 120."
120 PAUSE
130 END
```

`TEMPO` persists until changed again, so a program should set it explicitly before music if the exact speed matters.

### BEEP — Musical Note Sequences
`BEEP` plays one or more musical note specifications and waits until the sequence finishes. Use it for simple effects, melodies, and audible feedback in text or graphics programs.

```basic
10 PRINT "A single note: middle C, one beat."
20 BEEP C1
30 PRINT "Three notes in one line: A eighth, B eighth, C half."
40 BEEP A0.5 B0.5 C2
50 PRINT "Sharps and flats: C#, Db, F#."
60 BEEP C#1 Db1 F#2
70 PRINT "A rest followed by a note: silence, then C."
80 BEEP R1 C1
90 PRINT "Switching to octave 2: C and D sound higher."
100 BEEP O2 C1 D1
110 PRINT "Octave changes mid-sequence: A low, G higher."
120 BEEP O-1 A4 O1 G2
130 PAUSE
140 END
```

#### BEEP Syntax
Syntax: `BEEP spec [spec ...]`

**Note Specifications:**
- **Note**: `A`, `B`, `C`, `D`, `E`, `F`, `G` or `R` (rest)
- **Accidentals**: `#` (sharp) or `b` (flat) — e.g., `C#`, `Bb`
- **Duration**: Number of beats — `1` = quarter, `2` = half, `4` = whole, `0.5` = eighth, `0.25` = sixteenth
- **Octave**: `O<number>` sets octave; changes persist until the next `O` token

> **Heads up:** In BEEP syntax the number after a note is always the **duration**, never the octave. `C1` and `C2` are both middle C — one held for one beat, the other for two. To move to a different octave use `O`: `O1 C1` is C one octave above middle C.

#### BEEP Examples
```basic
10 PRINT "C major scale - 8 notes ascending (last C is one octave up)."
20 BEEP C1 D1 E1 F1 G1 A1 B1 O1 C1
30 PRINT "Rhythm with rests - short notes and a pause."
40 BEEP C0.5 C0.5 G1 R0.5 F0.5 E1
50 PRINT "Octave shifts - same note, three octaves rising."
60 BEEP O-1 C1 O0 C1 O1 C1
70 PRINT "Sharps and flats - C, C#, D, Eb, E."
80 BEEP C1 C#1 D1 Eb1 E1
90 PAUSE
100 END
```

#### BEEP Technical Details
- Default tempo: 120 BPM (adjustable via `global.beep_tempo`)
- Pitch targets use standard equal temperament with A4 = 440 Hz.
- BEEP tones are generated directly as mono audio buffers rather than pitch-shifted samples, so octaves and chromatic steps stay mathematically consistent.
- Playback amplitude is controlled through `global.beep_volume`, which defaults to a conservative music-friendly level. Lower octaves receive a small perceptual boost so they remain audible on small speakers.
- Generated notes use `global.beep_note_gate` to leave a tiny gap at the end of each note while preserving the rhythmic duration. This makes melodies easier to hear than fully legato beeps.
- Generated tones use a short attack/release envelope to reduce clicks at note boundaries.
- BEEP **blocks** program execution until the entire sequence completes
- Duration `0` is treated as `0.25` (sixteenth note)

### PLAY — Music Macro Language
`PLAY` accepts a compact Music Macro Language string. Use it when you want classic BASIC-style music listings or when importing short tunes written in MML. `PLAY` uses the same generated sound engine as `BEEP`, so `TEMPO`, generated tone volume, and note gating behave the same way.

Syntax: `PLAY "mml"`

The MML string is parsed character by character. The full command set is:

| Command | Description |
|---------|-------------|
| `T`_n_ | Tempo in BPM — e.g. `T120`. Range 20–600. |
| `O`_n_ | Set octave — `O4` is the octave containing middle C. |
| `L`_n_ | Default note length — `L4` = quarter, `L8` = eighth, `L16` = sixteenth. |
| `V`_n_ | Volume — `V0`–`V15` (0 = silent, 15 = full). Persists until changed. |
| `>` / `<` | Shift octave up / down by one. |
| `MN` | Music Normal — standard gate (~7/8 note length). |
| `MS` | Music Staccato — short gate (half note length). |
| `ML` | Music Legato — full gate (no gap between notes). |
| `A`–`G` | Play a note. Optionally followed by `#` or `+` (sharp), `-` (flat), a length number, and `.` (dotted — multiply by 1.5, repeatable). |
| `R` / `P` | Rest for the given length. |
| `N`_n_ | Absolute note number 0–95, where `N48` = middle C. Optional length after a comma: `N48,8` = middle C eighth note. |

This first example plays a C major scale. `T120` sets tempo, `O4` selects the octave containing middle C, and `L8` makes every note an eighth note by default.

```basic
10 PRINT "PLAY MML SCALE DEMO"
20 PRINT "T120 O4 L8: tempo 120, octave 4, default eighth notes."
30 PAUSE
40 PLAY "T120 O4 L8 CDEFGAB>C"
50 PRINT "The final >C shifts up one octave before playing C."
60 PAUSE
70 END
```

This second example tours the rest of the command set — volume, note style, absolute note numbers, and dotted notes. Each feature is announced before it plays.

```basic
10 PRINT "PLAY MML FULL FEATURE DEMO"
20 PAUSE
30 PRINT "Volume: loud (V15) then quiet (V5)."
40 PLAY "T120 O4 L4 V15 C G V5 C G"
50 PRINT "Note style: normal, staccato, legato."
60 PLAY "O4 L4 MN CDEF MS CDEF ML CDEF"
70 PRINT "Dotted notes: dotted quarter, double-dotted quarter."
80 PLAY "O4 T100 C4. C4.. R4"
90 PRINT "Absolute note numbers: N48=C4, N52=E4, N55=G4."
100 PLAY "T120 N48,4 N52,4 N55,4 N60,2"
110 PRINT "Rests, sharps, flats, and octave shifts."
120 PLAY "O4 L8 C R C+ D D- C. <B >C2"
130 PRINT "DONE."
140 PAUSE
150 END
```

`PLAY` is meant as a compatibility-friendly shortcut. For beginners, `BEEP` is often easier to read because each note is a separate word; for classic BASIC music listings, `PLAY` is usually more compact and importable.

---

## Program Control

### Conditional Statements
An `IF` statement tests a condition and runs code only when that condition is true. NW-BASIC supports a single-line form and a multi-line block form.

#### Inline IF
A single-line IF fits the test and its action on one line. An optional `ELSE` clause runs when the condition is false.
```basic
10 PRINT "X has never been set, so it defaults to 0."
20 PRINT "Testing IF X = 5 — this will be false, so nothing prints:"
30 IF X = 5 THEN PRINT "Five"
40 PRINT "(Correct — nothing printed above.)"
50 LET X = 5
60 PRINT "Now X = 5. Testing again — this time it prints:"
70 IF X = 5 THEN PRINT "Five"
80 LET A = 10 : LET B = 3
90 PRINT "A = 10, B = 3. The true branch of ELSE runs:"
100 IF A > B THEN PRINT "A is bigger" ELSE PRINT "B is bigger"
110 PRINT "IF can run multiple statements — setting Y and Z:"
120 IF X = 5 THEN Y = 2 : Z = 3
130 PRINT "Y = " + STR$(Y) + ", Z = " + STR$(Z)
140 PAUSE
150 END
```

#### Block IF (Multi-line)
When you need multiple lines of code under a condition, use the block form. `IF` opens the block, `ELSEIF` adds additional tests, `ELSE` catches everything that didn't match, and `ENDIF` closes it.
```basic
10 LET X = 7
20 PRINT "X = 7. Block IF checks it step by step:"
30 IF X > 10 THEN
40   PRINT "X is large"
50   Y = X * 2
60 ELSEIF X > 5 THEN
70   PRINT "X is medium"
80 ELSE
90   PRINT "X is small"
100 ENDIF
110 PAUSE
120 END
```

#### Logical Operators
`AND` requires both conditions to be true. `OR` requires at least one to be true. `NOT` inverts a condition.
```basic
10 LET X = 8 : LET Y = 7
20 IF X > 5 AND Y < 10 THEN PRINT "Both conditions true — X > 5 and Y < 10."
30 LET A = 1 : LET B = 9
40 IF A = 1 OR B = 2 THEN PRINT "One condition true — A = 1 matches."
50 LET DONE = 0
60 IF NOT DONE THEN PRINT "NOT DONE is true while DONE = 0."
70 PAUSE
80 END
```

### Loops

#### FOR/NEXT
`FOR` repeats a block of code a set number of times, stepping a counter variable from a start value to an end value. `NEXT` marks the end of the loop and increments the counter. Use `STEP` to count by something other than 1.
```basic
10 PRINT "Counting up from 1 to 5:"
20 FOR I = 1 TO 5
30   PRINT I
40 NEXT I
50 PRINT "Counting down from 10 to 2, stepping by 2:"
60 FOR J = 10 TO 2 STEP -2
70   PRINT J
80 NEXT J
90 PAUSE
100 END
```

#### WHILE/WEND
`WHILE` checks a condition and, as long as it is true, repeats all the statements between it and its matching `WEND`. When the condition becomes false, execution jumps past `WEND`. If the condition is false before the loop even starts, the body never runs.
```basic
10 PRINT "Printing X while it is <= 5:"
20 X = 1
30 WHILE X <= 5
40   PRINT X
50   X = X + 1
60 WEND
70 PRINT "The loop stopped when X became "; X
80 PAUSE
90 END
```

### Subroutines
`GOSUB` jumps to a numbered line and runs the code there until a `RETURN` statement sends execution back to the line after the original `GOSUB`. This lets you write a block of code once and call it from multiple places. Always place `END` before subroutine code so the program doesn't accidentally fall into it.
```basic
10 PRINT "Calling the subroutine at line 100:"
20 GOSUB 100
30 PRINT "Back in the main program."
40 PAUSE
50 END
100 PRINT "Inside the subroutine."
110 RETURN
```

### ON GOTO / ON GOSUB
`ON N GOTO` (or `GOSUB`) uses the value of `N` to choose which line to jump to from a list of targets. If `N` is 1 it goes to the first target, 2 to the second, and so on — handy for building menus or dispatching to different routines based on a number.
```basic
10 LET N = 2
20 PRINT "N = 2, so ON GOTO jumps to the second target:"
30 ON N GOTO 100, 200, 300
40 END
100 PRINT "Branch 1 — N was 1."
110 PAUSE
120 END
200 PRINT "Branch 2 — N was 2."
210 PAUSE
220 END
300 PRINT "Branch 3 — N was 3."
310 PAUSE
320 END
```
If `N` is out of range (less than 1 or greater than the number of targets), execution falls through to the next line.

### Program Flow
`GOTO` jumps unconditionally to any line number, skipping everything in between. `END` stops the program and waits for Enter/Esc. `STOP` is a **breakpoint**: it returns to the editor immediately, **preserves variables and PEEK/POKE memory**, and the next `RUN` continues from the `STOP` line (a fresh `RUN` after `NEW` or a normal restart still clears everything).

```basic
10 PRINT "Line 10 runs."
20 GOTO 50
30 PRINT "Line 30 is skipped."
40 PRINT "Line 40 is skipped."
50 PRINT "Line 50 runs — GOTO jumped here."
60 STOP          ' Breakpoint — RUN again continues here
70 PRINT "After STOP."
80 END
```

### ON ERROR GOTO
Install a line-number handler for errors that NW-BASIC traps (for example division by zero in integer division `1 \ 0`). The handler runs instead of ending the program. Use `ON ERROR GOTO 0` to disable. The error message is still printed, then execution jumps to your handler line.

```basic
10 ON ERROR GOTO 9000
20 X = 1 \ 0     ' Trapped: integer division by zero
30 PRINT "Never reached"
40 END
9000 PRINT "Recovered — program did not END at the bad line."
9010 END
```

**Resume after a trap** — inside the handler you can return to the fault site:

- `RESUME` — re-run the statement that trapped (fix variables first if needed)
- `RESUME NEXT` — continue at the next statement (same line if more statements follow, otherwise the next program line)

```basic
10 ON ERROR GOTO 9000
20 Y = 0
30 X = 1 \ Y        ' traps while Y is 0
40 PRINT "X ="; X
50 END
9000 Y = 1          ' repair state
9010 RESUME         ' retry line 30
```

```basic
10 ON ERROR GOTO 9000
20 PRINT "Before"
30 X = 1 \ 0        ' traps here
40 PRINT "After"    ' RESUME NEXT lands here
50 END
9000 RESUME NEXT
```

**Error details in a handler** — `ERL` returns the BASIC line number that trapped; `ERR` returns a numeric error code (QBASIC-style where applicable). Both return `0` when no error has been trapped since the last `RUN` or `ON ERROR GOTO 0`.

| `ERR` | Typical cause |
|-------|----------------|
| 3 | `RETURN` without `GOSUB` |
| 4 | `READ` past end of `DATA` |
| 9 | Array index out of range |
| 11 | Division by zero in `\` |
| 13 | Type mismatch in numeric ops |
| 20 | `RESUME` with no trapped error |
| 2 | Other syntax/runtime errors (default) |

```basic
10 ON ERROR GOTO 9000
20 X = 1 \ 0
30 END
9000 PRINT "Error"; ERR; "at line"; ERL
9010 END
```

Not every failure is trapped (for example host/GameMaker fatal errors). For predictable program logic, prefer testing divisors and inputs before they fail.

### RANDOMIZE
`RANDOMIZE` seeds the random number generator so that `RND` produces a different sequence each run. Without it, the same seed is used every time and you get the same "random" numbers. Pass a specific number to get a repeatable sequence — useful for testing.
```basic
10 PRINT "RANDOMIZE without a number uses system time."
20 RANDOMIZE
30 PRINT "A fresh random die roll:"; RND(6)
40 PRINT "RANDOMIZE 42 gives a repeatable sequence."
50 RANDOMIZE 42
60 PRINT "First repeatable roll:"; RND(6)
70 PAUSE
80 END
```

---

## Mode Control

NW-BASIC has three public modes:

| Mode | Description |
|------|-------------|
| `MODE 0` | Text mode (compatibility alias for MODE 1) |
| `MODE 1` | Text mode (default) |
| `MODE 2` | Tile/character graphics |
| `MODE 3` | Pixel/surface graphics |

Switching modes clears the screen and resets the display. MODE 2 accepts an optional tile size in pixels — smaller tiles fit more characters on screen, larger tiles are easier to read. If no size is given, 32×32 is used. `GETMODE` (or its alias `SCREEN`) returns the current mode number so your program can behave differently depending on which mode is active.

```basic
10 MODE 1
20 PRINT "MODE 1 — text mode. Scrolling PRINT output, default at startup."
30 PAUSE
40 MODE 2
50 PRINTAT 0, 0, "MODE 2: tile graphics", WHITE, BLACK
60 PRINTAT 0, 1, "32x32 tiles (default)", WHITE, BLACK
70 PAUSE
80 MODE 2, 8
90 PRINTAT 0, 0, "MODE 2, 8: tile graphics", WHITE, BLACK
100 PRINTAT 0, 1, "8x8 tiles (most on screen)", WHITE, BLACK
110 PAUSE
120 MODE 2, 16
130 PRINTAT 0, 0, "MODE 2, 16: tile graphics", WHITE, BLACK
140 PRINTAT 0, 1, "16x16 tiles", WHITE, BLACK
150 PAUSE
160 MODE 2, 32
170 PRINTAT 0, 0, "MODE 2, 32: tile graphics", WHITE, BLACK
180 PRINTAT 0, 1, "32x32 tiles (largest)", WHITE, BLACK
190 PAUSE
200 MODE 3
210 PRINT "MODE 3: pixel graphics."
220 PRINT "Draw lines, circles, and pixels."
230 PAUSE
240 MODE 1
250 M = GETMODE()
260 PRINT "Back to MODE 1. GETMODE() = "; M
270 PRINT "SCREEN() is an alias for GETMODE()."
280 PAUSE
290 END
```

---

## MODE 2 Commands (Tile Graphics)

MODE 2 uses a grid of character-sized cells. Each cell has a character code, a foreground color, and a background color. Coordinates are always **column, row** (x, y), 0-based from the top-left.

MODE 2 uses tile-font glyphs, so its built-in font is ASCII-oriented. Common pasted Unicode punctuation is converted to readable ASCII fallbacks before rendering: em/en dashes become `-`, smart quotes become straight quotes, ellipsis becomes `...`, bullets become `*`, and non-breaking spaces become normal spaces.

**Cell size:** Most examples below use **`MODE 2, 16`** (16×16-pixel cells). You can substitute **`MODE 2, 8`** or **`MODE 2, 32`** anywhere you see `MODE 2, 16` — the commands are unchanged; only resolution and how many columns/rows fit on screen change. **`MODE 2, 32`** produces bold, readable tile art and makes tile maps especially striking. **`MODE 2, 8`** packs more cells for denser layouts. Custom tiles follow the active cell size (`TILEDEF` defaults to it), and **`TILEEDIT`** paints at the current resolution — there is no separate 32×32 editor; run at `MODE 2, 32` when you want chunky sprites.

### PRINT (MODE 2)
In MODE 2, `PRINT` writes text to the tile grid at the current cursor position. Use `LOCATE` to position the cursor first.

```basic
10 MODE 2, 16
20 PRINTAT 0, 0, "PRINT uses the tile cursor.", YELLOW, BLACK
30 LOCATE 4, 6       ' 1-based row 4, column 6
40 PRINT "Hello"     ' Prints at that position
50 PAUSE
60 END
```

### PRINTAT / DRAWSTR
`PRINTAT` writes a string directly to a specific column and row on the tile grid, with optional foreground and background colors. It does not move the cursor. `DRAWSTR` is an alias for the same command.
Syntax: `PRINTAT col, row, "text" [, fg [, bg]]`
```basic
10 MODE 2
20 PRINTAT 0, 0, "PRINTAT writes at exact tile coordinates.", YELLOW, BLACK
30 PRINTAT 5, 10, "HELLO", WHITE, BLACK
40 DRAWSTR 0, 2, "DRAWSTR is an alias.", BLUE, YELLOW
50 PAUSE
60 END
```

### PSET (MODE 2)
`PSET` places a single character at a tile grid position using an ASCII character code. All five arguments (column, row, character code, foreground, background) are required in MODE 2.
Syntax: `PSET col, row, charCode, fg, bg`
```basic
10 MODE 2
20 PRINTAT 0, 0, "PSET places one character tile.", YELLOW, BLACK
30 PSET 10, 5, 65, WHITE, BLACK   ' Place 'A' (ASCII 65) at column 10, row 5
40 PRINTAT 0, 7, "ASCII 65 is A.", WHITE, BLACK
50 PAUSE
60 END
```

### CHARAT / TILE / PLOT (MODE 2)
`CHARAT` places a single character by ASCII code at a tile position, optionally setting colors. If colors are omitted, existing cell colors are preserved. `TILE` and `PLOT` are aliases for the same command.
Syntax: `CHARAT col, row, charCode [, fg [, bg]]`
```basic
10 MODE 2
20 PRINTAT 0, 0, "CHARAT, TILE, and PLOT place character tiles.", YELLOW, BLACK
30 CHARAT 0, 2, 72               ' Place 'H', preserve existing colors
40 CHARAT 5, 3, 65, RED, BLACK   ' Place 'A' with colors
50 TILE 5, 5, 42, RED            ' TILE is an alias for CHARAT, 42 is an asterisk
60 PLOT 6, 5, 42, CYAN, BLACK    ' PLOT is an alias for CHARAT in MODE 2
70 PAUSE
80 END
```

### BOX (MODE 2)
`BOX` draws a rectangle border using a single tile character for all four sides and corners. Use it for dialog windows, frames, and menus. Combine with `FILL` to create a window with a solid interior.

Syntax: `BOX x1, y1, x2, y2, charCode [, fg [, bg]]`

```basic
10 MODE 2, 16
20 CLSCHAR 32, WHITE, BLACK
30 REM Draw a window: fill the interior first, then draw the border on top
40 FILL 3, 4, 21, 12, 32, WHITE, BLUE    ' Solid blue interior
50 BOX 2, 3, 22, 13, 35, YELLOW, BLUE   ' '#' border — ASCII 35
60 PRINTAT 7, 5, "DIALOG BOX", YELLOW, BLUE
61 PRINTAT 4, 7, "Press ENTER to close.", WHITE, BLUE
70 PAUSE
80 REM Now clear the window
90 FILL 2, 3, 22, 13, 32, BLACK, BLACK
100 PRINTAT 0, 0, "Window closed.", GREEN, BLACK
110 PAUSE
120 END
```

### FILL (MODE 2)
`FILL` paints a rectangular region of the tile grid with a single character, foreground color, and background color. It is useful for clearing a sub-region, drawing a solid background panel, or highlighting an area of the screen.

Syntax: `FILL x1, y1, x2, y2, charCode [, fg [, bg]]`

```basic
10 MODE 2, 16
20 CLSCHAR 32, BLACK, BLACK
30 PRINTAT 0, 0, "FILL demo", YELLOW, BLACK
40 REM Fill a blue info panel in the center
50 FILL 2, 3, 22, 9, 32, WHITE, BLUE    ' Space character = solid color fill
60 PRINTAT 4, 4, "This panel was drawn", WHITE, BLUE
70 PRINTAT 4, 5, "using FILL.", WHITE, BLUE
80 PRINTAT 4, 7, "FILL uses any char code.", YELLOW, BLUE
90 REM Fill a second region with a pattern character
100 FILL 2, 12, 22, 15, 176, CYAN, BLACK ' ASCII 176 = light shade block
110 PRINTAT 6, 13, "Pattern fill", BLACK, CYAN
120 PAUSE
130 END
```

### HLINE / VLINE (MODE 2)
`HLINE` draws a horizontal line of a single tile character across a row between two columns. `VLINE` draws a vertical line down a column between two rows. Both accept optional foreground and background colors. Together they are useful for drawing dividers, rulers, and the edges of custom window frames.

Syntax: `HLINE x1, x2, row, charCode [, fg [, bg]]`

Syntax: `VLINE col, y1, y2, charCode [, fg [, bg]]`

```basic
10 MODE 2, 16
20 CLSCHAR 32, WHITE, BLACK
30 PRINTAT 0, 0, "HLINE/VLINE panel demo", YELLOW, BLACK
40 REM Draw a horizontal rule under the title
50 HLINE 0, 25, 1, 196, YELLOW, BLACK   ' ASCII 196 = horizontal bar
60 REM Draw vertical dividers
70 VLINE 8, 2, 10, 179, CYAN, BLACK     ' ASCII 179 = vertical bar
80 VLINE 17, 2, 10, 179, CYAN, BLACK
90 REM Label the three columns
100 PRINTAT 1, 3, "COL A", WHITE, BLACK
110 PRINTAT 10, 3, "COL B", WHITE, BLACK
120 PRINTAT 19, 3, "COL C", WHITE, BLACK
130 REM Draw a horizontal rule at the bottom
140 HLINE 0, 25, 11, 196, YELLOW, BLACK
150 PAUSE
160 END
```

### CLSCHAR
`CLSCHAR` fills the entire tile grid with a single character, foreground color, and background color. Use character code 32 (space) to effectively clear the screen to a solid color. Syntax: `CLSCHAR charCode [, fg [, bg]]`
```basic
10 MODE 2
20 PRINTAT 0, 0, "CLSCHAR fills the whole tile grid.", YELLOW, BLACK
30 PAUSE
40 CLSCHAR 64, WHITE, BLUE     ' Fill screen with '@' on blue
50 PAUSE
60 CLSCHAR 32, GREEN, BLACK    ' Fill screen with spaces on black
70 PRINTAT 0, 0, "Back to blank spaces on black.", GREEN, BLACK
80 PAUSE
90 END
```

### Tile Grid Read Functions (MODE 2)
These functions let you read back what is currently on the tile grid — useful for collision detection, puzzle logic, or any time your program needs to know what character or color occupies a given cell.
```basic
10 MODE 2
20 PRINTAT 5, 3, "HI", RED, BLACK
30 C = TILECHAR(5, 3)          ' Returns the char code at col 5, row 3
40 CLR = TILECOLOR(5, 3)       ' Returns the foreground color value
50 N$ = TILENAME$(CLR)         ' Converts color value to name, e.g. "RED"
60 PRINTAT 0, 5, "Char=" + STR$(C) + " Color=" + N$, WHITE, BLACK
70 PAUSE
80 END
```

Legacy aliases (still work):
```basic
10 MODE 2
20 PRINTAT 5, 3, "HI", RED, BLACK
30 C = mode1_get_char(5, 3)
40 CLR = mode1_get_color(5, 3)
50 N$ = mode1_color_name(CLR)
60 PRINTAT 0, 5, "Legacy alias color=" + N$, WHITE, BLACK
70 PAUSE
80 END
```

### Font Control (MODE 2)
`FONT` switches the tile font sheet, which changes how every character on the grid is drawn. `FONTSET` works the same way but locks the choice so it survives subsequent `MODE 2` calls. Three sizes are available: 8×8, 16×16, and 32×32 pixels per tile.

Available font keys: `DEFAULT_8`, `DEFAULT_16`, `DEFAULT_32`.
```basic
10 MODE 2, 32
20 FONT "DEFAULT_32"
30 CLSCHAR 32, WHITE, BLACK
40 PRINTAT 0, 0, "32x32 font.", WHITE, BLACK
50 PRINTAT 0, 1, "Big tiles, few columns.", WHITE, BLACK
60 PAUSE
70 MODE 2, 16
80 FONT "DEFAULT_16"
90 CLSCHAR 32, WHITE, BLACK
100 PRINTAT 0, 0, "16x16 font.", WHITE, BLACK
110 PRINTAT 0, 1, "Medium tiles, more columns.", WHITE, BLACK
120 PAUSE
130 MODE 2, 8
140 FONT "DEFAULT_8"
150 CLSCHAR 32, WHITE, BLACK
160 PRINTAT 0, 0, "8x8 font.", WHITE, BLACK
170 PRINTAT 0, 1, "Tiny tiles, most columns.", WHITE, BLACK
180 PAUSE
190 FONTSET "DEFAULT_8"
200 MODE 2
210 CLSCHAR 32, WHITE, BLACK
220 PRINTAT 0, 0, "FONTSET locked 8x8.", WHITE, BLACK
230 PRINTAT 0, 1, "MODE 2 reset kept it.", WHITE, BLACK
240 PAUSE
250 END
```

---

## Custom Tiles (MODE 2)

Custom tiles are editable bitmap masks assigned to specific tile codes. When a cell uses a custom code, NW-BASIC draws the custom mask tinted with that cell's foreground color. All other codes continue to use the active font sheet, so normal text remains available alongside custom graphics.

**Important:** a tile definition is a shared glyph, not a per-cell image. Every cell on screen that displays the same tile code shows the same bitmap. If you edit tile 200's pixels, every cell currently showing tile 200 updates instantly — there is no way to have two cells show different versions of the same code. To display distinct shapes, use distinct codes (e.g. 200, 201, 202…).

```basic
10 MODE 2, 16
20 CLSCHAR 32, WHITE, BLACK
30 TILEDEF 200, 16, 16
40 FOR I = 0 TO 15
50   TILEPX 200, I, I, 1       ' Draw diagonal top-left to bottom-right
60   TILEPX 200, 15-I, I, 1   ' Draw diagonal top-right to bottom-left
70 NEXT I
80 PRINTAT 0, 0, "Custom X tile drawn.", WHITE, BLACK
90 TILE 5, 2, 200, CYAN, BLACK
100 PRINTAT 7, 2, "< that is tile 200", WHITE, BLACK
110 PRINTAT 0, 4, "Pixel at (0,0) = " + STR$(TILEBIT(200, 0, 0)), WHITE, BLACK
120 PAUSE
130 TILESAVE "mytiles"
140 PRINTAT 0, 6, "Saved to mytiles.nwtile.", WHITE, BLACK
150 PAUSE
160 TILECLEAR 200
170 TILE 5, 8, 200, CYAN, BLACK
180 PRINTAT 7, 8, "< tile 200 cleared", WHITE, BLACK
190 PAUSE
200 TILELOAD "mytiles"
210 TILE 5, 10, 200, CYAN, BLACK
220 PRINTAT 7, 10, "< reloaded from file", WHITE, BLACK
230 PAUSE
240 TILERESTORE 200
250 TILE 5, 12, 200, CYAN, BLACK
260 PRINTAT 7, 12, "< reverted to font glyph", WHITE, BLACK
270 PAUSE
280 END
```

**Custom tile commands:**

| Command | Syntax | Description |
|---------|--------|-------------|
| `TILEDEF` | `TILEDEF code [,w [,h]]` | Create/reset custom tile. Default size = current cell pixel size. |
| `TILEPX` | `TILEPX code, x, y [,on]` | Set pixel at (x,y) in tile. `on` defaults to 1 (set); pass 0 to clear. |
| `TILECLEAR` | `TILECLEAR code` | Clear all pixels in tile (keeps the definition). |
| `TILERESTORE` | `TILERESTORE code` | Remove custom tile; code reverts to font glyph. |
| `TILESAVE` | `TILESAVE "filename"` | Save all custom tiles to `filename.nwtile`. |
| `TILELOAD` | `TILELOAD "filename"` | Load custom tiles from `filename.nwtile`. |
| `TILEBIT` | `TILEBIT(code, x, y)` | Read a custom tile pixel: returns 1 (set) or 0 (clear). |

### Tile Editor (`TILEEDIT`)

From the program editor (not during `RUN`), type **`TILEEDIT`** or **`TE`** to open the visual tile painter. It edits the same in-memory tile definitions as `TILEDEF` / `TILEPX` — anything you paint is immediately available to `TILE`, `TILEBIT`, and `TILESAVE` in your next `RUN`.

The editor opens at **16×16** pixels per tile by default; default starting code is **200**. Custom tiles scale with your program's `MODE 2` cell size at run time — paint in the editor, then use `MODE 2, 32` or `MODE 2, 8` in your program without repainting. Edits persist in memory until you quit NW-BASIC.

| Key | Action |
|-----|--------|
| Arrows | Move cursor |
| Space / Enter | Paint pixel on (or off in erase mode) |
| `B` | Toggle **PAINT** / **ERASE** (banner turns red in erase mode) |
| `C` | Cycle pen color (preview tint) |
| `N` / `P` | Next / previous tile character code (200, 201, …) |
| `F` / `V` | Flip horizontal / vertical |
| `X` | Clear all pixels (one-level revert snapshot stored) |
| `R` / `U` | Revert last clear — restore tile as it was before `X` |
| `G` | Use font glyph for this code (drops custom bitmap) |
| `S` | Save — type a new filename or pick from list, then Enter |
| `L` | Load `.nwtile` file |
| Mouse | Click grid to paint |
| ESC | Exit editor (tiles remain in memory) |

Typical workflow:

```basic
' In editor: TILEEDIT — paint tile 200, save as "ships"
10 MODE 2, 16
20 TILELOAD "ships"
30 TILE 10, 5, 200, YELLOW, BLACK
40 END
```

### Low-resolution graphics with TILEEDIT and saved tilesets

MODE 2 is a **tile framebuffer**: every cell is a character code plus foreground and background colors. Codes **0–255** normally come from the active font sheet; codes you override with `TILEDEF` / `TILEEDIT` become **custom bitmaps** tinted by the cell's foreground color. That is how you build sprite-style graphics in pure BASIC without MODE 3 pixels.

**Author once, run many times**

1. In the **program editor** (not during `RUN`), type **`TILEEDIT`** (or **`TE`**). Examples use `MODE 2, 16`; try `MODE 2, 32` in your run program for larger on-screen sprites.
2. Paint sprites at dedicated codes — e.g. **200** = player ship, **201** = asteroid, **202** = power-up. Use **N** / **P** to change the active code.
3. Press **S**, type a filename (e.g. `space_tiles`), press Enter. NW-BASIC writes `Documents/BasicInterpreter/space_tiles.nwtile`.
4. Exit with **ESC**. Tiles stay in memory until you quit the app; the `.nwtile` file is what your programs load later.
5. In your BASIC program:

```basic
10 MODE 2, 16
20 CLSCHAR 32, WHITE, BLACK
30 TILELOAD "space_tiles"          ' loads every custom tile in the file
40 TILE 18, 18, 201, LIME, BLACK   ' stamp ship at column 18, row 18
50 TILE 32, 3, 202, CYAN, BLACK    ' stamp planet
60 PRINTAT 1, 0, "SCORE 1200", YELLOW, BLACK   ' text and sprites coexist
70 END
```

**Design tips**

- One tile code = one shape. To show two different ships at once, paint **two** codes (200 and 201), not two versions of 200.
- **Color variation** without extra art: draw the same code with different `TILE` foreground colors (the bitmap is a mask).
- **Screen size** depends on cell size: roughly 40×24 at 16×16, fewer but bigger cells at 32×32 (`MODE 2, 32`), more cells at 8×8 (`MODE 2, 8`). Pick one style and use it consistently in a project.
- **`TILEBIT(code, x, y)`** reads mask pixels for collision or animation logic.
- Large levels: build a **tile map** (`MAPNEW` / `MAPSET` / `MAPDRAW`) whose cells use your custom codes, then `TILELOAD` before `MAPDRAW`.

**Worked example in the repo:** `diagnostics/mode2_custom_tile_scene.bas` builds a small space scene (star, ship, planet, moon, flame), saves `space_tiles.nwtile`, clears definitions, reloads from disk, and draws the scene — 5/5 autotest PASS. `diagnostics/mode2_custom_circuit_showcase.bas` is a larger 32×32-cell circuit diagram built entirely with programmatic `TILEPX` art.

### Tile Maps

Tile maps are large off-screen layers (up to 256×256 cells) stored separately from the display grid. Paint cells with `MAPSET`, then blit the whole map to the screen with `MAPDRAW`. Maps persist in memory for the current `RUN`; use `MAPSAVE` / `MAPLOAD` to store them as `.nwmap` files under `Documents/BasicInterpreter/`.

| Command | Syntax | Description |
|---------|--------|-------------|
| `MAPNEW` | `MAPNEW w, h [, name]` | Create a new map filled with spaces (char 32, white on black). Optional `name` defaults to `"map"`. |
| `MAPSET` | `MAPSET x, y, code [, fg [, bg]]` | Set one cell on the active map. Colors default to the cell's existing fg/bg. |
| `MAPDRAW` | `MAPDRAW [, col [, row [, name]]]` | Copy map cells onto the display grid at `(col, row)`. Defaults: `0, 0`, active map. |
| `MAPSAVE` | `MAPSAVE "filename"` | Save the active map to `filename.nwmap`. |
| `MAPLOAD` | `MAPLOAD "filename"` | Load a map from `filename.nwmap` and make it active. |

**`.nwmap` format (NWMAP1):** text file with header lines `NAME`, `SIZE`, `DEF` (default char/fg/bg), one `ROW` line per row (`ROW,row,char,fg,bg,...`), and `END`. Paths omit the extension in BASIC — `.nwmap` is appended automatically.

Example — draw a bordered room, save, reload:

```basic
10 MODE 2, 16
20 MAPNEW 40, 24, "room"
30 FOR X = 0 TO 39
40   MAPSET X, 0, 35
50   MAPSET X, 23, 35
60 NEXT X
70 FOR Y = 0 TO 23
80   MAPSET 0, Y, 35
90   MAPSET 39, Y, 35
100 NEXT Y
110 MAPSET 20, 12, 42, YELLOW, BLACK
120 MAPDRAW 0, 0
130 MAPSAVE "myroom"
140 END
```

Verified by `diagnostics/mode2_tile_map_smoke.bas` (4/4 PASS).

### Viewport clipping (`VIEW`)

`VIEW` defines a rectangular **clip region** on the tile grid (column, row, width, height). While active, `PRINT`, `PRINTAT`, `TILE`, `BOX`, `FILL`, `HLINE`, `VLINE`, `SCROLL`, `CLSCHAR`, and `MAPDRAW` only affect cells inside the viewport; cells outside are left unchanged. `VIEW OFF` restores full-screen drawing.

| Command | Syntax | Description |
|---------|--------|-------------|
| `VIEW` | `VIEW col, row, w, h` | Enable clipping to the given cell rectangle |
| `VIEW OFF` | `VIEW OFF` | Disable clipping (full grid) |

Draw a frame **before** `VIEW` to mark the window border; paint game content **after** `VIEW` so HUD text outside the playfield stays put.

```basic
10 MODE 2, 16
20 CLSCHAR 32, WHITE, BLACK
30 PRINTAT 0, 0, "STATUS BAR", YELLOW, BLACK
40 VIEW 2, 2, 36, 20
50 MAPDRAW 0, 0
60 PRINTAT 4, 4, "PLAYFIELD", GREEN, BLACK
70 END
```

Verified by `diagnostics/mode2_view_clip_smoke.bas` (6/6 PASS).

**Tile size gallery:** `diagnostics/mode2_tile_size_gallery.bas` draws the same ship-in-context scene at `MODE 2, 8`, then `16`, then `32` (screenshot captures the final 32×32 frame). Add `PAUSE` lines between sections when stepping through manually.

---

## MODE 3 Commands (Pixel Graphics)

MODE 3 renders to a full-screen pixel surface. Text overlay `PRINT` is available at the same time. Coordinates are in **pixels** from the top-left corner.

### PSET (MODE 3)
`PSET` draws a single pixel at the given x, y coordinate. Color defaults to white if omitted. `PLOT` is an alias for the same command. Syntax: `PSET x, y [, color]`

```basic
10 MODE 3
20 PRINT "PSET draws individual pixels."
30 PSET 100, 180, RED         ' Red pixel at (100, 180)
40 PSET 200, 220              ' White pixel (default color)
50 PRINT "Look below the text for two pixels."
60 PAUSE
70 END
```

### PLOT (MODE 3)
`PLOT` is an alias for `PSET` in MODE 3. Syntax: `PLOT x, y [, color]`

```basic
10 MODE 3
20 PRINT "PLOT is the MODE 3 alias for PSET."
30 PLOT 320, 240, GREEN
40 PRINT "A green pixel was plotted near the center."
50 PAUSE
60 END
```

### CIRCLE (MODE 3 only)
`CIRCLE` draws a circle centered at (x, y) with the given radius. Pass a fill flag of 1 and a fill color to draw a solid circle. Syntax: `CIRCLE x, y, radius [, lineColor [, fillFlag [, fillColor]]]`
```basic
10 MODE 3
20 PRINT "CIRCLE can draw outlines and filled circles."
30 CIRCLE 240, 260, 50, WHITE                    ' Outline circle
40 CIRCLE 420, 260, 50, YELLOW, 1, BLUE          ' Filled circle (fillFlag=1)
50 PRINT "Left is outline. Right is filled blue with yellow edge."
60 PAUSE
70 END
```

### LINE (MODE 3 only)
`LINE` draws a straight line between two pixel coordinates. Thickness defaults to 1 if omitted. Syntax: `LINE x1, y1, x2, y2 [, color [, thickness]]`
```basic
10 MODE 3
20 PRINT "LINE draws accelerated pixel lines."
30 LINE 100, 220, 500, 360, GREEN                ' Green diagonal line
40 LINE 100, 260, 500, 260, CYAN, 4              ' Thick cyan horizontal line
50 PRINT "The horizontal line uses thickness 4."
60 PAUSE
70 END
```

### BOX (MODE 3)
In MODE 3, `BOX` draws a pixel-coordinate rectangle outline or filled box. Syntax: `BOX x1, y1, x2, y2 [, lineColor [, fillFlag [, fillColor [, thickness]]]]`
```basic
10 MODE 3
20 PRINT "BOX draws rectangles in pixel coordinates."
30 BOX 100, 220, 300, 320, WHITE                    ' Outline only
40 BOX 360, 220, 560, 320, MAGENTA, 1, DKGRAY, 4    ' Filled, thick border
50 PRINT "Left is outline. Right is filled."
60 PAUSE
70 END
```

### POINT (MODE 3)
`POINT` reads back the color of a pixel at the given coordinates and returns it as a numeric color value — the same kind of number that color names like `RED` or `BLUE` represent internally. Returns -1 if the pixel surface is not available. Syntax: `POINT(x, y)`

Color names are stored as integers in BGR (blue-green-red) byte order, which is GameMaker's native format. `RED` = 255 (full red channel, zero blue and green), so seeing `255` when you read back a red pixel is correct, not an error. You can compare the result directly to a named color:

```basic
10 MODE 3
20 PRINT "POINT reads back a pixel color."
30 PSET 100, 180, RED
40 C = POINT(100, 180)
50 PRINT "Color value:"; C
60 IF C = RED THEN PRINT "Confirmed: pixel is RED" ELSE PRINT "Color mismatch"
70 PAUSE
80 END
```

### PAINT (MODE 3)
`PAINT` flood-fills a connected region on the pixel surface, starting at the seed pixel. Syntax: `PAINT x, y [, color]`

```basic
10 MODE 3
20 CLS
30 BOX 40, 40, 200, 200, WHITE, 1, BLUE
40 PAINT 100, 100, RED
50 IF POINT(100, 100) = RED THEN PRINT "PAINT filled the interior."
60 PAUSE
70 END
```

### DRAW (MODE 3)
`DRAW` executes a **vector command string** (QBASIC-style turtle graphics). Use `COLOR` before `DRAW` to set the pen color, or `C` inside the string. Default scale is `4` (`S4`), so `R10` moves 10 pixels. Pen position, scale, and angle persist across `DRAW` calls until the next `RUN`.

| Code | Action |
|------|--------|
| `U` `D` `L` `R` [n] | Up / down / left / right (default n=1) |
| `E` `F` `G` `H` [n] | Diagonal moves |
| `M x,y` | Move absolute; `M+x,+y` is relative |
| `B` | Prefix: move without drawing (e.g. `BM100,100`) |
| `C` [color] | Set pen color (numeric or name like `CRED`) |
| `S` n | Set scale (pixels per unit = n÷4) |
| `A` n | Rotate move angles n degrees |
| `P` | Prefix: flood-fill after move (like `PAINT`) |
| `N` | End `P` / `B` prefix mode |

```basic
10 MODE 3
20 CLS
30 COLOR YELLOW
40 DRAW "S4BM160,200R60D60L60U60"
50 DRAW "BM200,120CREDR40D40L40U40"
60 PAUSE
70 END
```

### CLS (MODE 3)
`CLS` in MODE 3 clears the entire pixel surface to black.
```basic
10 MODE 3
20 PRINT "CLS clears the MODE 3 pixel surface."
30 BOX 100,220,260,320, MAGENTA
40 PAUSE
50 CLS   ' Clears the screen surface to black
60 PRINT "The box is gone after CLS."
70 PAUSE
80 END
```

---

## Sprite System

NW-BASIC includes a hardware-accelerated sprite system that works in any mode. Sprites are 16×16 pixel bitmaps drawn directly by the GameMaker engine, supporting rotation, scaling, and circular collision detection. Up to 64 sprites (slots 1–64) can be active at once.

Sprites are defined with `SPRITE DEF`, displayed with `SPRITE SHOW`, repositioned with `SPRITE MOVE`, and cleaned up with `SPRITE CLEAR`. Because one line of BASIC executes per game frame, a `WHILE` loop with `SPRITE MOVE` inside it produces smooth per-frame animation automatically.

### Sprite Commands

| Command | Syntax | Description |
|---------|--------|-------------|
| `SPRITE DEF` | `SPRITE DEF slot, "hexstr"` | Define a monochrome sprite. 64 hex characters = 256 bits, MSB first, top row to bottom. |
| `SPRITE FG` | `SPRITE FG slot, color` | Set the on-pixel color using a palette index 1–15. |
| `SPRITE BG` | `SPRITE BG slot, color` | Set the off-pixel color. 0 = transparent (default). |
| `SPRITE SHOW` | `SPRITE SHOW slot, x, y [, angle]` | Make a sprite visible at screen coordinates (x, y), optionally rotated. |
| `SPRITE HIDE` | `SPRITE HIDE slot` | Hide a single sprite. |
| `SPRITE HIDE ALL` | `SPRITE HIDE ALL` | Hide all active sprites. |
| `SPRITE MOVE` | `SPRITE MOVE slot, x, y` | Reposition a visible sprite. Use in a loop for animation. |
| `SPRITE ANGLE` | `SPRITE ANGLE slot, angle` | Set rotation in degrees (0 = pointing right, 90 = up). |
| `SPRITE SCALE` | `SPRITE SCALE slot, factor` | Game pixels per sprite pixel. Default 4 renders a 16px sprite as 64×64 on screen. |
| `SPRITE COLOR` | `SPRITE COLOR slot` | Switch slot to colour mode (used with `SPRITE ROW`). |
| `SPRITE ROW` | `SPRITE ROW slot, row, "hexstr"` | Set one row of a colour-mode sprite. Each nibble = one pixel, palette index 0–15. |
| `SPRITE CLEAR` | `SPRITE CLEAR` | Destroy all sprite instances and free all sprite assets. |

### Sprite Functions

| Function | Description |
|----------|-------------|
| `SPRITEX(n)` | Returns the current X position of sprite n. |
| `SPRITEY(n)` | Returns the current Y position of sprite n. |
| `SPRITEHIT(n, m)` | Returns 1 if sprites n and m overlap, 0 if not. Uses circular collision — radius = `scale × 8`. |

### Sprite Palette (Color Indexes 1–15)

| Index | Color | Index | Color |
|-------|-------|-------|-------|
| 1 | Black | 9 | Orange |
| 2 | White | 10 | Pink |
| 3 | Dark Red | 11 | Dark Grey |
| 4 | Cyan | 12 | Mid Grey |
| 5 | Purple | 13 | Light Green |
| 6 | Green | 14 | Light Blue |
| 7 | Blue | 15 | Light Grey |
| 8 | Yellow | | |

### Monochrome Sprite Definition

A 16×16 monochrome sprite is defined by 64 hex characters. Each nibble represents 4 pixels (MSB = leftmost), scanning left to right, top to bottom. A `1` bit lights the pixel in the foreground color; a `0` bit shows the background color (or nothing if BG is transparent).

```basic
10 REM ** Orbiting Sprite Demo **
20 SPRITE DEF 1, "003C7EFFFFFFFFFFFFFFFF7E3C00000000000000000000000000000000000000"
30 SPRITE FG 1, 13
40 SPRITE SHOW 1, 320, 200, 0
50 FOR A = 0 TO 360 STEP 5
60   SPRITE ANGLE 1, A
70   SPRITE MOVE 1, 320 + COS(A*3.14159/180)*100, 200 + SIN(A*3.14159/180)*100
80 NEXT A
90 SPRITE CLEAR
100 END
```

The sprite orbits the center of the screen, rotating as it goes. Because each BASIC line runs on a separate game frame, the FOR loop produces 72 smooth animation steps at 60 fps.

### Collision Detection Example

`SPRITEHIT` tests whether two sprites overlap using circular distance — a hit is detected when the centers are closer than the sum of both radii (radius = `scale × 8` pixels). The demo below drives two sprites toward each other and reacts the moment they collide.

```basic
10 REM ** Two Sprites Collide **
20 SPRITE DEF 1, "000000003CC37FF7FFFFFFFFFFFFFFFFFFFFFFFFFFFF7FF73CC3000000000000"
30 SPRITE DEF 2, "000000003CC37FF7FFFFFFFFFFFFFFFFFFFFFFFFFFFF7FF73CC3000000000000"
40 SPRITE FG 1, 6
50 SPRITE FG 2, 3
60 X1 = 80 : X2 = 1200
70 SPRITE SHOW 1, X1, 400, 0
80 SPRITE SHOW 2, X2, 400, 180
90 WHILE SPRITEHIT(1, 2) = 0
100   X1 = X1 + 10 : X2 = X2 - 10
110   SPRITE MOVE 1, X1, 400 : SPRITE MOVE 2, X2, 400
120 WEND
130 SPRITE ANGLE 1, 35 : SPRITE ANGLE 2, 215
140 SPRITE FG 1, 9 : SPRITE FG 2, 9
150 PRINT "*** CRASH! ***"
160 PRINT "PRESS ANY KEY..."
170 K$ = INKEY$        ' modal wait — blocks until a key is pressed
180 SPRITE CLEAR
190 END
```

Both sprites move 10 pixels per frame (one line = one frame). At collision the angles are skewed and both sprites turn orange before the program waits for a keypress. Line 170 uses bare `INKEY$` on purpose — that is the modal “press any key” form, not a poll loop.

### Notes

- Sprite coordinates are in screen pixels from the top-left corner. At the default 1280×800 resolution, center is approximately (640, 400).
- Sprites persist after a program ends so you can see the final frame. They are cleared when you type `NEW` or call `SPRITE CLEAR`.
- All sprite command arguments accept BASIC expressions and variables — `SPRITE MOVE 1, X, Y` and `SPRITE ANGLE 1, A*2` both work inside loops.
- Up to 64 sprite slots are available, numbered 1–64.
- `SPRITE SCALE` default is 4 (a 16-pixel sprite renders 64 game pixels wide). Increase it for big, chunky retro sprites.

---

## File I/O

NW-BASIC supports reading and writing text files using numbered channels (1 and up).

```basic
10 OPEN "data.txt" FOR OUTPUT AS #1    ' Create/overwrite file
20 PRINT #1, "Hello"                   ' Write a line
30 PRINT #1, "Value="; 42             ' Write with expression
40 CLOSE #1                            ' Close the file

50 OPEN "data.txt" FOR INPUT AS #1     ' Open for reading
60 WHILE NOT EOF(1)
70   INPUT #1, LINE$                   ' Read one line (whole-line, type-converted)
80   PRINT LINE$
90 WEND
100 CLOSE #1

110 OPEN "log.txt" FOR APPEND AS #2    ' Append to existing file
120 PRINT #2, "New entry"
130 CLOSE #2
140 PRINT "File write, read, and append demo complete."
150 PAUSE
160 END
```

**LINE INPUT #n** reads a whole line as a string, without any type conversion:
```basic
10 OPEN "notes.txt" FOR OUTPUT AS #1
20 PRINT #1, "This whole line will be read back."
30 CLOSE #1
40 OPEN "notes.txt" FOR INPUT AS #1
50 LINE INPUT #1, L$    ' Reads entire line into L$ as-is
60 CLOSE #1
70 PRINT "LINE INPUT read: "; L$
80 PAUSE
90 END
```

**Notes:**
- **Desktop:** files are stored in `Documents/BasicInterpreter/`.
- **Browser:** files are stored in the browser's IndexedDB virtual filesystem and persist across page reloads automatically. `SAVE`, `LOAD`, and `DIR` all use this storage — no extra steps needed.
- Channel numbers are integers (1, 2, 3, ...).
- `EOF(n)` returns -1 (true in BASIC) when channel n is at end of file, 0 otherwise.
- `OPEN` modes: `INPUT`, `OUTPUT`, `APPEND`.
- Opening a channel that is already open closes the old handle first.

---

## Math Functions

NW-BASIC includes a standard set of math functions. Each can be used anywhere an expression is accepted — in PRINT, LET, IF, and FOR statements.

| Function | Returns |
|----------|---------|
| `ABS(x)` | Absolute value |
| `INT(x)` | Floor — rounds down toward negative infinity |
| `FIX(x)` | Truncate toward zero (`FIX(-3.7)` → `-3`) |
| `CINT(x)` | Round to nearest integer (half away from zero) |
| `SGN(x)` | Sign: -1, 0, or 1 |
| `SQR(x)` | Square root |
| `EXP(x)` | e raised to the power x |
| `LOG(x)` | Base-10 logarithm |
| `LOG10(x)` | Base-10 logarithm (alias) |
| `SIN(x)` | Sine (radians) |
| `COS(x)` | Cosine (radians) |
| `TAN(x)` | Tangent (radians) |
| `ATN(x)` | Arctangent (radians) |
| `RND(n)` | Random integer 1 to n; `RND(a,b)` = random a to b; `RND(1)` = 0..1 float |

```basic
10 PRINT "Math function sampler:"
20 PRINT "ABS(-7) ="; ABS(-7)
30 PRINT "INT(3.9) ="; INT(3.9)
35 PRINT "FIX(-3.7) ="; FIX(-3.7)
36 PRINT "CINT(2.5) ="; CINT(2.5)
40 PRINT "SGN(-5) ="; SGN(-5)
50 PRINT "SQR(25) ="; SQR(25)
60 PRINT "EXP(1) ="; EXP(1)
70 PRINT "LOG(100) ="; LOG(100)
80 PAUSE
90 END
```

### Trigonometric Functions (radians)
All trig functions work in radians. To convert degrees to radians, multiply by π/180 (approximately 0.01745).
```basic
10 PRINT SIN(1.5708)   ' Sine: ~1
20 PRINT COS(0)        ' Cosine: 1
30 PRINT TAN(0.7854)   ' Tangent: ~1
40 PRINT ATN(1) * 4    ' Pi: ~3.14159 (ATN = arctangent)
50 PAUSE
60 END
```

### Random Numbers
`RND` generates random numbers. Pass one argument for a random integer from 1 to N, two arguments for a range, or `RND(1)` for a floating-point value between 0 and 1. Always call `RANDOMIZE` first if you want a different sequence each run.
```basic
10 RANDOMIZE
20 PRINT "Random die roll:"; RND(6)
30 PRINT "Random 1 to 10:"; RND(1, 10)
40 X = RND(1)
50 PRINT "Random fraction:"; X
60 PAUSE
70 END
```

Use `RANDOMIZE` to seed the random number generator before calling `RND`.

---

## String Functions

String functions let you inspect and manipulate text. String variable names end with `$`. These functions can be combined — for example, `LEFT$(UCASE$(A$), 3)` uppercases a string and then takes the first three characters.

```basic
10 A$ = "HELLO WORLD"
20 PRINT "Working with: " + A$
30 PRINT LEFT$(A$, 5)      ' "HELLO"
40 PRINT RIGHT$(A$, 5)     ' "WORLD"
50 PRINT MID$(A$, 7, 5)    ' "WORLD" (start position, length)
60 L = LEN(A$)             ' String length: 11
70 PRINT "Length is "; L
80 PRINT UCASE$("hello")   ' "HELLO"
90 PRINT LCASE$("WORLD")   ' "world"
100 PRINT LTRIM$("  hi")   ' "hi"
110 PRINT RTRIM$("hi  ")   ' "hi"
120 P = INSTR(A$, "WORLD") ' Position of "WORLD" in A$: 7 (0 if not found)
130 PRINT "WORLD starts at "; P
140 PAUSE
150 END
```

### Repeat, Fill, and Padding
These functions build strings by repeating a character or inserting spaces — handy for drawing separators, padding columns, and aligning output.

- `REPEAT$(str, n)` — repeats a string n times
- `STRING$(code, n)` — repeats a character (by ASCII code or single-char string) n times
- `SPACE$(n)` — returns a string of n spaces (alias: `SPC(n)` inside PRINT)

```basic
10 PRINT "Drawing text separators with string builders."
20 PRINT REPEAT$("#", 30)        ' "##############################"
30 PRINT STRING$(61, 20)         ' "====================" (ASCII 61 = '=')
40 PRINT STRING$("*", 10)        ' "**********"
50 PRINT "Name" + SPACE$(16) + "Score"
60 PRINT "Alice" + SPACE$(15) + "98"
70 PRINT "Bob" + SPACE$(17) + "74"
80 PAUSE
90 END
```

### Conversion Functions
These functions convert between numbers and strings, and between characters and their ASCII codes.
```basic
10 PRINT "Converting between numbers and strings."
20 N$ = STR$(123)      ' Number to string: "123"
30 N = VAL("3.14")     ' String to number: 3.14
40 PRINT "STR$(123)=" + N$
50 PRINT "VAL(""3.14"")="; N
60 PRINT CHR$(65)      ' ASCII code to character: "A"
70 C = ASC("A")        ' Character to ASCII code: 65
80 PRINT "ASC(""A"")="; C
90 PAUSE
100 END
```

---

## System Functions

### INKEY$ - Keyboard Input
`INKEY$` reads one character from the keyboard queue. NW-BASIC supports two behaviors:

**Modal wait (blocking)** — the program pauses until the user presses a key. Use this for “press any key to continue” prompts:

```basic
10 PRINT "Press any key to continue..."
20 K$ = INKEY$         ' waits here until a key is pressed
30 PRINT "You pressed: "; K$
40 PAUSE
50 END
```

**Non-blocking poll** — the program keeps running and checks whether a key is already waiting. Use this inside game loops. Add `+ ""` (or use `INKEY$` inside another expression) so the interpreter does not enter modal wait:

```basic
10 PRINT "Press A to finish (other keys are ignored)."
20 K$ = INKEY$ + ""    ' returns "" immediately if no key is queued
30 IF K$ = "" THEN GOTO 20
40 IF K$ <> "A" AND K$ <> "a" THEN
50   PRINT "Ignoring "; K$
60   GOTO 20
70 ENDIF
80 PRINT "You pressed A."
90 PAUSE
100 END
```

- **Poll loops:** use `K$ = INKEY$ + ""` or `IF INKEY$ + "" <> "" THEN ...`. Bare `K$ = INKEY$` waits every time it runs.
- Keys are read from a per-frame queue; `""` means no key was waiting.
- Arrow keys and other extended keys arrive as two-character sequences (`CHR$(0)` + `CHR$(scan_code)`).
- **Keyboard limitation:** `INKEY$` reports **physical key codes**, not shifted/layout characters. Unshifted letters, digits, and space work as expected. Shifted punctuation (e.g. Shift+8 for `*`) may return the base key (`8`). Numpad keys may not match their labels. Use **INPUT** when you need arbitrary typed text; use `INKEY$` for game controls and simple key waits.

### Mobile/Touch Support (Android)
On Android, the screen is divided into touch regions that inject keystrokes as if the user pressed a key — so `INKEY$`-based programs work on touch devices without modification.
- Top-center touch → `"W"`, Bottom-center → `"S"`, Left-center → `"A"`, Right-center → `"D"`

### PEEK and POKE — Virtual byte memory

`POKE addr, value` stores one byte (0–255) at an address. `PEEK(addr)` reads it back. Syntax: `POKE 1000, 65` and `X = PEEK(1000)`.

**What this is:** a private 64K scratch map (addresses 0–65535) inside NW-BASIC. Each `RUN` clears it unless you resumed from a `STOP` breakpoint (variables and this map are both preserved in that case).

**What this is not:** real PC RAM, C64/VIC memory, or a way to reach the tile grid, sprites, or GameMaker directly. For graphics use `PSET`/`PAINT`; for named data use variables and arrays.

**Why use it today?** Retro BASIC books and tutorials often teach packed bytes and fixed addresses. NW-BASIC keeps that learning path alive in a safe sandbox. Modern uses that fit well:

| Use | Idea |
|-----|------|
| Game flags | One byte per switch: door open, key found, boss defeated |
| High score bytes | Store three bytes for scores up to 16,777,215 |
| Phase / mode byte | `0` = title, `1` = play, `2` = game over |
| Tiny buffers | ASCII codes, simple tables, lookup data |
| Teaching | Addresses, bytes, and “memory maps” without risking the host OS |

**Suggested address layout (convention only — your program chooses):**

| Range | Suggested use |
|-------|----------------|
| 0–255 | System / temp (avoid for saves) |
| 1000–1099 | User “save” slot — flags and scores |
| 2000–2127 | 128-byte scratch buffer (one row of a small map) |

#### Example: pack a high score into three bytes

```basic
10 REM Store SCORE across bytes 1000–1002 (up to 16,777,215)
20 SCORE = 123456
30 POKE 1000, SCORE \ 65536
40 POKE 1001, (SCORE \ 256) MOD 256
50 POKE 1002, SCORE MOD 256
60 REM Read back:
70 H = PEEK(1000) * 65536 + PEEK(1001) * 256 + PEEK(1002)
80 PRINT "Stored score:"; H
90 PAUSE
100 END
```

#### Example: game state flags

```basic
10 REM Flag bytes: 1000=level done, 1001=has key, 1002=lives
20 POKE 1002, 3          ' 3 lives
30 POKE 1001, 0          ' no key yet
40 IF PEEK(1001) = 0 THEN PRINT "Find the key."
50 POKE 1001, 1          ' picked up key
60 IF PEEK(1001) = 1 THEN PRINT "You can open the door."
70 PAUSE
80 END
```

#### Example: ASCII character in a byte

```basic
10 POKE 2000, 65         ' ASCII 'A'
20 PRINT "Character at 2000: "; CHR$(PEEK(2000))
30 PAUSE
40 END
```

For larger or named structures, prefer `DIM`, variables, and `DATA` streams. Use PEEK/POKE when you want fixed addresses, packed bytes, or a retro machine feel — not because it is faster or more powerful than normal BASIC storage.

#### BSAVE and BLOAD — save bytes to disk

`BSAVE "filename", addr, length` writes a byte range from the virtual map to `Documents/BasicInterpreter/` (adds `.nwmem` if you omit an extension). Unset addresses in the range are saved as `0`. `BLOAD "filename", addr` reads the payload back starting at `addr`.

**File format:** 7-byte magic `NWBMEM1`, then start address and length as 32-bit values, then raw bytes.

```basic
10 POKE 1000, 65
20 POKE 1001, 66
30 BSAVE "mydata", 1000, 2
40 POKE 1000, 0
50 POKE 1001, 0
60 BLOAD "mydata", 1000
70 PRINT CHR$(PEEK(1000)); CHR$(PEEK(1001))
80 PAUSE
90 END
```

Like `TILESAVE` / `OPEN`, paths are relative to the NW-BASIC save folder, not GameMaker project files.

### Time and Date
These functions return the current system time and date as strings, and a running timer in seconds since the program started — useful for measuring elapsed time or timestamping saved data.
```basic
10 PRINT "Time and date functions:"
20 PRINT TIME$         ' Current time: "HH:MM:SS"
30 PRINT DATE$         ' Current date: "YYYY-MM-DD"
40 T = TIMER           ' Seconds since game start (integer)
50 PRINT "Timer seconds:"; T
60 PAUSE
70 END
```

### Cursor Position — POS and CSRLIN
`POS` and `CSRLIN` return the current print cursor column and row. These are useful for aligning output dynamically without hardcoding positions.

- `POS` — returns the current cursor column (0-based)
- `CSRLIN` — returns the current cursor row (0-based)

```basic
10 PRINT "Line one"
20 PRINT "Line two"
30 R = CSRLIN
40 PRINT "Cursor is now on row "; R
50 PRINT "Cursor column before this print: "; POS
60 PAUSE
70 END
```

---

## Data Handling

### DATA / READ / RESTORE
`DATA` stores a list of literal values inside the program itself. `READ` pulls the next value from that list into a variable. `RESTORE` resets the read pointer back to the beginning so the data can be read again. This is useful for tables, level data, or any fixed set of values you want to embed in the program.
```basic
10 DATA 1, 2, 3, "HELLO", 5.5
20 READ X, Y, Z, MSG$, F
30 PRINT X, Y, Z, MSG$, F
40 RESTORE             ' Reset data pointer to the beginning
50 READ FIRST          ' Read 1 again
60 PRINT "After RESTORE, first value is "; FIRST
70 PAUSE
80 END
```

### Named Data Streams
Named streams let you group related `DATA` values under a label so they can be read and restored independently. Prefix the label with `@` in the `DATA`, `READ`, and `RESTORE` statements. This is useful when one program has several embedded tables, such as names, scores, map rows, or menu text.

Syntax: `DATA @name: value1, value2, ...`

Syntax: `READ @name, var1 [, var2 ...]`

Syntax: `RESTORE @name`

The example below creates two independent streams. It reads two numbers from `@numbers`, reads one name from `@names`, restores only `@numbers`, then proves that `@names` kept its own position by reading `BOB` next.

```basic
10 PRINT "NAMED DATA STREAMS"
20 PRINT "Create @numbers and @names as separate DATA streams."
30 DATA @numbers: 1, 2, 3, 4, 5
40 DATA @names: "ALICE", "BOB", "CHARLIE"
50 PRINT "Read two values from @numbers into X and Y."
60 READ @numbers, X, Y
70 PRINT "X="; X; " Y="; Y
80 PRINT "Read one value from @names into N$."
90 READ @names, N$
100 PRINT "N$=["; N$; "]"
110 PRINT "Restore only @numbers."
120 RESTORE @numbers
130 READ @numbers, A
140 PRINT "After RESTORE @numbers, A="; A
150 PRINT "@names was not restored, so the next name is BOB."
160 READ @names, B$
170 PRINT "B$=["; B$; "]"
180 IF X=1 AND Y=2 AND N$="ALICE" AND A=1 AND B$="BOB" THEN PRINT "PASS NAMED DATA STREAMS" ELSE PRINT "FAIL NAMED DATA STREAMS"
190 PAUSE
200 END
```

---

## Color Control

### COLOR and BGCOLOR
`COLOR` sets the foreground (text) color for subsequent `PRINT` output. Optionally pass a second argument for the background color at the same time. `BGCOLOR` sets only the background. Colors can be named constants or custom RGB values.
```basic
10 PRINT "COLOR changes following PRINT output."
20 COLOR RED
30 PRINT "This line is red."
40 COLOR GREEN, BLACK
50 PRINT "This line is green on black."
55 PAUSE:CLS
60 BGCOLOR BLUE
70 COLOR WHITE: PRINT "The background is now blue."
80 COLOR RGB(255, 128, 0)
90 PRINT "This uses a custom RGB color."
100 PAUSE
110 END
```

### Hex Color Forms
In addition to named colors and `RGB(r,g,b)`, NW-BASIC accepts several hex forms in `COLOR`, `BGCOLOR`, and tile color arguments:

| Form | Example | Notes |
|------|---------|-------|
| `&HBBGGRR` | `COLOR &H0000FF` | QBASIC-style byte order (blue, green, red) |
| `$RRGGBB` | `COLOR $00FF00` | Six-digit RGB hex |
| `#RRGGBB` | `BGCOLOR #000080` | Same as `$` form |

```basic
10 COLOR &H0000FF       ' Red (&H BBGGRR)
20 PRINT "Line 1: &H red"
30 COLOR $00FF00        ' Green ($ RRGGBB)
40 PRINT "Line 2: $ green"
50 BGCOLOR #000080      ' Navy background
60 COLOR WHITE
70 PRINT "Line 3: white on navy"
80 PAUSE
90 END
```

`LIGHTGRAY` / `LIGHTGREY` and `GREY` / `GRAY` are accepted aliases.

### Available Named Colors
Named colors include `BLACK`, `WHITE`, `RED`, `GREEN`, `BLUE`, `CYAN`, `MAGENTA`, `YELLOW`, `GRAY`, `DKGRAY`, `ORANGE`, `LIME`, and `NAVY`.

**Note:** `COLOR` and `BGCOLOR` apply to subsequent `PRINT` output. Individual tile commands (`PRINTAT`, `CHARAT`, `PSET`, etc.) take their own fg/bg color arguments and do not use these globals.

---

## Operators

### Arithmetic
The standard math operators. `\` is integer division (drops the remainder), `^` is exponentiation (power), and `MOD` or `%` gives the remainder after division.
```basic
10 PRINT 5 + 3         ' Addition: 8
20 PRINT 10 - 4        ' Subtraction: 6
30 PRINT 6 * 7         ' Multiplication: 42
40 PRINT 15 / 3        ' Division: 5.0
50 PRINT 17 \ 5        ' Integer division (truncates toward zero): 3
60 PRINT 2 ^ 3         ' Exponentiation: 8
70 PRINT 17 MOD 5      ' Modulo: 2
80 PRINT 17 % 5        ' Modulo (alternate): 2
90 PAUSE
100 END
```

### Comparison
Comparison operators test the relationship between two values and return true or false, which is what `IF` acts on.
```basic
10 LET X = 5 : LET Y = 5 : LET A = 3 : LET B = 7
20 IF X = Y THEN PRINT "X = Y — equal."
30 IF A <> B THEN PRINT "A <> B — not equal."
40 IF A < 10 THEN PRINT "A < 10 — less than."
50 IF B > 5 THEN PRINT "B > 5 — greater than."
60 IF X <= 100 THEN PRINT "X <= 100 — less than or equal."
70 IF B >= 5 THEN PRINT "B >= 5 — greater than or equal."
80 PAUSE
90 END
```

### Logical
`AND` and `OR` combine multiple conditions inside an `IF`. Use `AND` when all conditions must be true; use `OR` when any one of them is enough. `NOT` inverts a condition — `NOT (X = 5)` is true when X is anything other than 5.
```basic
10 LET X = 8 : LET Y = 7
20 IF X > 5 AND Y < 10 THEN PRINT "AND: both conditions true."
30 LET A = 1 : LET B = 9
40 IF A = 1 OR B = 2 THEN PRINT "OR: at least one condition true."
50 LET DONE = 0
60 IF NOT DONE THEN PRINT "NOT: DONE is 0 (false), so NOT DONE is true."
70 DONE = 1
80 IF NOT DONE THEN PRINT "This will NOT print." ELSE PRINT "NOT: DONE is 1, so NOT DONE is false."
90 PAUSE
100 END
```

### String Concatenation
Use `+` to join two strings into one.
```basic
10 FIRST$ = "Hello"
20 SECOND$ = "World"
30 FULL$ = FIRST$ + " " + SECOND$
40 PRINT FULL$
50 PAUSE
60 END
```

---

## Editor Commands

These commands are typed at the prompt without a line number (immediate mode). They cannot be used inside a program.

### Program Management

| Command | Description |
|---------|-------------|
| `RUN` | Run the current program |
| `NEW` | Clear the program from memory |
| `LIST` | List all program lines |
| `LIST 100` | Jump the editor view to line 100 (or next stored line) |
| `LIST 10-50` | List lines 10 through 50 |
| `GO 100` or `G 100` | Jump the editor view to line 100 |
| `SAVE "filename"` | Save program to disk (`.bas` extension added automatically) |
| `LOAD "filename"` | Load a program from disk |
| `DIR` | Open the interactive file browser |
| `DIR IMPORT` | Open the OS file picker to import a `.bas` file (browser only) |
| `HELP` | Open the built-in help browser |
| `:PASTE` | Paste a multi-line program from the clipboard |
| `:LOADURL url` | Fetch and load a program from a URL (browser only) |
| `SCREENEDIT` or `SE` | Enter full-screen C64-style editor |
| `QUIT` or `Q` | Exit NW-BASIC |

### File Browser (DIR)
- Arrow keys to navigate
- Enter to load the selected file
- D/X/Delete to delete the selected file
- Esc to close

### Screen Editor (SCREENEDIT / SE)
- Arrow keys to navigate lines
- Type directly to edit
- Enter commits the current line
- Esc returns to line editor
- Home/End for line navigation
- Page Up/Down to scroll

### Navigation Shortcuts

| Key | Action |
|-----|--------|
| `PageUp` | Scroll backward through code listing |
| `PageDown` | Scroll forward through code listing |
| `Esc` (during RUN) | Exit interpreter and return to editor |
| `Up Arrow` | Navigate up through command history |
| `Down Arrow` | Navigate down through command history |
| `Ctrl+Z` | Undo last change |

---

## Browser (Web) Edition

NW-BASIC runs in the browser at **[johnnwfs.net/NW-BASIC](https://johnnwfs.net/NW-BASIC/)**. The web edition works the same as the desktop version with a few differences in how files are handled and how programs can be loaded.

### File Storage in the Browser
Saved programs are stored in the browser's **IndexedDB** virtual filesystem. They persist across page reloads and browser restarts automatically — just `SAVE myprogram` and it will be there next session. Each browser/device has its own independent storage.

### Browser-Only Commands

| Command | Description |
|---------|-------------|
| `SAVE "name"` | Save the current program to IndexedDB. Triggers a download to your local disk as well so you keep a copy. |
| `LOAD "name"` | Load a previously saved program from IndexedDB. |
| `DIR` | Open the file browser showing all programs saved in IndexedDB. Press D/X/Delete to remove a file. |
| `DIR IMPORT` | Open your OS file picker. Select any `.bas` file from your computer — it is loaded into the editor and also saved to IndexedDB for future sessions. |
| `:LOADURL url` | Fetch a plain-text `.bas` program from any URL and load it into the editor. Example: `:LOADURL https://johnnwfs.net/NW-BASIC/demos/mode1_fizzbuzz.bas` |
| `:PASTE` | Paste a complete multi-line BASIC program from your clipboard directly into the editor. |

### Demo Programs
Three demo programs are hosted on the server and ready to load:

| URL | Mode | Description |
|-----|------|-------------|
| `https://johnnwfs.net/NW-BASIC/demos/mode1_fizzbuzz.bas` | Mode 1 (text) | FizzBuzz 1–30 using `FOR`, `MOD`, `IF/AND`, and a summary table |
| `https://johnnwfs.net/NW-BASIC/demos/mode2_mosaic.bas` | Mode 2 (tile) | Checkerboard mosaic with colored border and title box |
| `https://johnnwfs.net/NW-BASIC/demos/mode3_geometric.bas` | Mode 3 (pixel) | Concentric rainbow circles, starburst, and corner ornaments |
| `https://johnnwfs.net/NW-BASIC/demos/car_crash.bas` | Sprites | Two sprites drive toward each other and collide with `SPRITEHIT` |

**To run a demo:**
```
:LOADURL https://johnnwfs.net/NW-BASIC/demos/mode1_fizzbuzz.bas
RUN
```

### Notes
- **File I/O** (`OPEN`/`CLOSE`/`PRINT #n`) writes to IndexedDB, not your local disk. The data is readable within the same session and persists between sessions in the same browser.
- **No keyboard paste into the canvas** is supported yet — to paste a program use `:PASTE` or `DIR IMPORT`.
- The `:LOADURL` command requires the file to be served with CORS headers or be on the same domain (`johnnwfs.net`).

---

## Error Handling

- **Syntax errors** show the line number and a description.
- **Runtime errors** include hints to help diagnose the problem.
- Pre-execution validation checks for mismatched `IF`/`ENDIF`, `FOR`/`NEXT`, `WHILE`/`WEND`, and `GOSUB`/`RETURN`.
- `INKEY$` usage is validated (must appear in an assignment or expression — e.g. `K$ = INKEY$`, `K$ = INKEY$ + ""`, or `IF INKEY$ + "" <> ""`).
- Command arguments are validated before they reach GameMaker runtime calls. Malformed numeric arguments such as `BOX x1,y1,80,80` should produce a clean NW-BASIC syntax error instead of a GameMaker fatal error.
- Program state is preserved after errors so you can inspect variables.
- NW-BASIC should handle ordinary syntax and runtime errors itself. If you still find a GameMaker fatal error, please report the error text and, if possible, the NW-BASIC code that triggered it.
---

## Programming Tips

1. **Use meaningful names**: `SCORE` instead of `S` — your future self will thank you.
2. **Comment your code**: `REM` or `'` explains *why*, not just what.
3. **Use subroutines**: Put repeated logic in `GOSUB` routines. Always place `END` before the subroutine block so normal flow doesn't fall into it.
4. **Indent loop bodies**: NW-BASIC ignores leading spaces, so indenting `FOR`/`NEXT` and `WHILE`/`WEND` bodies makes structure obvious at a glance.
5. **PAUSE after output**: Any time you switch modes or print something important, add `PAUSE` so the user can read it before the screen changes.
6. **Avoid magic numbers**: `LET MAXROWS = 20` is easier to update than hardcoding `20` in five places.
7. **GOSUB for menus**: `ON N GOSUB 1000, 2000, 3000` dispatches to a menu branch cleanly from a single line.
8. **RESTORE for replay**: If you read DATA values in a loop, call `RESTORE` at the top of the loop to re-read them from the start each time.
9. **Use STR$ and VAL**: Mixing numbers into strings requires `STR$(n)`; reading numbers from file or input requires `VAL(s$)`. Forgetting these is a common source of type errors.
10. **Test in small pieces**: Write a few lines, run them, check the output. In BASIC, incremental testing is faster than debugging a large program all at once.
11. **INKEY$ modal vs poll**: `K$ = INKEY$` waits for a key; `K$ = INKEY$ + ""` polls without stopping. Game loops need the `+ ""` form (or an expression like `LEN(INKEY$ + "")`).
12. **PEEK/POKE is virtual**: fixed-address byte storage for flags, packed scores, and retro tutorials — not real machine RAM. Prefer variables/arrays for big structures.

---

## Example Programs

### Number Guessing Game
```basic
10 REM ** Number Guessing Game **
20 CLS : COLOR YELLOW
30 PRINT "Guess the number (1-100)!"
40 SECRET = RND(1, 100)
50 TRIES = 0
60 INPUT "Your guess: ", GUESS
70 TRIES = TRIES + 1
80 IF GUESS = SECRET THEN GOTO 140
90 IF GUESS < SECRET THEN PRINT "Too low!"
100 IF GUESS > SECRET THEN PRINT "Too high!"
110 IF TRIES >= 10 THEN GOTO 130
120 GOTO 60
130 PRINT "Sorry! The number was "; SECRET : END
140 COLOR GREEN
150 PRINT "Correct! You got it in "; TRIES; " tries!"
160 BEEP O1 C0.5 E0.5 G1
170 END
```

### Musical Scale
```basic
10 REM ** Musical Scales **
20 CLS
30 PRINT "Playing C Major Scale..."
40 BEEP C1 D1 E1 F1 G1 A1 B1 O1 C1
50 PRINT "Playing Chromatic Scale..."
60 BEEP C0.5 C#0.5 D0.5 Eb0.5 E0.5 F0.5 F#0.5 G0.5
70 BEEP G#0.5 A0.5 Bb0.5 B0.5 O1 C1
80 END
```

### Tile Graphics Demo (MODE 2)
```basic
10 REM ** Tile Border Demo **
20 MODE 2, 16
30 CLSCHAR 32, WHITE, BLACK
40 BOX 0, 0, 19, 12, 35, YELLOW, BLACK    ' '#' border
50 FILL 1, 1, 18, 11, 32, BLACK, BLACK    ' Clear interior
60 PRINTAT 3, 5, "TILE GRAPHICS", CYAN, BLACK
70 PRINTAT 3, 7, "NW-BASIC MODE 2", GREEN, BLACK
80 PAUSE
90 END
```

### Pixel Graphics Demo (MODE 3)
```basic
10 REM ** Pixel Drawing Demo **
20 MODE 3
30 CLS
40 CIRCLE 320, 240, 100, WHITE
50 CIRCLE 320, 240, 60, YELLOW, 1, BLUE
60 LINE 100, 100, 540, 380, RED, 2
70 BOX 400, 50, 580, 150, GREEN, 1, DKGRAY
80 PRINT "MODE 3 PIXEL GRAPHICS"
90 PAUSE
100 END
```

### Music Demo — Für Elise (Beethoven)
The opening theme of Beethoven's Für Elise, arranged for `BEEP`. Demonstrates octave switching mid-sequence, rests, and tempo control. `O1` is one octave above middle C; `O0` is middle C.

```basic
10 PRINT "FUR ELISE - NW-BASIC DEMO"
20 PRINT "Ludwig van Beethoven"
30 PRINT "Opening theme excerpt"
40 PAUSE

50 TEMPO 110
60 PRINT "PLAYING..."

70 BEEP O1 E0.5 D#0.5 E0.5 D#0.5 E0.5 O0 B0.5 O1 D0.5 C0.5
80 BEEP O0 A1 R0.5 C0.5 E0.5 A0.5
90 BEEP O0 B1 R0.5 E0.5 G#0.5 B0.5
100 BEEP O1 C1 R0.5 O0 E0.5 O1 E0.5 D#0.5

110 BEEP O1 E0.5 D#0.5 E0.5 D#0.5 E0.5 O0 B0.5 O1 D0.5 C0.5
120 BEEP O0 A1 R0.5 C0.5 E0.5 A0.5
130 BEEP O0 B1 R0.5 E0.5 O1 C0.5 O0 B0.5
140 BEEP O0 A2 R1

150 PRINT "DONE."
160 TEMPO 120
170 PAUSE
180 END
```

### File I/O Example
```basic
10 REM ** Write and Read a Data File **
20 OPEN "scores.txt" FOR OUTPUT AS #1
30 FOR I = 1 TO 5
40   PRINT #1, "Score "; I; " = "; RND(1, 100)
50 NEXT I
60 CLOSE #1
70 PRINT "Written. Now reading..."
80 OPEN "scores.txt" FOR INPUT AS #1
90 WHILE NOT EOF(1)
100   INPUT #1, L$
110   PRINT L$
120 WEND
130 CLOSE #1
140 END
```

---

## Planned / Not Yet Implemented

These features are on the roadmap but not yet available:

- MODE 3 drawing extras (ellipse/arc options, sprite overlays)

---

This manual covers all implemented features of NW-BASIC. The language supports traditional line-by-line BASIC programming, structured block `IF` statements, subroutines, file I/O, tile graphics, and pixel graphics. The `BEEP` command adds musical capabilities, making it possible to create programs that combine computation, graphics, and sound.

---

## Contact

Questions, feedback, bug reports, and retro BASIC ideas are welcome. You can write to John at **JohnNWFSDeveloper@gmail.com**, contact him on X/Twitter at **@JohnNWFS**, or reach out through Instagram @john__h__.
