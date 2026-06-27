
Running 69 programs  (skipping 5 ΓÇö {'skip_input'})

========================================================================
[01/69] #00 text          Line Numbers
       10 PRINT "This program starts at line 10."
       -> PASS  (10.8s)

[02/69] #01 text          Multiple Statements
       10 PRINT "This line prints three separate messages:"
       -> PASS  (10.8s)

[03/69] #02 text          Variable Assignment
       10 LET X = 5
       -> PASS  (10.8s)

[04/69] #03 text          Arrays
       10 DIM A(10)           ' 1-D array with indices 1-10 (10 ele
       -> PASS  (10.7s)

[05/69] #04 text          Arrays
       10 DIM SCORES(5)
       -> PASS  (10.7s)

[06/69] #05 text          Arrays
       10 PRINT "Switching arrays to OPTION BASE 0."
       -> PASS  (10.7s)

[07/69] #06 text          PRINT
       10 X = 42
       -> PASS  (10.8s)

[08/69] #08 text          CLS
       10 PRINT "This text appears before CLS."
       -> PASS  (10.7s)

[09/69] #09 text          PAUSE
       10 PRINT "Read this line, then press ENTER."
       -> PASS  (10.8s)

[10/69] #10 graphics      LOCATE (MODE 2 only)
       10 MODE 2
       -> PASS  (10.7s)

[11/69] #11 graphics      SCROLL (MODE 2 only)
       10 MODE 2
       -> PASS  (14.8s)

[12/69] #12 audio         TEMPO ΓÇö Music Speed
       10 PRINT "TEMPO DEMO"
       -> PASS  (16.8s)

[13/69] #13 audio         BEEP ΓÇö Musical Note Sequences
       10 PRINT "A single note: middle C, one beat."
       -> PASS  (12.7s)

[14/69] #14 audio         BEEP ΓÇö Musical Note Sequences
       10 PRINT "C major scale - 8 notes ascending (last C is one o
       -> PASS  (12.7s)

[15/69] #15 audio         PLAY ΓÇö Music Macro Language
       10 PRINT "PLAY MML SCALE DEMO"
       -> PASS  (12.8s)

[16/69] #16 audio         PLAY ΓÇö Music Macro Language
       10 PRINT "PLAY MML FULL FEATURE DEMO"
       -> PASS  (26.7s)

[17/69] #17 text          Conditional Statements
       10 PRINT "X has never been set, so it defaults to 0."
       -> PASS  (10.7s)

[18/69] #18 text          Conditional Statements
       10 LET X = 7
       -> PASS  (10.8s)

[19/69] #19 text          Conditional Statements
       10 LET X = 8 : LET Y = 7
       -> PASS  (10.8s)

[20/69] #20 text          Loops
       10 PRINT "Counting up from 1 to 5:"
       -> PASS  (10.8s)

[21/69] #21 text          Loops
       10 PRINT "Printing X while it is <= 5:"
       -> PASS  (10.7s)

[22/69] #22 text          Subroutines
       10 PRINT "Calling the subroutine at line 100:"
       -> PASS  (10.8s)

[23/69] #23 text          ON GOTO / ON GOSUB
       10 LET N = 2
       -> PASS  (10.8s)

[24/69] #24 text          Program Flow
       10 PRINT "Line 10 runs."
       -> PASS  (10.8s)

[25/69] #25 text          RANDOMIZE
       10 PRINT "RANDOMIZE without a number uses system time."
       -> PASS  (10.8s)

[26/69] #26 graphics      Mode Control
       10 MODE 1
       -> PASS  (10.8s)

[27/69] #27 graphics      PRINT (MODE 2)
       10 MODE 2, 16
       -> PASS  (10.8s)

[28/69] #28 graphics      PRINTAT / DRAWSTR
       10 MODE 2
       -> PASS  (10.8s)

[29/69] #29 graphics      PSET (MODE 2)
       10 MODE 2
       -> PASS  (10.8s)

[30/69] #30 graphics      CHARAT / TILE / PLOT (MODE 2)
       10 MODE 2
       -> PASS  (10.8s)

[31/69] #31 graphics      BOX (MODE 2)
       10 MODE 2, 16
       -> PASS  (10.7s)

[32/69] #32 graphics      FILL (MODE 2)
       10 MODE 2, 16
       -> PASS  (10.8s)

[33/69] #33 graphics      HLINE / VLINE (MODE 2)
       10 MODE 2, 16
       -> PASS  (10.7s)

[34/69] #34 graphics      CLSCHAR
       10 MODE 2
       -> PASS  (10.7s)

[35/69] #35 graphics      Tile Grid Read Functions (MODE 2)
       10 MODE 2
       -> PASS  (10.7s)

[36/69] #36 graphics      Tile Grid Read Functions (MODE 2)
       10 MODE 2
       -> PASS  (10.8s)

