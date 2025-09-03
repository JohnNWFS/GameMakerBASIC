# NW-BASIC

A lightweight, custom-built BASIC interpreter and code editor created using **GameMaker Studio**. This project aims to recreate the feel of early home computer BASIC environments—reimagined for modern use and ultimately targeting **Android deployment**.

> **Built for fun**, educational exploration, and retro coding joy — this project is co-developed using LLMs (Large Language Models) to assist with iterative code design, debugging, and feature expansion.

---

## 🎯 Project Goals

- Build a **fully functional** interpreted BASIC environment from scratch
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
- [Input/Output Commands](#inputoutput-commands)
- [Program Control](#program-control)
- [Mode Control](#mode-control)
- [MODE 1 Commands](#mode-1-commands)
- [Math Functions](#math-functions)
- [String Functions](#string-functions)
- [System Functions](#system-functions)
- [Data Handling](#data-handling)
- [Array Operations](#array-operations)
- [Color Control](#color-control)
- [Editor Commands](#editor-commands)
- [Advanced Features](#advanced-features)
- [Error Handling](#error-handling)
- [Programming Tips](#programming-tips)
- [Advanced Topics](#advanced-topics)

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
10 PRINT "A"; : PRINT "B" : PRINT "C"
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

### Arrays (1D Only)
```basic
10 DIM A(10)        ' Creates array A with indices 0-10
20 DIM B(5), C$(20) ' Multiple arrays
30 A(3) = 42        ' Set array element
40 PRINT A(3)       ' Read array element
```
**Note:** Only 1-dimensional arrays are supported.

---

## Input/Output Commands

### PRINT
```basic
10 PRINT "Hello World"
20 PRINT X          ' Print variable
30 PRINT "X="; X    ' Print with semicolon (no newline)
40 PRINT A, B, C    ' Multiple values (comma-separated)
```

**Special Print Behavior:**
- `;` at the end of a `PRINT` line **suppresses the newline**, continuing on the next `PRINT`.
- `+` is used to concatenate strings and variables:

```basic
10 PRINT "HELLO ";
20 PRINT name$
30 PRINT "HELLO " + name$
```

### INPUT
```basic
10 INPUT "Enter name: ", N$
20 INPUT X          ' Prompt with "? "
30 INPUT "Age"; AGE ' Semicolon separator also works
```

### CLS
```basic
10 CLS              ' Clear screen (MODE 0: clears text output)
                    ' (MODE 1: clears grid and resets cursor)
```

---

## Program Control

### Conditional Statements

#### Inline IF
```basic
10 IF X = 5 THEN PRINT "Five"
20 IF A > B THEN PRINT "A bigger" ELSE PRINT "B bigger"
30 IF X = 1 THEN Y = 2 : Z = 3     ' Multiple statements
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

#### Advanced IF Constructs
```basic
10 IF condition1 AND condition2 OR condition3 THEN
20   PRINT "Complex logic"
30 ENDIF

' Nested conditions supported
40 IF X > 0 THEN IF Y > 0 THEN PRINT "Both positive"
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

40 FOR J = 10 TO 1 STEP -2  ' With step
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

### Program Flow
```basic
10 GOTO 50          ' Jump to line 50
20 END              ' End program
30 PAUSE            ' Pause until ENTER pressed
```

---

## Mode Control

**Note:** Unless specifically noted as MODE 1, all commands are intended for MODE 0 (text mode, the default).

### Mode Switching
```basic
10 MODE 0           ' Text mode (default - no command needed)
20 MODE 1           ' Tile graphics mode  
30 MODE 1, 8        ' Tile mode with 8x8 pixel tiles
40 MODE 1, 16       ' Tile mode with 16x16 pixel tiles
50 MODE 1, 32       ' Tile mode with 32x32 pixel tiles (default)
```

---

## MODE 1 Commands (Tile Graphics)

### Character/Tile Graphics
```basic
10 PSET 10, 5, 65, WHITE, BLACK    ' Set char 'A' at (10,5)
20 CHARAT 0, 0, 72                 ' Set char 'H' at top-left
30 CHARAT 5, 5, 32, RED            ' Set space with red foreground
40 PRINTAT 5, 10, "HELLO"          ' Print text at position
50 PRINTAT 0, 0, "TEST", BLUE, YELLOW  ' With colors
60 CLSCHAR 32, GREEN, BLACK        ' Fill screen with spaces
```

### Font Control (MODE 1)
```basic
10 FONT "DEFAULT_16"    ' Switch to 16x16 font
20 FONT "8x8"          ' Switch to 8x8 font
30 FONTSET "DEFAULT_8"  ' Lock font to 8x8 (prevents MODE changes)
```

Available fonts: DEFAULT_8, DEFAULT_16, DEFAULT_32, SPECIAL, 16x16, etc.

### Screen Positioning (MODE 1)
```basic
10 LOCATE 5, 10        ' Set cursor to row 5, column 10
20 SCROLL "UP", 3      ' Scroll screen up 3 lines
30 SCROLL "DOWN", 1    ' Scroll down 1 line
40 SCROLL "LEFT", 2    ' Scroll left 2 columns
50 SCROLL "RIGHT", 1   ' Scroll right 1 column
60 SCROLL 2            ' Scroll up 2 lines (default direction)
```

### Color Functions (MODE 1)
Get information about screen contents:
```basic
10 C = mode1_get_char(10, 5)    ' Get character at position
20 CLR = mode1_get_color(10, 5) ' Get foreground color at position
```

### Additional MODE 1 Features
```basic
10 FONTSET "DEFAULT_8"     ' Lock font (prevents MODE changes)
20 ' Grid refresh and management
30 ' Automatic cursor tracking
40 ' Character-based graphics with full color control
```

---

## Math Functions

### Basic Math Functions
```basic
10 PRINT ABS(-5)       ' Absolute value: 5
20 PRINT INT(3.7)      ' Integer part: 3
30 PRINT SGN(-10)      ' Sign: -1, 0, or 1
40 PRINT EXP(1)        ' e^1
50 PRINT LOG(100)      ' Base-10 logarithm
60 PRINT LOG10(1000)   ' Base-10 logarithm: 3
```

### Trigonometric Functions
```basic
10 PRINT SIN(1.57)     ' Sine (radians)
20 PRINT COS(0)        ' Cosine: 1
30 PRINT TAN(0.785)    ' Tangent
```

### Random Numbers
```basic
10 PRINT RND(6)        ' Random 1-6
20 PRINT RND(1, 10)    ' Random between 1-10
30 X = RND(1)          ' Random 0-1 (floating point)
40 Y = RND             ' Same as RND(1)
```

### Operators
```basic
10 PRINT 5 + 3         ' Addition: 8
20 PRINT 10 - 4        ' Subtraction: 6
30 PRINT 6 * 7         ' Multiplication: 42
40 PRINT 15 / 3        ' Division: 5
50 PRINT 17 \ 5        ' Integer division: 3 (truncates toward zero)
60 PRINT 2 ^ 3         ' Exponentiation: 8
70 PRINT 17 MOD 5      ' Modulo: 2
80 PRINT 17 % 5        ' Modulo (alternate): 2
```

---

## String Functions

### String Manipulation
```basic
10 A$ = "HELLO WORLD"
20 PRINT LEFT$(A$, 5)      ' "HELLO"
30 PRINT RIGHT$(A$, 5)     ' "WORLD"
40 PRINT MID$(A$, 7, 5)    ' "WORLD" (start pos, length)
50 PRINT REPEAT$("#", 10)  ' "##########"
60 L = LEN(A$)             ' String length: 11
```

### String Conversion
```basic
10 N$ = STR$(123)          ' Convert number to string: "123"
20 PRINT CHR$(65)          ' Convert ASCII to char: "A"
30 C = ASC("A")            ' Convert char to ASCII: 65
```

### String Concatenation
```basic
10 FIRST$ = "Hello"
20 LAST$ = "World"
30 FULL$ = FIRST$ + " " + LAST$   ' "Hello World"
```

---

## System Functions

### INKEY$ - Advanced Keyboard Input
```basic
10 K$ = INKEY$         ' Get keypress without waiting (returns "" if none)
20 IF K$ <> "" THEN PRINT "Key pressed: "; K$
30 ' INKEY$ captures extended keys as 2-character sequences:
40 ' Arrow keys return CHR$(0) + scan code
50 ' Supports full printable ASCII range (32-126)
60 ' Queue-based system prevents key loss
```

### Mobile/Touch Support (Android)
- Screen divided into directional regions for INKEY$ input
- Touch top-center: "W", bottom-center: "S" 
- Touch left-center: "A", touch right-center: "D"
- Enables mobile-friendly game control schemes

### Time and Date
```basic
10 PRINT TIME$         ' Current time: "HH:MM:SS"
20 PRINT DATE$         ' Current date: "YYYY-MM-DD"
30 T = TIMER           ' Seconds since program start
```

---

## Data Handling

### DATA/READ/RESTORE
```basic
10 DATA 1, 2, 3, "HELLO", 5.5
20 READ X, Y, Z, MSG$, F
30 PRINT X, Y, Z, MSG$, F
40 RESTORE             ' Reset data pointer
50 READ FIRST          ' Read 1 again
```

### Named Data Streams
```basic
10 DATA @numbers: 1, 2, 3, 4, 5
20 DATA @names: "ALICE", "BOB", "CHARLIE"
30 READ @numbers, X, Y
40 READ @names, N$
50 RESTORE @numbers    ' Reset specific stream
```

---

## Array Operations

### Array Declaration and Usage
```basic
10 DIM A(10)           ' Creates array A with indices 0-10
20 DIM B(5), C$(20)    ' Multiple arrays in one statement
30 A(0) = 42           ' Set first element
40 A(10) = 99          ' Set last element (arrays are 0-based)
50 PRINT A(5)          ' Read array element
60 FOR I = 0 TO 10     ' Loop through array
70   A(I) = I * 2      ' Set each element
80 NEXT I
```

### Advanced Array Operations
```basic
10 DIM A(X+5)          ' Dynamic sizing with expressions
20 A(I*2+1) = VALUE    ' Complex index expressions
30 A(RND(1,10)) = 42   ' Random index access
```

**Note:** Only 1-dimensional arrays are supported. Arrays use 0-based indexing.

---

## Color Control

### Text Colors
```basic
10 COLOR RED           ' Set text color to red
20 COLOR GREEN, BLACK  ' Set text to green on black background
30 BGCOLOR BLUE        ' Set background color only
40 COLOR RGB(255,128,0)' Custom color (orange)
```

### Advanced Color Specifications
```basic
10 COLOR &HFF8000       ' Hexadecimal color (orange)
20 COLOR #FF8000        ' Web-style hex color
30 COLOR $FF8000        ' Dollar-prefix hex
40 COLOR 16711680       ' Decimal color value
50 COLOR LIGHTGRAY      ' Additional color names supported
```

### Available Colors
- RED, GREEN, BLUE, CYAN, MAGENTA, YELLOW
- WHITE, BLACK, GRAY, DKGRAY, LIGHTGRAY, ORANGE, LIME, NAVY

---

## Comparison Operators

```basic
10 IF X = Y THEN PRINT "Equal"
20 IF A <> B THEN PRINT "Not equal"  
30 IF X < 10 THEN PRINT "Less than"
40 IF Y > 5 THEN PRINT "Greater than"
50 IF Z <= 100 THEN PRINT "Less or equal"
60 IF W >= 50 THEN PRINT "Greater or equal"
```

---

## Editor Commands
(Entered in immediate mode, not in programs)

### Built-in Editor Commands
All editor commands are typed on a line that **does not begin with a number**:

| Command | Action |
|---------|--------|
| `RUN` | Run the current BASIC program in the interpreter |
| `NEW` | Clear program (same as CLEAR) |
| `CLEAR` | Wipe all program lines from memory |
| `LIST` | Display all currently stored BASIC lines |
| `LIST 10-50` | List lines 10 through 50 |
| `F5` | Output the full program as a raw BASIC listing to console |
| `:PASTE` | Paste multi-line programs from clipboard |
| `SCREENEDIT` or `SE` | Enter full-screen C64-style editor |
| `QUIT` | Exit BASIC |

### File Operations (Enhanced)
```
SAVE "filename"       - Auto-adds .bas extension
LOAD "filename"       - Supports drag-and-drop loading
DIR                   - Interactive file browser with:
                       * Arrow key navigation
                       * Enter to load
                       * D/X to delete (desktop only)
                       * ESC to close
```

### Screen Editor Mode
```
SCREENEDIT or SE      - Enter full-screen editor
                      - Use arrow keys to navigate
                      - Type directly to edit lines
                      - ENTER commits current line
                      - ESC exits back to line editor
                      - Home/End for line navigation
                      - Page Up/Down for scrolling
```

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

## Advanced Features

### Expression Evaluation
The BASIC interpreter supports complex expressions in most contexts:
```basic
10 X = (A + B) * SIN(C) + RND(1,6)
20 IF (X > Y AND Z < 100) OR W = 0 THEN PRINT "Complex condition"
30 A(I+1) = B(J*2) + C(K)  ' Array indexing with expressions
```

### Advanced Expression Features
- **Parentheses for precedence**: `(A + B) * C`
- **Function calls in expressions**: `SIN(X) + COS(Y)`
- **Nested function calls**: `LEFT$(STR$(X), 3)`
- **Array access in expressions**: `A(B(C))`
- **Mixed string/numeric operations** with auto-conversion

### Program Validation
- **Pre-execution syntax checking**
- **INKEY$ usage validation** (must be in assignments)
- **Matching IF/ENDIF, FOR/NEXT, WHILE/WEND** validation
- **DATA stream integrity** checking
- **Comprehensive error reporting** with hints

### Memory Management
- Variables are automatically created when first assigned
- Arrays must be dimensioned with DIM before use (except auto-growing in assignments)
- String variables automatically distinguished by $ suffix

---

## Error Handling

The interpreter provides comprehensive error handling:
- **Syntax errors** show exact line and position
- **Runtime errors** with helpful hints
- **INKEY$ usage validation** (must be in assignments)
- **Comprehensive validation** before program execution
- **Graceful error recovery** with program state preservation

---

## Programming Tips

1. **Use meaningful variable names**: `SCORE` instead of `S`
2. **Comment your code**: Use `REM` or `'` for documentation
3. **Structure with subroutines**: Break complex logic into GOSUB routines
4. **Test incrementally**: Run small sections before building larger programs
5. **Use MODE commands**: Switch to graphics modes for visual programs
6. **Leverage INKEY$**: Create responsive, interactive programs
7. **Use arrays wisely**: Remember they're 0-based and 1-dimensional only

---

## Example Program

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
160 END
```

---

## Advanced Topics

### Debug Features
**Debug Control (Advanced users)**
- F5 in interpreter: Dump program to console
- Extensive debug logging with categories
- Performance monitoring with frame quotas
- Error tracing and validation

### Performance Features
- **Automatic memory management**
- **Efficient data structure usage**
- **Queue-based input handling**
- **Optimized expression evaluation**
- **Configurable debug output quotas**

### Code Architecture Notes
The interpreter includes several sophisticated features:
- **Quote-aware parsing** throughout
- **Proper operator precedence**
- **Statement-level jumping** for complex control flow
- **Comprehensive validation pipeline**
- **Multiple font support systems**
- **Advanced expression evaluation** with function calls

---

This manual covers all the major features of this BASIC interpreter. The language supports both traditional line-by-line BASIC programming and more modern structured programming with block IF statements and proper variable scoping.
