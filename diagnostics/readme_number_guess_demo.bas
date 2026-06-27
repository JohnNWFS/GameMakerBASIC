10 REM ============================================================
20 REM README MANUAL TEST — Number guessing game (INPUT loop)
30 REM Guess 1-100; up to 10 tries
40 REM ============================================================
50 REM ** Number Guessing Game **
60 CLS : COLOR YELLOW
70 PRINT "Guess the number (1-100)!"
80 SECRET = RND(1, 100)
90 TRIES = 0
100 INPUT "Your guess: ", GUESS
110 TRIES = TRIES + 1
120 IF GUESS = SECRET THEN GOTO 180
130 IF GUESS < SECRET THEN PRINT "Too low!"
140 IF GUESS > SECRET THEN PRINT "Too high!"
150 IF TRIES >= 10 THEN GOTO 170
160 GOTO 100
170 PRINT "Sorry! The number was "; SECRET : END
180 COLOR GREEN
190 PRINT "Correct! You got it in "; TRIES; " tries!"
200 BEEP O1 C0.5 E0.5 G1
210 END