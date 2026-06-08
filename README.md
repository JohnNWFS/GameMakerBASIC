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
- [File I/O](#file-io)
- [Math Functions](#math-functions)
- [String Functions](#string-functions)
- [System Functions](#system-functions)
- [Data Handling](#data-handling)
- [Color Control](#color-control)
- [Operators](#operators)
- [Editor Commands](#editor-commands)
- [Error Handling](#error-handling)
- [Programming Tips](#programming-tips)
- [Example Programs](#example-programs)

---

## Program Structure

### Line Numbers
```basic
10 PRINT "Hello World"
20 END
```
- Line numbers: 1-65535
- Lines executed in order unless redirected by GOTO/GOSUB
- Comments: `REM` or `'` (apostrophe)

### Multiple Statements
```basic
10 PRINT "A" : PRINT "B" : PRINT "C"
```
Use colons (`:`) to separate multiple statements on one line.

---

## Variables and Data Types

### Variable Assignment
```basic
10 LET X = 5        ' Numeric variable
20 A$ = "HELLO"     ' String variable ($ suffix)
30 Y = X + 10       ' LET keyword optional
```

- Numeric variables default to 0 if read before being set.
- String variables default to `""` if read before being set.
- Variable names are case-insensitive. `score` and `SCORE` are the same variable.

---

## Arrays

```basic
10 DIM A(10)           ' 1-D array with indices 0-10 (11 elements)
20 DIM B(5), C$(20)    ' Multiple declarations in one statement
30 DIM M(3, 4)         ' 2-D array: valid indices (0..3, 0..4)
40 A(3) = 42           ' Set element
50 PRINT A(3)          ' Read element
60 M(1, 2) = 99        ' Set 2-D element
70 PRINT M(1, 2)       ' Read 2-D element
```

- Arrays are **0-based** by default (index 0 through N).
- Use `OPTION BASE 1` to switch to 1-based indexing.
- 1-D and 2-D arrays are supported. Arrays must be declared with `DIM` before use.
- `ERASE name` removes an array from memory.

```basic
10 OPTION BASE 1        ' Arrays use indices 1..N
20 DIM A(10)            ' A(1) through A(10)
```

---

## Input/Output Commands

### PRINT
```basic
10 PRINT "Hello World"
20 PRINT X                  ' Print variable
30 PRINT "X="; X            ' Semicolon: no space between items
40 PRINT A, B, C            ' Comma: tab-stop spacing
50 PRINT "Hi ";             ' Trailing semicolon suppresses newline
60 PRINT TAB(10); "here"    ' TAB(n) moves to column n
70 PRINT SPC(5); "spaced"   ' SPC(n) inserts n spaces
```

**Special print behavior:**
- `;` suppresses the newline and prints the next item immediately.
- `,` advances to the next tab zone (approximately every 14 characters).
- `TAB(n)` and `SPC(n)` work inside PRINT statements.
- `+` concatenates strings: `PRINT "Hello " + name$`

### INPUT
```basic
10 INPUT "Enter name: ", N$   ' Prompt with literal string
20 INPUT X                    ' Prompt with "? "
30 INPUT "Age"; AGE           ' Semicolon separator also works
```

### CLS
```basic
10 CLS   ' Clear screen
         ' MODE 1 (text): clears text output
         ' MODE 2 (tile): clears the tile grid and resets cursor
         ' MODE 3 (pixel): clears pixel surface
```

### PAUSE
```basic
10 PAUSE   ' Pause execution until the user presses Enter
```

### LOCATE (MODE 2 only)
```basic
10 LOCATE row, col   ' Set cursor position for next PRINT (1-based)
20 LOCATE 5, 10      ' Row 5, column 10
```
LOCATE has no effect in MODE 1 text mode.

### SCROLL (MODE 2 only)
```basic
10 SCROLL UP, 3       ' Scroll tile grid up 3 rows
20 SCROLL DOWN, 1     ' Scroll down 1 row
30 SCROLL LEFT, 2     ' Scroll left 2 columns
40 SCROLL RIGHT, 1    ' Scroll right 1 column
50 SCROLL 2           ' Scroll up 2 rows (direction defaults to UP)
```

---

## Sound Commands

### BEEP - Musical Note Sequences
```basic
10 BEEP C1             ' Play middle C for 1 beat
20 BEEP A0.5 B0.5 C2   ' A eighth, B eighth, C half note
30 BEEP C#1 Db1 F#2    ' Sharps (#) and flats (b) supported
40 BEEP R1 C1          ' R1 = 1-beat rest, then C
50 BEEP O2 C1 D1       ' O2 = octave 2, affects following notes
60 BEEP O-1 A4 O1 G2   ' Octave changes apply until changed again
```

#### BEEP Syntax
```
BEEP <spec> [<spec> ...]
```

**Note Specifications:**
- **Note**: `A`, `B`, `C`, `D`, `E`, `F`, `G` or `R` (rest)
- **Accidentals**: `#` (sharp) or `b` (flat) — e.g., `C#`, `Bb`
- **Duration**: Number of beats — `1` = quarter, `2` = half, `4` = whole, `0.5` = eighth, `0.25` = sixteenth
- **Octave**: `O<number>` sets octave; changes persist until the next `O` token

#### BEEP Examples
```basic
10 ' C major scale
20 BEEP C1 D1 E1 F1 G1 A1 B1 C2

30 ' Rhythm and rests
40 BEEP C0.5 C0.5 G1 R0.5 F0.5 E1

50 ' Octave shifts
60 BEEP O-1 C2 O0 C2 O1 C2

70 ' Sharps and flats
80 BEEP C1 C#1 D1 Eb1 E1
```

#### BEEP Technical Details
- Default tempo: 120 BPM (adjustable via `global.beep_tempo`)
- BEEP **blocks** program execution until the entire sequence completes
- Duration `0` is treated as `0.25` (sixteenth note)

---

## Program Control

### Conditional Statements

#### Inline IF
```basic
10 IF X = 5 THEN PRINT "Five"
20 IF A > B THEN PRINT "A bigger" ELSE PRINT "B bigger"
30 IF X = 1 THEN Y = 2 : Z = 3     ' Multiple statements in THEN arm
```

#### Block IF (Multi-line)
```basic
10 IF X > 10 THEN
20   PRINT "X is large"
30   Y = X * 2
40 ELSEIF X > 5 THEN
50   PRINT "X is medium"
60 ELSE
70   PRINT "X is small"
80 ENDIF
```

#### Logical Operators
```basic
10 IF X > 5 AND Y < 10 THEN PRINT "Both true"
20 IF A = 1 OR B = 2 THEN PRINT "Either true"
```

### Loops

#### FOR/NEXT
```basic
10 FOR I = 1 TO 10
20   PRINT I
30 NEXT I

40 FOR J = 10 TO 1 STEP -2
50   PRINT J
60 NEXT J
```

#### WHILE/WEND
```basic
10 X = 1
20 WHILE X <= 5
30   PRINT X
40   X = X + 1
50 WEND
```

### Subroutines
```basic
10 GOSUB 100
20 END
100 PRINT "Subroutine"
110 RETURN
```

### ON GOTO / ON GOSUB
```basic
10 N = 2
20 ON N GOTO 100, 200, 300   ' Jump to line 200 (N=2)
30 ON N GOSUB 100, 200       ' Call subroutine at line 200
```
If `N` is out of range (less than 1 or greater than the number of targets), execution falls through to the next line.

### Program Flow
```basic
10 GOTO 50          ' Jump unconditionally to line 50
20 END              ' End program
30 STOP             ' End program (alias for END)
```

### RANDOMIZE
```basic
10 RANDOMIZE        ' Seed RNG from system time
20 RANDOMIZE 42     ' Seed RNG with a specific value
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

```basic
10 MODE 1           ' Text mode
20 MODE 2           ' Tile graphics, default 32x32 pixel tiles
30 MODE 2, 8        ' Tile mode with 8x8 pixel tiles
40 MODE 2, 16       ' Tile mode with 16x16 pixel tiles
50 MODE 2, 32       ' Tile mode with 32x32 pixel tiles
60 MODE 3           ' Pixel graphics mode
```

Query the current mode:
```basic
10 M = GETMODE()    ' Returns 1, 2, or 3
20 M = SCREEN()     ' Alias for GETMODE()
```

---

## MODE 2 Commands (Tile Graphics)

MODE 2 uses a grid of character-sized cells. Each cell has a character code, a foreground color, and a background color. Coordinates are always **column, row** (x, y), 0-based from the top-left.

### PRINT (MODE 2)
In MODE 2, `PRINT` writes text to the tile grid at the current cursor position. Use `LOCATE` to position the cursor first.

```basic
10 MODE 2, 16
20 LOCATE 3, 5       ' Row 3, column 5
30 PRINT "Hello"     ' Prints at that position
```

### PRINTAT / DRAWSTR
```basic
10 PRINTAT col, row, "text" [, fg [, bg]]
20 PRINTAT 5, 10, "HELLO", WHITE, BLACK
30 DRAWSTR 0, 0, "TEST", BLUE, YELLOW    ' DRAWSTR is an alias for PRINTAT
```

### PSET (MODE 2)
```basic
10 PSET col, row, charCode, fg, bg
20 PSET 10, 5, 65, WHITE, BLACK   ' Place 'A' (ASCII 65) at column 10, row 5
```
All five arguments are required in MODE 2.

### CHARAT / TILE / PLOT (MODE 2)
```basic
10 CHARAT col, row, charCode [, fg [, bg]]
20 CHARAT 0, 0, 72               ' Place 'H' at top-left, preserve existing colors
30 CHARAT 5, 3, 65, RED, BLACK   ' Place 'A' with colors

40 TILE col, row, charCode [, fg [, bg]]   ' TILE is an alias for CHARAT
50 TILE 5, 5, 42, RED

60 PLOT col, row, charCode [, fg [, bg]]   ' PLOT is an alias for CHARAT in MODE 2
70 PLOT 6, 5, 42, CYAN, BLACK
```

### BOX (MODE 2)
Draws a rectangle border using the given character code.
```basic
10 BOX x1, y1, x2, y2, charCode [, fg [, bg]]
20 BOX 0, 0, 10, 4, 35, YELLOW, BLACK   ' '#' border rectangle
```

### FILL (MODE 2)
Fills a rectangular region with the given character.
```basic
10 FILL x1, y1, x2, y2, charCode [, fg [, bg]]
20 FILL 1, 1, 9, 3, 46, BLUE, BLACK    ' '.' fill
```

### HLINE / VLINE (MODE 2)
```basic
10 HLINE x1, x2, row, charCode [, fg [, bg]]
20 HLINE 0, 10, 6, 45, CYAN, BLACK     ' '-' horizontal line at row 6

30 VLINE col, y1, y2, charCode [, fg [, bg]]
40 VLINE 12, 0, 6, 124, MAGENTA, BLACK ' '|' vertical line at col 12
```

### CLSCHAR
```basic
10 CLSCHAR charCode [, fg [, bg]]
20 CLSCHAR 32, GREEN, BLACK    ' Fill entire screen with spaces
```

### Tile Grid Read Functions (MODE 2)
```basic
10 C = TILECHAR(col, row)      ' Get character code at position
20 CLR = TILECOLOR(col, row)   ' Get foreground color value at position
30 N$ = TILENAME$(CLR)         ' Convert color value to name string (e.g., "GREEN")
```

Legacy aliases (still work):
```basic
10 C = mode1_get_char(col, row)
20 CLR = mode1_get_color(col, row)
30 N$ = mode1_color_name(CLR)
```

### Font Control (MODE 2)
```basic
10 FONT "DEFAULT_16"    ' Switch to 16x16 font
20 FONT "DEFAULT_8"     ' Switch to 8x8 font
30 FONT "DEFAULT_32"    ' Switch to 32x32 font
40 FONTSET "DEFAULT_8"  ' Lock font to 8x8 (survives MODE switches)
```

Available font keys: `DEFAULT_8`, `DEFAULT_16`, `DEFAULT_32`. `FONTSET` locks the choice so that subsequent `MODE 2` switches do not override it.

---

## Custom Tiles (MODE 2)

Custom tiles are editable bitmap masks assigned to specific tile codes. When a cell uses a custom code, NW-BASIC draws the custom mask tinted with that cell's foreground color. All other codes continue to use the active font sheet, so normal text remains available alongside custom graphics.

```basic
10 MODE 2, 16
20 TILEDEF 200, 16, 16         ' Create/clear custom tile at code 200 (16x16 bitmap)
30 FOR I = 0 TO 15
40   TILEPX 200, I, I, 1       ' Set pixel on (diagonal line)
50   TILEPX 200, 15-I, I, 1   ' Set pixel on (other diagonal)
60 NEXT I
70 TILE 2, 4, 200, CYAN, BLACK ' Draw custom tile at (col 2, row 4)
80 PRINTAT 4, 4, "TEXT", WHITE, BLACK  ' Normal text beside it
90 TILESAVE "mytiles"          ' Save to mytiles.nwtile
100 TILECLEAR 200              ' Erase all pixels in tile 200 (keeps the definition)
110 TILELOAD "mytiles"         ' Reload from file
120 TILERESTORE 200            ' Remove custom override; tile 200 reverts to font glyph
130 PRINT TILEBIT(200, 0, 0)   ' Read a pixel: returns 1 or 0
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

---

## MODE 3 Commands (Pixel Graphics)

MODE 3 renders to a full-screen pixel surface. Text overlay `PRINT` is available at the same time. Coordinates are in **pixels** from the top-left corner.

### PSET (MODE 3)
```basic
10 MODE 3
20 PSET x, y [, color]       ' Draw a single pixel
30 PSET 100, 80, RED         ' Red pixel at (100,80)
40 PSET 200, 150             ' White pixel (default)
```

### PLOT (MODE 3)
```basic
10 PLOT x, y [, color]       ' Alias for PSET in MODE 3
20 PLOT 320, 240, GREEN
```

### CIRCLE (MODE 3 only)
```basic
10 CIRCLE x, y, radius [, lineColor [, fillFlag [, fillColor]]]
20 CIRCLE 320, 240, 50, WHITE                    ' Outline circle
30 CIRCLE 320, 240, 50, YELLOW, 1, BLUE          ' Filled circle (fillFlag=1)
```

### LINE (MODE 3 only)
```basic
10 LINE x1, y1, x2, y2 [, color [, thickness]]
20 LINE 0, 0, 640, 480, GREEN                    ' Green diagonal line
30 LINE 100, 200, 300, 200, CYAN, 4              ' Thick cyan horizontal line
```

### BOX (MODE 3)
In MODE 3, `BOX` draws a pixel-coordinate rectangle outline or filled box.
```basic
10 BOX x1, y1, x2, y2 [, lineColor [, fillFlag [, fillColor [, thickness]]]]
20 BOX 100, 100, 300, 200, WHITE                    ' Outline only
30 BOX 100, 100, 300, 200, MAGENTA, 1, DKGRAY, 4   ' Filled, thick border
```

### POINT (MODE 3)
```basic
10 C = POINT(x, y)   ' Returns the pixel color at (x, y), or -1 if surface not available
```

### CLS (MODE 3)
```basic
10 CLS   ' Clears the pixel surface to black
```

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
```

**LINE INPUT #n** reads a whole line as a string, without any type conversion:
```basic
10 OPEN "notes.txt" FOR INPUT AS #1
20 LINE INPUT #1, L$    ' Reads entire line into L$ as-is
30 CLOSE #1
```

**Notes:**
- Files are stored in the GameMaker save directory (`Documents/BasicInterpreter/` on desktop).
- Channel numbers are integers (1, 2, 3, ...).
- `EOF(n)` returns -1 (true in BASIC) when channel n is at end of file, 0 otherwise.
- `OPEN` modes: `INPUT`, `OUTPUT`, `APPEND`.
- Opening a channel that is already open closes the old handle first.

---

## Math Functions

```basic
10 PRINT ABS(-5)       ' Absolute value: 5
20 PRINT INT(3.7)      ' Floor (integer part): 3
30 PRINT SGN(-10)      ' Sign: -1, 0, or 1
40 PRINT SQR(16)       ' Square root: 4
50 PRINT EXP(1)        ' e^1 ≈ 2.718...
60 PRINT LOG(100)      ' Base-10 logarithm: 2  (note: both LOG and LOG10 use base 10)
70 PRINT LOG10(1000)   ' Base-10 logarithm: 3
```

### Trigonometric Functions (radians)
```basic
10 PRINT SIN(1.5708)   ' Sine: ~1
20 PRINT COS(0)        ' Cosine: 1
30 PRINT TAN(0.7854)   ' Tangent: ~1
40 PRINT ATN(1) * 4    ' Pi: ~3.14159 (ATN = arctangent)
```

### Random Numbers
```basic
10 PRINT RND(6)        ' Random integer 1-6
20 PRINT RND(1, 10)    ' Random integer between 1 and 10 (inclusive)
30 X = RND(1)          ' Random float 0.0 to 0.999...
```

Use `RANDOMIZE` to seed the random number generator before calling `RND`.

---

## String Functions

```basic
10 A$ = "HELLO WORLD"
20 PRINT LEFT$(A$, 5)      ' "HELLO"
30 PRINT RIGHT$(A$, 5)     ' "WORLD"
40 PRINT MID$(A$, 7, 5)    ' "WORLD" (start position, length)
50 L = LEN(A$)             ' String length: 11
60 PRINT UCASE$("hello")   ' "HELLO"
70 PRINT LCASE$("WORLD")   ' "world"
80 PRINT LTRIM$("  hi")    ' "hi"
90 PRINT RTRIM$("hi  ")    ' "hi"
100 P = INSTR(A$, "WORLD") ' Position of "WORLD" in A$: 7 (0 if not found)
```

### Repeat and Fill
```basic
10 PRINT REPEAT$("#", 10)     ' "##########"
20 PRINT STRING$(65, 5)       ' "AAAAA" (ASCII 65 = 'A', repeated 5 times)
21 PRINT STRING$("*", 5)      ' "*****" (character repeated 5 times)
30 PRINT SPACE$(8)            ' "        " (8 spaces)
```

### Conversion Functions
```basic
10 N$ = STR$(123)      ' Number to string: "123"
20 N = VAL("3.14")     ' String to number: 3.14
30 PRINT CHR$(65)      ' ASCII code to character: "A"
40 C = ASC("A")        ' Character to ASCII code: 65
```

---

## System Functions

### INKEY$ - Non-Blocking Keyboard Input
```basic
10 K$ = INKEY$            ' Read one keypress (returns "" if none queued)
20 IF K$ <> "" THEN PRINT "Pressed: "; K$
```
- `INKEY$` is non-blocking: it reads from a key queue and returns `""` if no key is waiting.
- Use it in a loop to create responsive interactive programs.
- Arrow keys and other extended keys arrive as two-character sequences.

### Mobile/Touch Support (Android)
- The screen is divided into directional regions that inject `INKEY$` values:
  - Top-center touch → `"W"`, Bottom-center → `"S"`, Left-center → `"A"`, Right-center → `"D"`

### Time and Date
```basic
10 PRINT TIME$         ' Current time: "HH:MM:SS"
20 PRINT DATE$         ' Current date: "YYYY-MM-DD"
30 T = TIMER           ' Seconds since game start (integer)
```

---

## Data Handling

### DATA / READ / RESTORE
```basic
10 DATA 1, 2, 3, "HELLO", 5.5
20 READ X, Y, Z, MSG$, F
30 PRINT X, Y, Z, MSG$, F
40 RESTORE             ' Reset data pointer to the beginning
50 READ FIRST          ' Read 1 again
```

### Named Data Streams
```basic
10 DATA @numbers: 1, 2, 3, 4, 5
20 DATA @names: "ALICE", "BOB", "CHARLIE"
30 READ @numbers, X, Y
40 READ @names, N$
50 RESTORE @numbers    ' Reset only the @numbers stream
```

---

## Color Control

### COLOR and BGCOLOR
```basic
10 COLOR RED                ' Set foreground text color
20 COLOR GREEN, BLACK       ' Set foreground and background
30 BGCOLOR BLUE             ' Set background color only
40 COLOR RGB(255, 128, 0)   ' Custom color using RGB values (0-255 each)
```

### Available Named Colors
```
BLACK    WHITE    RED      GREEN    BLUE
CYAN     MAGENTA  YELLOW   GRAY     DKGRAY
ORANGE   LIME     NAVY     LIGHTGRAY
```

**Note:** `COLOR` and `BGCOLOR` apply to subsequent `PRINT` output. Individual tile commands (`PRINTAT`, `CHARAT`, `PSET`, etc.) take their own fg/bg color arguments and do not use these globals.

---

## Operators

### Arithmetic
```basic
10 PRINT 5 + 3         ' Addition: 8
20 PRINT 10 - 4        ' Subtraction: 6
30 PRINT 6 * 7         ' Multiplication: 42
40 PRINT 15 / 3        ' Division: 5.0
50 PRINT 17 \ 5        ' Integer division (truncates toward zero): 3
60 PRINT 2 ^ 3         ' Exponentiation: 8
70 PRINT 17 MOD 5      ' Modulo: 2
80 PRINT 17 % 5        ' Modulo (alternate): 2
```

### Comparison
```basic
10 IF X = Y THEN PRINT "Equal"
20 IF A <> B THEN PRINT "Not equal"
30 IF X < 10 THEN PRINT "Less than"
40 IF Y > 5 THEN PRINT "Greater than"
50 IF Z <= 100 THEN PRINT "Less or equal"
60 IF W >= 50 THEN PRINT "Greater or equal"
```

### Logical
```basic
10 IF X > 5 AND Y < 10 THEN PRINT "Both true"
20 IF A = 1 OR B = 2 THEN PRINT "Either true"
```

### String Concatenation
```basic
10 FULL$ = "Hello" + " " + "World"   ' "Hello World"
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
| `HELP` | Open the built-in help browser |
| `:PASTE` | Paste a multi-line program from the clipboard |
| `:LOADURL url` | Load a program from a URL (HTML build) |
| `SCREENEDIT` or `SE` | Enter full-screen C64-style editor |
| `QUIT` or `Q` | Exit NW-BASIC |

### File Browser (DIR)
- Arrow keys to navigate
- Enter to load the selected file
- D/X to delete (desktop only)
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

## Error Handling

- **Syntax errors** show the line number and a description.
- **Runtime errors** include hints to help diagnose the problem.
- Pre-execution validation checks for mismatched `IF`/`ENDIF`, `FOR`/`NEXT`, `WHILE`/`WEND`, and `GOSUB`/`RETURN`.
- `INKEY$` usage is validated (must appear in an assignment or expression context).
- Program state is preserved after errors so you can inspect variables.

---

## Programming Tips

1. **Use meaningful names**: `SCORE` instead of `S`
2. **Comment your code**: `REM` or `'` for notes
3. **Use subroutines**: Break logic into `GOSUB` routines
4. **Test incrementally**: Run small sections before building larger programs
5. **Use MODE commands**: Switch to graphics modes for visual programs
6. **Leverage INKEY$**: Create responsive, interactive programs without blocking
7. **Arrays are 0-based by default**: Use `OPTION BASE 1` if you prefer 1-based
8. **BEEP sequences block**: Use them for sound effects and melodies
9. **File I/O saves and loads data**: Use `OPEN`/`CLOSE` for persistence

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
40 BEEP C1 D1 E1 F1 G1 A1 B1 C2
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

- `NOT` — logical NOT operator (unary prefix); not yet implemented
- `PEEK` / `POKE` — memory access (no plans to implement directly)
- `FIX`, `CINT` — additional numeric rounding functions
- 3-D arrays — planned (1-D and 2-D are implemented)
- Interactive tile editor UI, tile maps, window/clipping support
- `PAINT x,y` — flood fill for MODE 3 (planned)
- `DRAW` vector strings (classical BASIC DRAW command) — under consideration
- `STOP` as a true breakpoint (currently behaves identically to `END`)
- `ON ERROR GOTO` — error trapping

---

This manual covers all implemented features of NW-BASIC. The language supports traditional line-by-line BASIC programming, structured block `IF` statements, subroutines, file I/O, tile graphics, and pixel graphics. The `BEEP` command adds musical capabilities, making it possible to create programs that combine computation, graphics, and sound.