[37/69] #37 graphics      Font Control (MODE 2)
       10 MODE 2, 32
       -> PASS  (10.7s)

[38/69] #38 graphics      Custom Tiles (MODE 2)
       10 MODE 2, 16
       -> PASS  (12.9s)

[39/69] #39 graphics      PSET (MODE 3)
       10 MODE 3
       -> PASS  (10.7s)

[40/69] #40 graphics      PLOT (MODE 3)
       10 MODE 3
       -> PASS  (10.8s)

[41/69] #41 graphics      CIRCLE (MODE 3 only)
       10 MODE 3
       -> PASS  (10.7s)

[42/69] #42 graphics      LINE (MODE 3 only)
       10 MODE 3
       -> PASS  (10.7s)

[43/69] #43 graphics      BOX (MODE 3)
       10 MODE 3
       -> PASS  (10.8s)

[44/69] #44 graphics      POINT (MODE 3)
       10 MODE 3
       -> PASS  (10.7s)

[45/69] #45 graphics      CLS (MODE 3)
       10 MODE 3
       -> PASS  (10.8s)

[46/69] #46 text          Monochrome Sprite Definition
       10 REM ** Orbiting Sprite Demo **
       -> PASS  (14.8s)

[47/69] #48 file_io       File I/O
       10 OPEN "data.txt" FOR OUTPUT AS #1    ' Create/overwrite fi
       -> PASS  (10.9s)

[48/69] #49 file_io       File I/O
       10 OPEN "notes.txt" FOR OUTPUT AS #1
       -> PASS  (18.9s)

[49/69] #50 text          Math Functions
       10 PRINT "Math function sampler:"
       -> PASS  (10.7s)

[50/69] #51 text          Trigonometric Functions (radians)
       10 PRINT SIN(1.5708)   ' Sine: ~1
       -> PASS  (10.8s)

[51/69] #52 text          Random Numbers
       10 RANDOMIZE
       -> PASS  (10.8s)

[52/69] #53 text          String Functions
       10 A$ = "HELLO WORLD"
       -> PASS  (10.8s)

[53/69] #54 text          Repeat, Fill, and Padding
       10 PRINT "Drawing text separators with string builders."
       -> PASS  (10.8s)

[54/69] #55 text          Conversion Functions
       10 PRINT "Converting between numbers and strings."
       -> PASS  (10.8s)

[55/69] #58 text          Time and Date
       10 PRINT "Time and date functions:"
       -> PASS  (10.9s)

[56/69] #59 text          Cursor Position ΓÇö POS and CSRLIN
       10 PRINT "Line one"
       -> PASS  (10.8s)

[57/69] #60 text          DATA / READ / RESTORE
       10 DATA 1, 2, 3, "HELLO", 5.5
       -> PASS  (10.8s)

[58/69] #61 text          Named Data Streams
       10 PRINT "NAMED DATA STREAMS"
       -> PASS  (10.8s)

[59/69] #62 text          COLOR and BGCOLOR
       10 PRINT "COLOR changes following PRINT output."
       -> PASS  (10.8s)

[60/69] #63 text          Hex Color Forms
       10 COLOR &H0000FF       ' Red (&H BBGGRR)
       -> PASS  (10.8s)

[61/69] #64 text          Arithmetic
       10 PRINT 5 + 3         ' Addition: 8
       -> PASS  (10.8s)

[62/69] #65 text          Comparison
       10 LET X = 5 : LET Y = 5 : LET A = 3 : LET B = 7
       -> PASS  (10.8s)

[63/69] #66 text          Logical
       10 LET X = 8 : LET Y = 7
       -> PASS  (10.7s)

[64/69] #67 text          String Concatenation
       10 FIRST$ = "Hello"
       -> PASS  (10.8s)

[65/69] #69 audio         Musical Scale
       10 REM ** Musical Scales **
       -> PASS  (12.8s)

[66/69] #70 graphics      Tile Graphics Demo (MODE 2)
       10 REM ** Tile Border Demo **
       -> PASS  (10.8s)

[67/69] #71 graphics      Pixel Graphics Demo (MODE 3)
       10 REM ** Pixel Drawing Demo **
       -> PASS  (10.7s)

[68/69] #72 audio         Music Demo ΓÇö F├╝r Elise (Beethoven)
       10 PRINT "FUR ELISE - NW-BASIC DEMO"
       -> PASS  (24.9s)

[69/69] #73 file_io       File I/O Example
       10 REM ** Write and Read a Data File **
       -> PASS  (10.8s)

========================================================================

Results: 69 PASS  /  0 FAIL  (of 69 run)

Skipped categories (not run):
  #07 [skip(input) ] INPUT
  #47 [skip(input) ] Collision Detection Example
  #56 [skip(input) ] INKEY$ - Keyboard Input
  #57 [skip(input) ] INKEY$ - Keyboard Input
  #68 [skip(input) ] Number Guessing Game
