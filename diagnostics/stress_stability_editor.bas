10 REM ============================================================
20 REM NW-BASIC STABILITY EDITOR CHECKLIST
30 REM Automated GOTO/GOSUB sanity + manual editor command checklist
40 REM Manual steps: perform in editor AFTER this program ends
50 REM ============================================================
60 CLS
70 PRINT "NW-BASIC STABILITY EDITOR TEST"
80 PRINT "================================"
90 PRINT ""
100 REM --- Automated runtime sanity (same storage as editor) ---
110 GOTO 500
120 PRINT "TEST: GOTO_SKIP = FAIL"
500 PRINT "TEST: GOTO_LINE = PASS"
510 GOSUB 9000
520 IF ED_OK = 1 THEN PRINT "TEST: GOSUB_RET = PASS" ELSE PRINT "TEST: GOSUB_RET = FAIL"
530 PRINT ""
540 PRINT "MANUAL EDITOR CHECKLIST (type at editor prompt):"
550 PRINT "  1. NEW        — program clears"
560 PRINT "  2. Type 3 lines, LIST — lines appear in order"
570 PRINT "  3. Ctrl+Z     — last edit restores"
580 PRINT "  4. SAVE test  — file appears in DIR"
590 PRINT "  5. NEW, LOAD test — program restores"
600 PRINT "  6. RUN        — program executes"
610 PRINT "  7. HELP       — help browser opens"
620 PRINT "  8. DIR        — saved programs listed"
630 PRINT "  9. SCREENEDIT — screen editor opens (ESC to exit)"
640 PRINT " 10. QUIT       — returns to GameMaker (optional)"
650 PRINT ""
660 PRINT "Automated lines above must PASS before manual checks."
670 END
9000 ED_OK = 1
9010 RETURN