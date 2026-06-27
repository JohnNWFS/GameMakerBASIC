10 REM ============================================================
20 REM README MANUAL TEST — INKEY$ poll (press A to finish)
30 REM Uses INKEY$ + "" so the loop does not block each frame
40 REM ============================================================
50 PRINT "Press A to finish (other keys are ignored)."
60 K$ = INKEY$ + ""
70 IF K$ = "" THEN GOTO 60
80 IF K$ <> "A" AND K$ <> "a" THEN
90   PRINT "Ignoring "; K$
100   GOTO 60
110 ENDIF
120 PRINT "You pressed A."
130 PAUSE
140 END